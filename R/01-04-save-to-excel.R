## ---- Excel's cell limit -----------------------------------------------------
## An Excel cell holds at most 32,767 characters. Some DGF cells are larger: the
## rg_graphics value/count table of a date column with thousands of distinct
## dates runs to 100,000+ characters. Excel cuts such a cell off when the file is
## opened and saved, which breaks the JSON. So save_to_excel() moves any cell
## over the limit to a second sheet, DGF_overflow, split into parts (one row per
## part), and leaves a short pointer in the main sheet. load_dgf() joins the
## parts back. The .csv mirror has no limit and is written whole.

DGF_OVERFLOW_SHEET  <- "DGF_overflow"
DGF_OVERFLOW_MARKER <- "<<DGF_overflow>>"
DGF_XLSX_CELL_LIMIT <- 32767L


## Per-character width once XML-escaped (& -> &amp;, " -> &quot;, ...).
## openxlsx checks the 32,767 limit on the escaped text, so a JSON cell full of
## quotes counts several times its length. Measuring escaped width keeps every
## written cell under the limit for both openxlsx and Excel.
#' @noRd
.xml_widths <- function( s ) {
  ch <- strsplit( s, "", fixed = TRUE )[[1]]
  1L + 4L * (ch == "&") + 3L * (ch %in% c("<", ">")) + 5L * (ch %in% c("\"", "'"))
}


## Move oversized cells out of a DGF. Returns the DGF with each oversized cell
## replaced by DGF_OVERFLOW_MARKER, plus a long table of its parts
## (var_name, column, part, n_parts, text), or NULL when nothing overflows.
## Sizes are escaped widths (see .xml_widths); parts stay under `part_size`.
#' @noRd
.dgf_split_overflow <- function( df, limit = DGF_XLSX_CELL_LIMIT,
                                 part_size = DGF_CHUNK_CHAR_LIMIT ) {
  rows <- list()
  key  <- if( "var_name" %in% names(df) ) as.character(df$var_name)
          else as.character( seq_len(nrow(df)) )
  for( cn in names(df) ) {
    x <- df[[cn]]
    if( ! is.character(x) ) next
    # cheap pre-filter: escaping at most sextuples a character
    cand <- which( ! is.na(x) & nchar(x) * 6L > limit )
    big  <- cand[ vapply( cand, function(i) sum( .xml_widths( x[i] ) ) > limit,
                          logical(1) ) ]
    for( i in big ) {
      s  <- x[i]
      w  <- .xml_widths( s )
      ch <- strsplit( s, "", fixed = TRUE )[[1]]
      grp <- ( cumsum(w) - 1L ) %/% part_size     # part index per character
      parts <- vapply( split( ch, grp ), paste, character(1), collapse = "" )
      names(parts) <- NULL
      rows[[ length(rows) + 1L ]] <- data.frame(
        var_name = key[i], column = cn, part = seq_along(parts),
        n_parts = length(parts), text = parts, stringsAsFactors = FALSE )
      df[[cn]][i] <- DGF_OVERFLOW_MARKER
    }
  }
  list( dgf = df,
        overflow = if( length(rows) ) do.call( rbind, rows ) else NULL )
}


## Put overflowed cells back: each pointer cell gets its parts, in order. A
## pointer whose parts are missing or incomplete becomes "" with a warning
## (the profile for that variable is lost; re-run create_dgf() to rebuild it).
#' @noRd
.dgf_join_overflow <- function( dgf, overflow ) {
  key <- if( "var_name" %in% names(dgf) ) as.character(dgf$var_name)
         else as.character( seq_len(nrow(dgf)) )
  lost <- character(0)
  for( cn in names(dgf) ) {
    x <- dgf[[cn]]
    if( ! is.character(x) ) next
    hit <- which( ! is.na(x) & x == DGF_OVERFLOW_MARKER )
    for( i in hit ) {
      p <- if( is.null(overflow) ) NULL
           else overflow[ overflow$var_name == key[i] & overflow$column == cn, ]
      ok <- ! is.null(p) && nrow(p) > 0 &&
            setequal( p$part, seq_len( p$n_parts[1] ) )
      if( ok ) {
        p <- p[ order(p$part), ]
        dgf[[cn]][i] <- paste( p$text, collapse = "" )
      } else {
        dgf[[cn]][i] <- ""
        lost <- c( lost, paste0( key[i], "$", cn ) )
      }
    }
  }
  if( length(lost) )
    warning( "DGF overflow parts missing or incomplete for: ",
             paste( lost, collapse = ", " ),
             ". Those cells were left blank; re-run create_dgf() to rebuild them.",
             call. = FALSE )
  dgf
}


#' @title Saves DGF to excel
#'
#' @description Write the DGF to excel.
#'
#' @details Used by [create_dgf()], [update_dgf()] and [create_rg()]. Any cell
#'   over Excel's 32,767-character limit (e.g. the graphics data of a date
#'   column with thousands of distinct dates) is moved to a second sheet,
#'   `DGF_overflow`, in parts, with a `<<DGF_overflow>>` pointer left in the
#'   main sheet. [load_dgf()] joins the parts back, so the DGF survives being
#'   opened and saved in Excel. Leave the `DGF_overflow` sheet and the pointer
#'   cells as they are.
#'
#' @param df Data frame to write.
#' @param filename Destination `.xlsx` path.
#' @param open Logical; launch the saved file in Excel. Defaults to
#'   [interactive()], so it stays off in scripts, tests, and CI.
#'
#' @export
save_to_excel <- function( df, filename="DGF.xlsx", open = interactive() )
{

  split <- .dgf_split_overflow( df )
  df    <- split$dgf

  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet( wb, "DGF" )
  openxlsx::writeData( wb, sheet="DGF", x=df )

  nrow <- nrow(df) + 1
  ncol <- ncol(df)

  g1 <- 2:5
  g2 <- 6:12
  g2.2 <- 8:10
  g3 <- 13:17
  g3.2 <- 13:17
  g4 <- 18:19

  openxlsx::setRowHeights( wb, sheet=1, rows=1:nrow, heights=25  )
  openxlsx::setColWidths(  wb, sheet=1, cols=1:ncol,  widths =20 )

  openxlsx::modifyBaseFont( wb, fontSize=11, fontName='Calibri Light' )

  # openxlsx::addStyle( wb, sheet=1, style=valign,
  #           rows=1:nrow, cols=1:ncol,
  #           gridExpand=TRUE, stack=TRUE )

  headerStyle <-
    openxlsx::createStyle(
      fontName = 'Segoe UI Black',
      fontSize = 12,
      fontColour = "#FFFFFF",
      textDecoration="bold",
      halign = "left",
      valign = "center",
      fgFill = "#404040"  )

  openxlsx::addStyle( wb, sheet=1,
    headerStyle, rows=1, cols=1:ncol )


  var_name <-
    openxlsx::createStyle(
      fontName = 'Segoe UI Black',
      fontSize = 12,
      fontColour = "#FFFFFF",
      fgFill = "#404040",
      halign = "left",
      valign = "center" )

  openxlsx::addStyle( wb, sheet=1, var_name, rows=2:nrow, cols=1 )

  var_name.blue <- openxlsx::createStyle(
    fgFill = "#44546A" )
  openxlsx::addStyle( wb, sheet=1, var_name.blue,
    rows=1, cols=c(g1,g3), stack=T )

  var_name.brown <- openxlsx::createStyle(
    fgFill = "#833C0C" )
  openxlsx::addStyle( wb, sheet=1, var_name.brown,
    rows=1, cols=c(g2,g4), stack=T )

  blues <- openxlsx::createStyle(
    fgFill = "#E3E7ED" )
  openxlsx::addStyle( wb, sheet=1, blues,
    rows=2:nrow, cols=g1, gridExpand=TRUE, stack=T  )
  openxlsx::addStyle( wb, sheet=1, blues,
    rows=2:nrow, cols=g3, gridExpand=TRUE, stack=T  )

  browns <- openxlsx::createStyle(
    fgFill = "#FEF2EC" )
  openxlsx::addStyle( wb, sheet=1, browns,
    rows=2:nrow, cols=g2, gridExpand=TRUE, stack=T  )
  openxlsx::addStyle( wb, sheet=1, browns,
    rows=2:nrow, cols=g4, gridExpand=TRUE, stack=T  )

  # openxlsx::addStyle( wb, sheet=1, first3,
  #   rows=2:20, cols=5, stack=T )

  indentAll <- openxlsx::createStyle(
    indent = 1 )

  openxlsx::addStyle( wb, sheet=1, indentAll,
    rows=1:nrow, cols=1:ncol,
    gridExpand=TRUE, stack=TRUE  )

  monospace <- openxlsx::createStyle(
    fontName = 'Lucida Console',
    fontSize = 10,
    halign = "left",
    valign = "center" )

  openxlsx::addStyle( wb, sheet=1, monospace,
    rows=2:nrow, cols=c(g2.2,g3.2), gridExpand=TRUE, stack=T )

  ninePoint <- openxlsx::createStyle(
    fontName = 'Calibri Light',
    fontSize = 9 )

  openxlsx::addStyle( wb, sheet=1, ninePoint,
    rows=2:nrow, cols=6:7, gridExpand=TRUE, stack=T  )
  openxlsx::addStyle( wb, sheet=1, ninePoint,
    rows=2:nrow, cols=12:13, gridExpand=TRUE, stack=T  )

  openxlsx::freezePane( wb, sheet=1, firstActiveRow=2, firstActiveCol=2 )

  # openxlsx::addStyle( wb, sheet=1, unlocked,
  #   rows=2:nrow, cols=2:4, gridExpand=TRUE, stack=T  )
  # openxlsx::addStyle( wb, sheet=1, unlocked,
  #   rows=2:nrow, cols=7:ncol, gridExpand=TRUE, stack=T  )
  # openxlsx::addStyle( wb, sheet=1, unlocked,
  #   rows=1:nrow, cols=1, stack=T  )
  # openxlsx::addStyle( wb, sheet=1, unlocked,
  #   rows=1, cols=1:ncol, stack=T  )

  if( ! is.null( split$overflow ) ) {
    openxlsx::addWorksheet( wb, DGF_OVERFLOW_SHEET )
    openxlsx::writeData( wb, sheet = DGF_OVERFLOW_SHEET, x = split$overflow )
  }

  openxlsx::saveWorkbook( wb, filename, overwrite = TRUE )
  if( open ) openxlsx::openXL( filename )
  return(invisible(NULL))
}




##  1 dgf_vname,
#  --- G1  # BLUES
#  2 dgf_vlabel,
#  3 dgf_vdesc,
#  4 dgf_vname_alias,

### dgf_duplicated,

#  --- G2  # BROWNS
#  5 dgf_first5_raw,
#  6 dgf_raw_type,
#  7 dgf_raw_convert,
#  8 dgf_type,
#  9 dgf_type_class,
#  10 dgf_format_out,
#  --- G3  # BROWNS
#  11 dgf_first5,
#  12 dgf_values,
#  13 dgf_f_levels,
#  14 dgf_f_order,
#  --- G4  # BLUES
#  15 raw_to_stable_transform,
#  16 validate_rules

# darkblue  headers: #44546A  cells: #E3E7ED
# darkbrown headers: #833C0C  cells: #FEF2EC



