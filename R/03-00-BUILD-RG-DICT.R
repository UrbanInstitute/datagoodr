####################################
### Internal Functions
####################################

# Per-variable render context.
#
# The render/paste functions need the current variable's DGF row (a named list
# keyed by DGF column). Rather than a bare global `xx`, the current row is held
# in this package-internal environment and read via get_xx(). create_section()
# (full render) and the dg_*() granular helpers set it with set_xx().
.dg_env <- new.env( parent = emptyenv() )

#' @keywords internal
#' @noRd
set_xx <- function( x ) {
  .dg_env$xx <- x
  invisible( x )
}

#' @keywords internal
#' @noRd
get_xx <- function() {
  if( is.null(.dg_env$xx) )
  { stop( "No datagoodr variable context is set. Call a dg_*() helper ",
          "(e.g. dg_stats(dgf, \"VNAME\")) or render via create_all_sections().",
          call. = FALSE ) }
  .dg_env$xx
}

#' Convert JSON text to a nested R list
#'
#' This internal helper function takes a JSON string and converts it
#' into a nested R list using \pkg{jsonlite}.
#'
#' @param json_text A character string containing valid JSON.
#'
#' @return A nested list representation of the JSON.
#'
#' @keywords internal
#' @noRd
json_to_list <- function(json_text) {
  lst <- jsonlite::fromJSON(json_text, simplifyVector = FALSE)
  return(lst)
}


#' Convert JSON text to a data frame
#'
#' This internal helper function takes a JSON string and converts it
#' into a data frame using \pkg{jsonlite}.
#'
#' @param json_text A character string containing valid JSON.
#'
#' @return A data frame representation of the JSON.
#'
#' @keywords internal
#' @noRd
json_to_df <- function(json_text) {
  df <- jsonlite::fromJSON(json_text)
  return(as.data.frame(df))
}



###  CONVERT CELL VALUE TO DD MARKDOWN TEXT --------
#' Convert a cell value to Markdown text
#'
#' Take a variable name and its label,
#' looks up the value from the object `xx`, and prints it as
#' a Markdown string in definition-list style.
#'
#' @param VNAME A character string; the name of the variable in `xx`.
#' @param LABEL A character string; the label to display before the value.
#'
#' @return Invisibly returns the constructed Markdown string. The string is
#'   also printed to the quarto document render using [cat()].
#'
#' @details
#' The global object `xx` is expected to be available in the environment
#' and contain a named element corresponding to `VNAME`. `xx` is defined in
#' the \link{create_section} function in R/03-01-create-sections.R.
#'
#' @keywords internal
#' @noRd
v_to_txt <- function( VNAME, LABEL = "" )
{
  value  <- get_xx()[[VNAME]]
  # Show blank (not "NA") for empty/unfilled metadata fields such as SCOPE
  # or LOCATION CODE.
  if( is.null(value) || length(value) == 0 || is.na(value) ) value <- ""
  # An empty LABEL prints the value on its own (used for the prominent
  # plain-language variable label). Otherwise emit the label and value as two
  # separate cells so the stylesheet can align short metadata values into a
  # column (div3) or flow prose after the label (div4) - see datagoodr.css.
  if( is.null(LABEL) || trimws(LABEL) == "" )
  { cat( value, "\n\n" ) }
  else
  {
    esc <- function( s ) {
      s <- gsub( "&", "&amp;", s, fixed = TRUE )
      s <- gsub( "<", "&lt;",  s, fixed = TRUE )
      gsub( ">", "&gt;",  s, fixed = TRUE )
    }
    cat( "\n<div class=\"dg-field\"><span class=\"dg-k\">", esc( LABEL ),
         "</span><span class=\"dg-v\">", esc( value ),
         "</span></div>\n\n", sep = "" )
  }
}

###########################################
### Paste properties
###########################################


#' Print Properties of a Variable into RG
#'
#' Read rg_properties column of DGF and print properties in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"PROPERTIES"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of \link{create_div} in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_properties <- function(VNAME, LABEL = "PROPERTIES"){

  # for testing VNAME <- div.fxs$VNAME
  info <- get_xx()[[VNAME]]
  tab <- json_to_df(info)

  # Drop rows that now live elsewhere: Most Common (shown in MOST COMMON VALUES)
  # and Skew/Kurtosis (shown in the numeric STATS section). Filtered defensively
  # so DGFs built before these rows were removed from get_properties() also
  # render without them.
  if( "STAT" %in% names(tab) )
  { tab <- tab[ ! trimws(as.character(tab$STAT)) %in%
                  c("Most Common", "Skew", "Kurtosis"), , drop = FALSE ] }

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( tab, align=c("l","r", "r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}


###########################################
### Paste factor/logical levels
###########################################

#' Print the level dictionary of a factor/logical variable into the RG
#'
#' Reads the `dd_f_level` column of the DGF (a JSON table of level codes and
#' their editable labels) and prints it as a two-column LEVELS table.
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"dd_f_level"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"LEVELS"`.
#'
#' @return No return value; prints the LEVELS table to the RG. Nothing is
#'   printed when the variable has no levels.
#'
#' @details Internal to \link{create_div} in R/03-01-create-sections.R. The
#'   table is capped at the first 50 levels.
#'
#' @import knitr
#' @export
paste_levels <- function( VNAME, LABEL = "CATEGORY MEANING" ){

  info <- get_xx()[[VNAME]]
  if( is.null(info) || is.na(info) || trimws(info) == "" )
  { return( invisible(NULL) ) }

  tab <- json_to_df(info)

  # No levels captured (e.g. empty JSON array) - nothing to print
  if( nrow(tab) == 0 || ncol(tab) < 2 )
  { return( invisible(NULL) ) }

  if( nrow(tab) > 50 )
  { tab <- tab[ 1:50, ] }

  lvl  <- as.character( tab[[1]] )
  mean <- as.character( tab[[2]] )

  if( nzchar(trimws(LABEL)) ) cat( "**", LABEL, "**:\n\n", sep = "" )

  # The Meaning column only appears once labels have been customised (differ
  # from the raw level codes); otherwise show just the Label column.
  if( levels_customized( lvl, mean ) ) {
    out <- data.frame( Label = lvl, Meaning = ifelse(is.na(mean), "", mean),
                       stringsAsFactors = FALSE )
    k <- knitr::kable( out, align = c("l","l") )
  } else {
    out <- data.frame( Label = lvl, stringsAsFactors = FALSE )
    k <- knitr::kable( out, align = c("l") )
  }
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}


# TRUE when at least one level label has been edited away from its raw code.
levels_customized <- function( level, label ) {
  level <- as.character( level ); label <- as.character( label )
  any( !is.na(label) & nzchar( trimws(label) ) & trimws(label) != trimws(level) )
}


### Factor levels + frequency (+ optional meaning) --------------------------
#' Print the combined FACTOR LEVELS table into the RG
#'
#' Joins the factor level frequencies (`rg_stats`) with the editable level
#' dictionary (`dd_f_level`) into one table: Label | Frequency | Meaning. The
#' Meaning column is shown only when the labels have been customised away from
#' the raw level codes.
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"dd_f_level"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"FACTOR LEVELS"`.
#'
#' @return No return value; prints the table to the RG.
#' @import knitr
#' @export
paste_levels_freq <- function( VNAME, LABEL = "FACTOR LEVELS" ){

  freq <- get_xx()[["rg_stats"]]
  dict <- get_xx()[["dd_f_level"]]
  if( is.null(freq) || is.na(freq) || trimws(freq) == "" )
  { return( invisible(NULL) ) }

  ftab <- json_to_df(freq)                       # Value, Frequency (desc)
  if( nrow(ftab) == 0 || ! all( c("Value","Frequency") %in% names(ftab) ) )
  { return( invisible(NULL) ) }
  ftab$Value     <- as.character( ftab$Value )
  ftab$Frequency <- suppressWarnings( as.numeric( as.character( ftab$Frequency ) ) )

  # look up an editable meaning for each level (blank when uncustomised)
  meaning    <- rep( "", nrow(ftab) )
  customized <- FALSE
  if( ! is.null(dict) && ! is.na(dict) && trimws(dict) != "" ) {
    dtab <- json_to_df(dict)
    if( ncol(dtab) >= 2 ) {
      lvl <- as.character( dtab[[1]] ); lab <- as.character( dtab[[2]] )
      m   <- lab[ match( ftab$Value, lvl ) ]
      meaning    <- ifelse( is.na(m), "", m )
      customized <- levels_customized( ftab$Value, meaning )
    }
  }

  # keep up to 50 rows; the full-width cell is height-capped and scrolls (CSS)
  if( nrow(ftab) > 50 ) { ftab <- ftab[ 1:50, ]; meaning <- meaning[ 1:50 ] }
  freq.fmt <- formatC( ftab$Frequency, big.mark = ",", format = "d" )

  if( nzchar(trimws(LABEL)) ) cat( "**", LABEL, "**:\n\n", sep = "" )
  if( customized ) {
    out <- data.frame( Label = ftab$Value, Frequency = freq.fmt, Meaning = meaning,
                       stringsAsFactors = FALSE )
    k <- knitr::kable( out, align = c("l","r","l") )
  } else {
    out <- data.frame( Label = ftab$Value, Frequency = freq.fmt,
                       stringsAsFactors = FALSE )
    k <- knitr::kable( out, align = c("l","r") )
  }
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}


### Logical category labels laid out horizontally --------------------------
#' Print the logical CATEGORY LABELS transposed across a full-width row
#'
#' Reads the level dictionary (`dd_f_level`) and lays the categories out
#' horizontally: one column per level code, with an editable meaning beneath
#' each. The meaning row appears only once labels are customised.
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"dd_f_level"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"CATEGORY LABELS"`.
#'
#' @return No return value; prints the table to the RG.
#' @import knitr
#' @export
paste_levels_horizontal <- function( VNAME, LABEL = "CATEGORY LABELS" ){

  info <- get_xx()[[VNAME]]
  if( is.null(info) || is.na(info) || trimws(info) == "" )
  { return( invisible(NULL) ) }
  tab <- json_to_df(info)
  if( nrow(tab) == 0 || ncol(tab) < 2 ) return( invisible(NULL) )

  lvl  <- as.character( tab[[1]] )
  mean <- as.character( tab[[2]] )
  customized <- levels_customized( lvl, mean )

  if( nzchar(trimws(LABEL)) ) cat( "**", LABEL, "**:\n\n", sep = "" )

  # columns = level codes; single row = meaning (blank until customised)
  body <- if( customized ) ifelse( is.na(mean), "", mean ) else rep( "", length(lvl) )
  out  <- as.data.frame( as.list( body ), stringsAsFactors = FALSE, check.names = FALSE )
  names(out) <- lvl
  k <- knitr::kable( out, align = rep("l", ncol(out)) )
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}


###########################################
#### Paste Stats
###########################################

### Numeric ---------
#' Print Statistic of a Numeric Variable into RG
#'
#' Read rg_stats column of DGF and print statistics in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"STATS"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_stats_num <- function( VNAME, LABEL = "STATS" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- get_xx()[[VNAME]]
  tab <- json_to_df(info)

  # The numeric stats table also carries the quantiles; those are shown in a
  # separate QUANTILES section (see paste_quantiles), so exclude them here.
  tab <- tab[ ! tab$STAT %in% c("Q - 05", "Q - 25", "Q - 75", "Q - 95"), ]
  rownames(tab) <- NULL   # drop leaked row indices from the subset

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( tab, align=c("l","r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )

  # return( df )
}


### Numeric quantiles ---------
#' Print the quantiles of a numeric variable into the RG
#'
#' Reads the `rg_stats` column of the DGF and prints just the quantile rows
#' (Q-05, Q-25, Median, Q-75, Q-95) as a QUANTILES table. The remaining
#' summary statistics are shown by [paste_stats_num()].
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"rg_stats"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"QUANTILES"`.
#'
#' @return No return value; prints the QUANTILES table to the RG.
#'
#' @details Internal to \link{create_div} in R/03-01-create-sections.R.
#'
#' @import knitr
#' @export
paste_quantiles <- function( VNAME, LABEL = "QUANTILES" ){

  info <- get_xx()[[VNAME]]
  tab <- json_to_df(info)

  tab <- tab[ tab$STAT %in% c("Q - 05", "Q - 25", "Median", "Q - 75", "Q - 95"), ]
  tab$STAT[ tab$STAT == "Median" ] <- "Q - 50"   # show as a quantile here
  rownames(tab) <- NULL   # drop leaked row indices from the subset

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( tab, align=c("l","r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}


### Numeric combined stats + quantiles ---------
#' Print the combined STATS table (summary + quantiles) into the RG
#'
#' Reads `rg_stats` and prints one table: Minimum, Mean, Maximum, then the
#' quantiles Q-05 / Q-25 / Q-50 / Q-75 / Q-95. Skew and Kurtosis are shown in
#' PROPERTIES (as LOW/MED/HIGH), so they are excluded here. Values are padded so
#' their decimal points line up down the column (see [align_dec()]).
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"rg_stats"`).
#' @param LABEL A character string for the section title. Defaults to `"STATS"`.
#'
#' @return No return value; prints the STATS table to the RG.
#' @import knitr
#' @export
paste_stats_combined <- function( VNAME, LABEL = "STATS" ){

  info <- get_xx()[[VNAME]]
  tab  <- json_to_df(info)
  tab$STAT <- trimws( as.character( tab$STAT ) )

  want <- c("Minimum","Mean","Maximum","Q - 05","Q - 25","Median","Q - 75","Q - 95")
  tab  <- tab[ match( want, tab$STAT ), ]
  tab  <- tab[ ! is.na(tab$STAT), ]
  tab$STAT[ tab$STAT == "Median" ] <- "Q - 50"
  tab$VAL <- align_dec( as.character( tab$VAL ) )
  rownames(tab) <- NULL

  if( nzchar(trimws(LABEL)) ) cat( "**", LABEL, "**:\n\n", sep = "" )
  k <- knitr::kable( tab, align = c("l","r"), col.names = c("STAT","VAL") )
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}


#' Pad a column of formatted numbers so their decimal points align
#'
#' Given already-formatted number strings (commas allowed), pads the fractional
#' side with non-breaking spaces so that, under right alignment in a monospace
#' cell, every decimal point sits in the same column - rows without a decimal
#' get blank placeholders where the fraction would be.
#'
#' @param x A character vector of formatted numbers (e.g. `"29,933"`,
#'   `"362,012.5"`).
#'
#' @return A character vector padded for decimal alignment.
#' @export
align_dec <- function( x ) {
  x    <- as.character( x )
  neg  <- grepl( "^\\s*-", x )
  core <- sub( "^\\s*-?", "", x )
  has  <- grepl( "\\.", core )
  intp <- ifelse( has, sub( "\\..*$", "", core ), core )
  frac <- ifelse( has, sub( "^[^.]*\\.", "", core ), "" )
  fw   <- max( nchar(frac), 0 )
  nb   <- " "                                   # non-breaking space
  fseg <- ifelse( nzchar(frac),
                  paste0( ".", frac, strrep( nb, fw - nchar(frac) ) ),
                  if( fw > 0 ) strrep( nb, fw + 1 ) else "" )
  paste0( ifelse( neg, "-", "" ), intp, fseg )
}


### Numeric stats laid out horizontally ---------
#' Print the numeric STATS transposed across a full-width row
#'
#' Reads `rg_stats` and prints Minimum, the quantiles, Mean and Maximum as a
#' single-row (transposed) table so the summary spreads horizontally across the
#' full width instead of stacking. Skew/Kurtosis live in PROPERTIES.
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"rg_stats"`).
#' @param LABEL A character string for the section title. Defaults to `"STATS"`.
#'
#' @return No return value; prints the STATS row to the RG.
#' @import knitr
#' @export
paste_stats_horizontal <- function( VNAME, LABEL = "STATS" ){

  info <- get_xx()[[VNAME]]
  tab  <- json_to_df(info)
  tab$STAT <- trimws( as.character( tab$STAT ) )

  # source stat name -> short display label, in display order. Skew and Kurtosis
  # are shown here (as actual values) rather than in the PROPERTIES table.
  relabel <- c( "Minimum"  = "MIN",
                "Maximum"  = "MAX",
                "Mean"     = "MEAN",
                "Q - 05"   = "Q05",
                "Q - 25"   = "Q25",
                "Median"   = "Q50",
                "Q - 75"   = "Q75",
                "Q - 95"   = "Q95",
                "Skew"     = "SKEW",
                "Kurtosis" = "KURTOSIS" )
  idx  <- match( names(relabel), tab$STAT )
  keep <- ! is.na(idx)

  # transpose: one value row, short stat labels as column headers
  out <- as.data.frame( as.list( as.character(tab$VAL)[ idx[keep] ] ),
                        stringsAsFactors = FALSE, check.names = FALSE )
  names(out) <- unname( relabel[keep] )

  if( nzchar(trimws(LABEL)) ) cat( "**", LABEL, "**:\n\n", sep = "" )
  k <- knitr::kable( out, align = rep("r", ncol(out)) )
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}

### Character --------
#' Print Statistic of a Character Variable into RG
#'
#' Read rg_stats column of DGF and print statistics in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"STATS"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_stats_chr <- function( VNAME, LABEL = "STATS" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- get_xx()[[VNAME]]
  info.list <- json_to_list(info)
  info.tab <- as.data.frame(do.call(rbind, info.list[[1]]))
  info.hist <- as.data.frame(do.call(rbind, info.list[[2]]))

  # histogram in the table isn't currently working.
  # This is just an extra thing that would be cool if it did work but isn't technically necessary.
  # info.tab[6, ] <- c("Histogram", info.hist$V1[1], info.hist$V1[2])

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( info.tab, align=c("l","r", "r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )

  # return( df )
}



### Character - most common strings --------
#' Print the most common strings of a character variable into the RG
#'
#' Reads the most-common-values component of the character `rg_stats` cell and
#' prints a Value/Frequency table. Prints nothing if that component is not
#' present (e.g. a DGF generated before this element was added).
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"rg_stats"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"MOST COMMON"`.
#'
#' @return No return value; prints the table (or nothing) to the RG.
#' @import knitr
#' @export
paste_stats_chr_common <- function( VNAME, LABEL = "MOST COMMON" ){

  info      <- get_xx()[[VNAME]]
  info.list <- json_to_list(info)
  if( length(info.list) < 3 || is.null(info.list[[3]]) )
  { return( invisible(NULL) ) }

  tab <- as.data.frame( do.call( rbind, info.list[[3]] ) )
  if( nrow(tab) == 0 ) return( invisible(NULL) )
  colnames(tab) <- c("Value", "Frequency")[ seq_len(ncol(tab)) ]

  # Add each value's share of all records as a (%) column. The denominator (total
  # rows) is read from the already-computed PROPERTIES table so no rebuild is
  # needed; if it can't be resolved, fall back to the plain Value/Frequency table.
  n <- suppressWarnings( total_rows_from_properties() )
  if( "Frequency" %in% names(tab) && ! is.na(n) && n > 0 ) {
    freq <- suppressWarnings( as.numeric( as.character( tab$Frequency ) ) )
    tab[["(%)"]] <- paste0( "(", formatC( freq / n * 100, format = "f", digits = 1 ), "%)" )
    align <- c( "l", "r", "r" )
  } else {
    align <- c( "l", "r" )
  }

  cat( paste0( "**", LABEL, "**", ": ", "\n\n" ) )
  k <- knitr::kable( tab, align = align )
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}


# Total row count for the current variable, read from its PROPERTIES table
# (the "Rows" stat). Returns NA when unavailable. Used to turn a raw frequency
# into a share of all records.
total_rows_from_properties <- function() {
  info <- get_xx()[["rg_properties"]]
  if( is.null(info) || length(info) == 0 || is.na(info) || trimws(info) == "" )
  { return( NA_real_ ) }
  props <- json_to_df( info )
  if( ! all( c("STAT","VAL") %in% names(props) ) ) return( NA_real_ )
  val <- props$VAL[ trimws(as.character(props$STAT)) == "Rows" ]
  if( length(val) == 0 ) return( NA_real_ )
  as.numeric( gsub( ",", "", as.character( val[1] ) ) )
}


### Factor --------
#' Print Statistic of a Factor Variable into RG
#'
#' Read rg_stats column of DGF and print statistics in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"STATS"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_stats_fact <- function( VNAME, LABEL = "STATS" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- get_xx()[[VNAME]]
  tab <- json_to_df(info)

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( tab, align=c("l","r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )

  # return( df )
}

#' Print Statistic of a Logical Variable into RG
#'
#' Read rg_stats column of DGF and print statistics in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"STATS"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_stats_log <- function( VNAME, LABEL = "STATS" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- get_xx()[[VNAME]]
  tab <- json_to_df(info)

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( tab, align=c("l","r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )

  # return( df )
}



###########################################
### Paste Preview
###########################################


#' Wrap preview values into a text block
#'
#' Packs example values into lines no wider than `size` characters, separated
#' by `sep`. Any single value longer than `size` is truncated to `size - 3`
#' characters, given a trailing `...`, and placed on its own line.
#'
#' @param x A character vector of values, or a single `;;`-delimited string.
#' @param size Maximum line width, in characters. Defaults to `80`.
#' @param sep Separator placed between values packed onto the same line.
#'   Defaults to `" ;; "`.
#'
#' @return A character vector of wrapped lines.
#' @examples
#' wrap_preview(c("apple", "banana", "cherry"), size = 15)
#' @export
wrap_preview <- function( x, size = 80, sep = " ;; " ) {

  if( length(x) == 1 )
  { x <- stringr::str_split( x, ";;" )[[1]] }
  x <- trimws( x )
  x <- x[ nzchar(x) ]

  lines <- character(0)
  cur   <- ""

  for( val in x ) {
    if( nchar(val) > size ) {
      # long value: flush the current line, then give it its own truncated row
      if( nzchar(cur) ) { lines <- c( lines, cur ); cur <- "" }
      lines <- c( lines, paste0( substr( val, 1, size - 3 ), "..." ) )
    } else {
      candidate <- if( nzchar(cur) ) paste0( cur, sep, val ) else val
      if( nchar(candidate) > size ) {
        lines <- c( lines, cur )   # would overflow the line: start a new one
        cur   <- val
      } else {
        cur <- candidate
      }
    }
  }
  if( nzchar(cur) ) lines <- c( lines, cur )
  lines
}


# internal: render the rg_preview values as a wrapped monospace text block.
# An empty LABEL prints just the block (the standard template puts the label in
# its own cell). At most `max.lines` wrapped rows are shown so the preview stays
# a compact 3-4 line strip.
paste_preview_block <- function( VNAME, LABEL = "PREVIEW", size = 68,
                                 max.vals = 200, max.lines = 4 ) {

  info <- get_xx()[[VNAME]]
  vals <- unique( trimws( stringr::str_split( info, ";;" )[[1]] ) )
  vals <- vals[ nzchar(vals) ]
  if( length(vals) > max.vals ) vals <- vals[ seq_len(max.vals) ]

  # values are stored ";;"-delimited but displayed separated by a middle dot
  lines <- wrap_preview( vals, size = size, sep = " · " )
  if( length(lines) > max.lines ) lines <- lines[ seq_len(max.lines) ]

  # escape HTML-special characters so arbitrary values render safely in <pre>
  esc <- function(s) {
    s <- gsub( "&", "&amp;", s )
    s <- gsub( "<", "&lt;",  s )
    gsub( ">", "&gt;",  s )
  }

  if( nzchar(trimws(LABEL)) ) cat( "**", LABEL, "**:\n\n", sep = "" )
  cat( '<pre class="dg-preview">\n' )
  cat( esc(lines), sep = "\n" )
  cat( "\n</pre>\n\n" )
}


#' Print just a section label (no content) into the RG
#'
#' Used by the standard layout to place a section's label in its own left-hand
#' cell (e.g. the PREVIEW label beside a full-width data preview).
#'
#' @param VNAME Ignored; present for a uniform layout-function signature.
#' @param LABEL A character string for the label. Defaults to `"PREVIEW"`.
#'
#' @return No return value; prints the label to the RG.
#' @export
paste_label <- function( VNAME, LABEL = "PREVIEW" ){
  if( nzchar(trimws(LABEL)) ) cat( "**", LABEL, "**:\n\n", sep = "" )
}


### Numeric --------------------------
#' Print Preview of a Numeric Variable into RG
#'
#' Reads the rg_preview column of the DGF and prints the example values as a
#' wrapped text block (see [wrap_preview()]).
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"rg_preview"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"PREVIEW"`.
#' @param size Maximum line width, in characters. Defaults to `80`.
#'
#' @return No return value; prints the preview block to the RG.
#'
#' @details
#' Internal to `create_div` in R/03-01-create-sections.R.
#'
#' @export
paste_preview_num  <- function( VNAME, LABEL = "PREVIEW", size = 68 ){
  paste_preview_block( VNAME, LABEL, size = size )
}


### Character -----------------------------
#' Print Preview of a Character Variable into RG
#'
#' Reads the rg_preview column of the DGF and prints the example values as a
#' wrapped text block (see [wrap_preview()]).
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"rg_preview"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"PREVIEW"`.
#' @param size Maximum line width, in characters. Defaults to `80`.
#'
#' @return No return value; prints the preview block to the RG.
#'
#' @details
#' Internal to `create_div` in R/03-01-create-sections.R.
#'
#' @export
paste_preview_chr <- function( VNAME, LABEL = "PREVIEW", size = 68 ){
  paste_preview_block( VNAME, LABEL, size = size )
}

