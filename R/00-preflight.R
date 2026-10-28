## PRE-FLIGHT CHECK FOR DEGENERATE COLUMNS ---------------------------------------------
##
## create_dgf() profiles every column, which on a large file takes minutes. A column the
## profilers cannot handle used to be discovered by crashing partway through, with an error
## that named no column. preflight_dgf() finds those columns first, far faster than a build, and reports
## all of them at once.

# the spellings a yes/no flag is written in
.BOOL_VOCAB <- c( "true", "false", "t", "f", "yes", "no", "y", "n", "1", "0" )

.PREFLIGHT_COLS <- c( "var_name", "rule", "severity", "detail", "suggestion" )

# a placeholder (0000000000, N/A, ...) is reported only when it holds at least this share of rows
.PLACEHOLDER_MIN_SHARE <- 0.001


#' Check a dataset for degenerate columns before building a DGF
#'
#' Scans every column and reports the ones that tend to break, or quietly mislead, a
#' profile: a column with a single value, an all-missing column, values too long for a date
#' parser, a yes/no flag spelled several ways, zero-padded codes, duplicate columns,
#' placeholder values, non-finite numbers, and timestamp columns with too many distinct
#' values to store whole. It is much faster than \code{\link{create_dgf}} (about 40 seconds
#' on a file of 568,000 rows and 199 columns, where the build took about 22 minutes with the
#' formex release before its 2026-10-28 speed-up), and it
#' reports \strong{every} finding at once instead of the first failure.
#'
#' \code{\link{create_dgf}} runs this itself (see its \code{preflight} argument); call it
#' directly to look at a dataset before committing to a build.
#'
#' @param df A data frame, or the path to a \code{.csv} file (read with every column as
#'   text, as \code{\link{create_dgf}} does).
#' @param max_chr Values of at least this many bytes are reported as \code{long_values}.
#'   Defaults to \code{1000}, the length at which base R's \code{strptime()} gives up.
#' @param smoke_n \code{NULL} (the default), or a number of rows. If given, also runs
#'   \code{\link{create_dgf}} on a random sample of that many rows (written to a temporary
#'   folder, with the pre-flight off) and reports any failure as a \code{smoke_test_failed}
#'   finding that names the variable. A sample of a few thousand rows finds most crashes in
#'   about a minute, even on a file whose full build takes half an hour.
#' @param seed Integer seed for the smoke-test sample. The session's random-number state is
#'   left as it was.
#'
#' @details Missing means \code{NA} or blank (empty or whitespace-only), as in
#'   \code{\link{create_dgf}}. The rules, with their severity:
#'
#'   \describe{
#'     \item{\code{smoke_test_failed} (error)}{the sample build failed (only with \code{smoke_n}).}
#'     \item{\code{constant} (warn)}{every row has the same value.}
#'     \item{\code{single_value_with_blanks} (warn)}{one value plus blanks, e.g. an
#'       \code{X}/blank checkbox.}
#'     \item{\code{all_missing} (warn)}{no values at all.}
#'     \item{\code{duplicate_column} (warn)}{identical to an earlier column.}
#'     \item{\code{mixed_boolean_encoding} (warn)}{a flag written more than two ways
#'       (\code{0}, \code{1}, \code{true}, \code{false}).}
#'     \item{\code{non_finite} (warn)}{\code{Inf}, \code{-Inf} or \code{NaN}.}
#'     \item{\code{placeholder_value} (info, warn from 5\% of rows)}{\code{0000000000},
#'       \code{9999}, \code{N/A}, ... holding at least 0.1\% of the rows.}
#'     \item{\code{long_values} (info)}{values of \code{max_chr} bytes or more.}
#'     \item{\code{leading_zero_code} (info)}{digit strings with leading zeros, which a
#'       number would lose.}
#'     \item{\code{high_cardinality_temporal} (info)}{too many distinct timestamps to store
#'       whole; see \code{getOption("datagoodr.temporal.max_values")}.}
#'   }
#'
#'   \code{create_dgf(preflight = "warn")} reports errors and warnings; \code{"error"}
#'   stops on either.
#'
#' @return A data frame with one row per finding and columns \code{var_name}, \code{rule},
#'   \code{severity} (\code{"error"}, \code{"warn"} or \code{"info"}), \code{detail} and
#'   \code{suggestion}; zero rows for a clean dataset. It has class \code{dgf_preflight},
#'   with its own \code{print()} method.
#'
#' @examples
#' df <- data.frame(
#'   id    = sprintf("%03d", 1:40),
#'   year  = rep("2023", 40),                          # one value
#'   box_x = ifelse(seq_len(40) %% 4 == 0, "X", ""),   # one value plus blanks
#'   n     = rnorm(40)
#' )
#' preflight_dgf(df)
#'
#' @seealso \code{\link{create_dgf}}
#' @export
preflight_dgf <- function( df, max_chr = 1000L, smoke_n = NULL, seed = 1L ) {

  if( is.character(df) && length(df) == 1 )
    df <- as.data.frame( suppressMessages(
      readr::read_csv( df, col_types = readr::cols( .default = "c" ), lazy = FALSE ) ) )
  if( !is.data.frame(df) ) stop( "`df` must be a data frame or the path to a .csv file.", call. = FALSE )
  df <- .collapse_list_cols( df )

  n_row   <- nrow( df )
  cap     <- getOption( "datagoodr.temporal.max_values", 10000L )
  out     <- list()
  add     <- function( var, rule, severity, detail, suggestion )
    out[[ length(out) + 1L ]] <<- data.frame( var_name = var, rule = rule, severity = severity,
                                              detail = detail, suggestion = suggestion,
                                              stringsAsFactors = FALSE )
  pct     <- function( k ) sprintf( "%.1f%%", 100 * k / max( n_row, 1L ) )
  shown   <- function( v, n = 4L ) paste0( "'", utils::head( v, n ), "'", collapse = ", " )

  sig    <- character( ncol(df) )                   # cheap signature, to find duplicate columns
  min_ph <- max( 1L, ceiling( .PLACEHOLDER_MIN_SHARE * n_row ) )
  ph_pat <- "^(0{4,}|9{4,}|n/?a|null|none|unknown|tbd|\\?+|-+)$"
  for( j in seq_along(df) ) {
    nm <- names(df)[j]
    x  <- df[[j]]
    v  <- as.character( x )

    # Everything below works on the DISTINCT values and how many rows hold each, not on every
    # row. Scanning all rows per rule (tolower, regexes) took ~100 s on a 568,000 x 199 file,
    # nearly all of it spent on high-cardinality columns where a rule needs a handful of values.
    ux  <- unique( v )
    idx <- match( v, ux )
    # blank = NA, empty, or whitespace-only. A whitespace-only value must START with whitespace,
    # so startsWith() finds the few candidates and the regex only checks those.
    ub  <- is.na( ux ) | !nzchar( ux )
    ws  <- which( !ub & ( startsWith(ux, " ") | startsWith(ux, "\t") |
                          startsWith(ux, "\n") | startsWith(ux, "\r") ) )
    if( length(ws) ) ub[ ws[ grepl( "^[[:space:]]*$", ux[ws] ) ] ] <- TRUE
    u   <- ux[ !ub ]                                # distinct non-blank values
    cnt <- tabulate( idx, nbins = length(ux) )[ !ub ]   # rows holding each
    k   <- sum( cnt )
    nd  <- length( u )

    if( k == 0L ) {
      add( nm, "all_missing", "warn",
           sprintf( "all %d values are missing", n_row ),
           "drop it, or document why it is empty" )
      sig[j] <- paste( "empty", n_row )
      next
    }

    sig[j] <- paste( nd, k, paste( v[ utils::head( which( !ub[idx] ), 20L ) ], collapse = "\r" ) )

    ## one distinct value
    if( nd == 1L ) {
      if( k == n_row )
        add( nm, "constant", "warn", sprintf( "every row is '%s'", u ),
             "no information to analyse; drop it, or record the value in the documentation" )
      else
        add( nm, "single_value_with_blanks", "warn",
             sprintf( "one value ('%s') in %d of %d rows (%s); the rest are blank", u, k, n_row, pct(k) ),
             paste( "if a blank means 'no' this is a checkbox: recode to TRUE/FALSE;",
                    "if a blank means 'not asked', leave blank; otherwise drop it" ) )
    }

    ## values too long for strptime()
    if( is.character(x) || is.factor(x) ) {
      bytes <- nchar( u, type = "bytes" )
      long  <- sum( cnt[ bytes >= max_chr ] )
      if( long > 0L )
        add( nm, "long_values", "info",
             sprintf( "%d value(s) of %d bytes or more (longest %d)", long, as.integer(max_chr), max(bytes) ),
             "free text: it is kept out of the date detectors; no action needed" )
    }

    ## a yes/no flag spelled more than two ways (a flag has few spellings, so skip wide columns)
    if( nd > 2L && nd <= 20L && all( tolower(u) %in% .BOOL_VOCAB ) )
      add( nm, "mixed_boolean_encoding", "warn",
           sprintf( "one flag written %d ways: %s", nd, shown( sort(u), 8L ) ),
           "harmonise to one TRUE/FALSE before analysis; type it boolean" )

    ## zero-padded codes: a number would drop the zeros. Cheap test first; the regex only runs
    ## on a column that has a value starting with 0.
    zr <- startsWith( u, "0" ) & nchar( u ) > 1L
    if( nd > 1L && any(zr) && all( grepl( "^[0-9]+$", u ) ) ) {
      z <- sum( cnt[ zr ] )
      add( nm, "leading_zero_code", "info",
           sprintf( "%d value(s) (%s) are digit strings with a leading zero, e.g. '%s'",
                    z, pct(z), u[ zr ][1] ),
           "keep as text: type it identifier or categorical, never number" )
    }

    ## placeholders. One must hold at least the minimum share of rows to be reported (on a real
    ## 568,000-row file, 71 of 73 hits touched under 200 rows; one organisation really is called
    ## "None"; the two that mattered held 0.4% and 25%), so only values that frequent are tested.
    cand <- which( cnt >= min_ph )
    if( length(cand) ) {
      hit <- cand[ grepl( ph_pat, u[cand], ignore.case = TRUE ) ]
      if( length(hit) ) {
        n_ph  <- sum( cnt[hit] )
        share <- n_ph / max( n_row, 1L )
        add( nm, "placeholder_value", if( share >= 0.05 ) "warn" else "info",
             sprintf( "%d row(s) (%s) hold the placeholder %s", n_ph, pct(n_ph), shown( u[hit] ) ),
             "probably 'missing' written as a value; consider recoding to blank" )
      }
    }

    ## non-finite numbers
    nf <- which( u %in% c( "Inf", "-Inf", "NaN" ) )
    if( length(nf) )
      add( nm, "non_finite", "warn",
           sprintf( "%d row(s) hold %s", sum( cnt[nf] ), shown( u[nf] ) ),
           "not a usable number: recode to blank, or find where it was produced" )

    ## too many distinct timestamps to store whole
    cut <- .timestamp_cut( u, cap )
    if( !is.na(cut) )
      add( nm, "high_cardinality_temporal", "info",
           sprintf( "%d distinct timestamps (more than datagoodr.temporal.max_values = %d)", nd, as.integer(cap) ),
           sprintf( "stored at %s resolution in the DGF; raise the option to keep more",
                    c( `16` = "minute", `13` = "hour", `10` = "day" )[[ as.character(cut) ]] ) )
  }

  ## duplicate columns: same signature, then a full comparison
  dup <- which( duplicated(sig) | duplicated(sig, fromLast = TRUE) )
  seen <- list()
  for( j in dup ) {
    if( startsWith( sig[j], "empty " ) ) next
    first <- seen[[ sig[j] ]]
    if( is.null(first) ) { seen[[ sig[j] ]] <- j; next }
    if( identical( as.character(df[[first]]), as.character(df[[j]]) ) )
      add( names(df)[j], "duplicate_column", "warn",
           sprintf( "identical to the earlier column '%s'", names(df)[first] ),
           "keep one; the copy is profiled again for nothing" )
  }

  ## optional: really try it on a sample
  if( !is.null(smoke_n) ) {
    n_s  <- min( as.integer(smoke_n), n_row )
    # one seeded scope around the sample and the build: formex draws its own random
    # sample while guessing types, and the caller's random numbers must come out unchanged
    err  <- .with_seed( seed, {
      smp <- df[ sample.int( n_row, n_s ), , drop = FALSE ]
      tryCatch( {
        utils::capture.output( suppressMessages( suppressWarnings(
          create_dgf( smp, dir = tempdir(), file = "preflight-smoke", open = FALSE, preflight = "off" ) ) ) )
        NULL
      }, error = function(e) conditionMessage(e) )
    } )
    if( !is.null(err) ) {
      v <- sub( ".*variable '([^']+)'.*", "\\1", err )
      add( if( identical(v, err) ) NA_character_ else v, "smoke_test_failed", "error",
           sprintf( "create_dgf() failed on a %d-row sample: %s", n_s, err ),
           "fix or exclude this column; the full build would fail the same way" )
    }
  }

  res <- if( length(out) ) do.call( rbind, out )
         else data.frame( var_name = character(), rule = character(), severity = character(),
                          detail = character(), suggestion = character(), stringsAsFactors = FALSE )
  res <- res[ order( match( res$severity, c("error", "warn", "info") ) ), .PREFLIGHT_COLS, drop = FALSE ]
  rownames(res) <- NULL
  attr( res, "n_rows" ) <- n_row
  attr( res, "n_cols" ) <- ncol( df )
  class( res ) <- c( "dgf_preflight", "data.frame" )
  res
}


## Evaluate `expr` with a seed, leaving the session's RNG state exactly as it was.
#' @noRd
.with_seed <- function( seed, expr ) {
  had <- exists( ".Random.seed", envir = globalenv(), inherits = FALSE )
  if( had ) old <- get( ".Random.seed", envir = globalenv() )
  on.exit( if( had ) assign( ".Random.seed", old, envir = globalenv() )
           else if( exists( ".Random.seed", envir = globalenv(), inherits = FALSE ) )
                  rm( ".Random.seed", envir = globalenv() ) )
  set.seed( seed )
  expr
}


#' @export
print.dgf_preflight <- function( x, ... ) {
  n_e <- sum( x$severity == "error" ); n_w <- sum( x$severity == "warn" ); n_i <- sum( x$severity == "info" )
  dims <- function( a ) if( is.null(a) ) "?" else format( a, big.mark = "," )
  cat( sprintf( "preflight_dgf: %s columns, %s rows: %d error(s), %d warning(s), %d note(s)\n",
                dims( attr(x, "n_cols") ), dims( attr(x, "n_rows") ), n_e, n_w, n_i ) )
  if( nrow(x) == 0L ) { cat( "  no degenerate columns found\n" ); return( invisible(x) ) }
  for( r in unique( x$rule ) ) {
    rows <- x[ x$rule == r, , drop = FALSE ]
    cat( sprintf( "\n[%s] %s: %d column(s)\n", rows$severity[1], r, nrow(rows) ) )
    for( i in seq_len( min( nrow(rows), 8L ) ) )
      cat( sprintf( "  %-34s %s\n", if( is.na(rows$var_name[i]) ) "(unknown)" else rows$var_name[i], rows$detail[i] ) )
    if( nrow(rows) > 8L ) cat( sprintf( "  ... and %d more\n", nrow(rows) - 8L ) )
    cat( sprintf( "  -> %s\n", rows$suggestion[1] ) )
  }
  invisible( x )
}


## What create_dgf() does with the findings (see its `preflight` argument).
#' @noRd
.report_preflight <- function( findings, policy ) {
  flagged <- findings[ findings$severity %in% c( "error", "warn" ), , drop = FALSE ]
  if( policy == "error" && nrow(flagged) > 0L )
    stop( sprintf( "preflight_dgf() flagged %d column(s): %s. Fix them, or use create_dgf(preflight = \"warn\") to go on.",
                   length( unique(flagged$var_name) ),
                   paste( utils::head( unique(flagged$var_name), 10L ), collapse = ", " ) ), call. = FALSE )
  if( nrow(flagged) > 0L ) {
    by_rule <- table( flagged$rule )
    message( sprintf( "preflight: %d column(s) need attention (%s). Run preflight_dgf(df) for the detail; the findings are kept in attr(<dgf>, \"preflight\").",
                      length( unique(flagged$var_name) ),
                      paste( sprintf( "%s x%d", names(by_rule), as.integer(by_rule) ), collapse = ", " ) ) )
  }
  invisible( findings )
}
