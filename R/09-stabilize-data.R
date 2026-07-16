# Apply a DGF's rules to a raw dataset to produce a "stable" version, and write
# it as a governed CSV that carries its own DGF and provenance.
#
# This is the payoff of the whole schema: a DGF authored once can be applied to
# each new raw extract to yield a clean, import-stable file, with the rules and
# lineage travelling inside the CSV (no sidecar).
#
# Two rule columns drive the transform, applied in order:
#   raw_data_import_rule    how to read the raw column correctly (as_mdy, as_EIN)
#   stable_data_transform   how to standardize it (dollarize, zero_pad, ...)
# Both name a function reachable in the session; a blank rule leaves the column
# as-is. This reuses the create_dgf() dispatch (exists()/get()).


#' Apply a named per-value function to a column, or pass it through (internal)
#'
#' @param col A vector (one DGF variable's data).
#' @param rule A function name, or `NA`/`""` to leave `col` unchanged.
#' @param env Environment to look the function up in.
#'
#' @return The transformed column, or `col` unchanged when `rule` is blank or
#'   the function is not found (with a warning in the latter case).
#'
#' @details Mirrors how [create_dgf()] applies `raw_data_import_rule`/
#'   `stable_data_format`: element-wise via `get(rule)`, NA-safe.
#' @noRd
apply_rule_col <- function( col, rule, env = parent.frame() ) {
  if( is.null(rule) || is.na(rule) || ! nzchar( trimws(rule) ) ) return( col )
  fn <- trimws( rule )
  if( ! exists( fn, mode = "function", envir = env ) ) {
    warning( "Rule function not found: ", fn, "() - column left unchanged.",
             call. = FALSE )
    return( col )
  }
  f <- get( fn, mode = "function", envir = env )
  out <- try( vapply( col, function(x) as.character( f(x) ), character(1),
                      USE.NAMES = FALSE ), silent = TRUE )
  if( inherits( out, "try-error" ) ) {
    warning( "Rule ", fn, "() failed - column left unchanged.", call. = FALSE )
    return( col )
  }
  out
}


#' Standardize a raw dataset with a DGF's rules
#'
#' Applies a DGF's per-variable rules to a raw dataset: first the
#' `raw_data_import_rule` (read the column correctly), then the
#' `stable_data_transform` (standardize it). The result is the "stable" version
#' of the data - what a downstream program should consume.
#'
#' @param raw A data frame, or a path to a raw `.csv`.
#' @param dgf A DGF data frame, or a path to a DGF `.xlsx` (read with
#'   [load_dgf()]).
#' @param env Environment in which to find the rule functions named in the DGF
#'   (e.g. project `dgf.R` helpers). Defaults to the caller's environment.
#'
#' @return A data frame: the columns the DGF describes, in DGF order, with each
#'   rule applied. Columns present in `raw` but absent from the DGF are dropped;
#'   a DGF variable with no matching raw column is skipped with a warning.
#'
#' @details Rules name a function reachable in `env` and are applied
#'   element-wise; a blank rule is a pass-through. This is the same dispatch
#'   [create_dgf()] uses, so the built-in helpers ([as_EIN()], [as_mm()], ...)
#'   and any user function work identically here.
#'
#' @seealso [write_stable_csv()], [create_dgf()]
#' @export
stabilize_data <- function( raw, dgf, env = parent.frame() ) {

  if( is.character(raw) && length(raw) == 1 )
    raw <- as.data.frame( suppressMessages( readr::read_csv( raw ) ) )
  if( is.character(dgf) && length(dgf) == 1 )
    dgf <- load_dgf( dgf )

  stopifnot( is.data.frame(raw), is.data.frame(dgf), "var_name" %in% names(dgf) )

  out <- list()
  for( i in seq_len( nrow(dgf) ) ) {
    v <- dgf$var_name[i]
    if( ! v %in% names(raw) ) {
      warning( "DGF variable not in raw data, skipped: ", v, call. = FALSE )
      next
    }
    col <- raw[[v]]
    col <- apply_rule_col( col, dgf$raw_data_import_rule[i], env )
    col <- apply_rule_col( col, dgf$stable_data_transform[i], env )
    out[[v]] <- col
  }

  as.data.frame( out, stringsAsFactors = FALSE, check.names = FALSE )
}


# Families that are portable (travel in the CSV). rg_ is session-only R
# artifacts (nested tables, plot objects) and is deliberately excluded.
.dgf_portable_prefixes <- c("var_name", "dd_", "raw_", "stable_", "validate_", "prov_")


#' The portable subset of a DGF (internal)
#'
#' @param dgf A DGF data frame.
#' @return `dgf` with the `rg_*` columns removed - the part that means something
#'   to a non-R program reading the governed CSV.
#' @noRd
dgf_portable <- function( dgf ) {
  keep <- grepl( "^(var_name$|dd_|raw_|stable_|validate_|prov_)", names(dgf) )
  dgf[ , keep, drop = FALSE ]
}


#' Per-column content hashes (internal)
#'
#' @param df A data frame.
#' @return A named list mapping each column to a content hash of its values.
#'
#' @details Hashes the column values (coerced to character so the hash tracks
#'   content, not storage), matching how provenance is chained across
#'   generations: a child file's `start_hash` equals its parent's
#'   `current_hash`.
#' @noRd
hash_columns <- function( df ) {
  h <- lapply( df, function(x) rlang::hash( as.character(x) ) )
  stats::setNames( as.list(h), names(df) )
}


#' Write a data frame to a stable CSV with embedded provenance
#'
#' @description
#' Writes a CSV that carries its own metadata embedded across the data rows (no
#' sidecar): named `payloads`, and - when a `dgf` is supplied - the DGF's
#' portable contract plus a provenance record. See [read_stable_csv()] to
#' recover them and [dgf_from_stable()] to rebuild the DGF.
#'
#' @param df Data frame to write (typically the output of [stabilize_data()]).
#' @param path Output file path.
#' @param payloads Named list of extra R objects to embed. Defaults to none.
#' @param dgf Optional DGF to embed. Its portable families (`dd_`/`raw_`/
#'   `stable_`/`validate_`/`prov_`) are stored; `rg_*` is excluded, since those
#'   are R-native artifacts meaningless to another program. A `provenance`
#'   payload is derived automatically.
#' @param start_hash Optional named list of the parent file's per-column
#'   `current_hash`, to chain lineage. When omitted, `dgf`'s `prov_start_hash`
#'   column is used if present.
#' @param replication Optional per-payload replication factors (default 2x).
#' @param chunk_limit Max characters per embedded chunk.
#'
#' @return Invisibly, `path`.
#'
#' @details With `dgf`, two payloads are added: `dgf` (the portable subset, as
#'   records) and `provenance` (`dgf_version`, `created`, `start_hash`,
#'   `current_hash` = per-column hashes of `df`). The provenance payload seeds
#'   the tier-1 core stamp, so version and lineage survive on every row.
#'
#' @seealso [read_stable_csv()], [dgf_from_stable()], [stabilize_data()]
#' @export
write_stable_csv <- function( df, path, payloads = list(), dgf = NULL,
                              start_hash = NULL, replication = list(),
                              chunk_limit = DGF_CHUNK_CHAR_LIMIT ) {

  if( ! is.null(dgf) ) {
    if( is.character(dgf) && length(dgf) == 1 ) dgf <- load_dgf( dgf )

    if( is.null(start_hash) && "prov_start_hash" %in% names(dgf) ) {
      sh <- unique( dgf$prov_start_hash[ nzchar( trimws(dgf$prov_start_hash) ) ] )
      # only a single whole-file start hash is meaningful here; ignore per-row
      if( length(sh) == 1 ) start_hash <- sh
    }

    payloads$dgf <- dgf_portable( dgf )
    payloads$provenance <- list(
      dgf_version  = as.character( utils::packageVersion("datagoodr") ),
      created      = format( Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC" ),
      start_hash   = start_hash,
      current_hash = hash_columns( df )
    )
  }

  if( length(payloads) == 0 )
    stop( "Nothing to embed: supply `payloads` and/or `dgf`.", call. = FALSE )

  write_governed_csv( df, path, payloads, core_stamp = NULL,
                      replication = replication, chunk_limit = chunk_limit )
}


#' Rebuild a DGF from a stable CSV read
#'
#' Reconstructs the portable DGF that was embedded in a stable CSV by
#' [write_stable_csv()].
#'
#' @param x The result of [read_stable_csv()], or a path to a stable CSV.
#'
#' @return The embedded DGF as a data frame (portable families only - no
#'   `rg_*`), or `NULL` if the file carries no DGF payload.
#'
#' @seealso [read_stable_csv()], [write_stable_csv()]
#' @export
dgf_from_stable <- function( x ) {
  if( is.character(x) && length(x) == 1 ) x <- read_stable_csv( x )
  if( is.null( x$meta ) || is.null( x$meta$dgf ) ) return( NULL )
  as.data.frame( x$meta$dgf, stringsAsFactors = FALSE )
}
