#############################
### Get_properties (for all data types)
##############################

#' Generate Table of Properties
#'
#' Generates needed properties for rg_properties column of the DGF. Used inside R/01-00-CREATE-DGF.R
#'
#' @param VNAME A character string specifying the name of the variable in the data frame. (From vname column of the DGF)
#' @param df A data frame containing the variable to be visualized.
#'
#' @return Data table as JSON text string needed to store in the DGF to later generate the properties table when rendering the RG.
#'
#' @details
#' properties include number of rows and distinct values, most common value,
#' number of zero, empty cells, missing/NA cells, and cell with infinite values
#'
#'
#' @export
get_properties <- function( VNAME, df ){

  x <- unlist( df[[VNAME]] )
  n <- length(x)
  is.num <- is.numeric(x)
  chr <- as.character(x)

  # format as an integer with thousands separators; use a double (format "f",
  # 0 digits) so values above the 32-bit integer range don't overflow to NA.
  comma <- function(v) formatC( as.numeric(v), big.mark = ",", format = "f", digits = 0 )
  # All percentages carry exactly one decimal so the decimal point lines up
  # when scanning the column (e.g. "13.0%" over "79.7%").
  pct   <- function(v) paste0( "(", formatC( v / n * 100, format = "f", digits = 1 ), "%)" )

  ## exhaustive, mutually-comparable missingness checks
  na.count    <- sum( is.na(x) )                                  # NA / NaN
  empty.count <- sum( ! is.na(x) & ( trimws(chr) == "" | chr == "." ) )
  zero.count  <- if( is.num ) sum( x == 0, na.rm = TRUE ) else 0L
  inf.count   <- if( is.num ) sum( is.infinite(x) )        else 0L

  ## assemble rows in order; include a missingness row only when it occurs.
  ## (The most common value is shown in the separate MOST COMMON VALUES table,
  ## so it is intentionally omitted here.)
  rows <- list(
    c( "Rows",     comma(n),                    "" ),
    c( "Distinct", comma( length(unique(x)) ),  pct( length(unique(x)) ) )
  )
  if( na.count    > 0 ) rows <- c( rows, list(c("Missing/NA",    comma(na.count),    pct(na.count)   )) )
  if( empty.count > 0 ) rows <- c( rows, list(c("Missing/Empty", comma(empty.count), pct(empty.count))) )
  if( zero.count  > 0 ) rows <- c( rows, list(c("Zero",          comma(zero.count),  pct(zero.count) )) )
  if( inf.count   > 0 ) rows <- c( rows, list(c("Infinite",      comma(inf.count),   pct(inf.count)  )) )

  # Skew and Kurtosis are intentionally NOT in the properties table - they are
  # shown (as actual values) in the numeric STATS section instead.

  tab <- as.data.frame( do.call( rbind, rows ), stringsAsFactors = FALSE )
  names(tab) <- c( "STAT", "VAL", "PER" )

  jsonify_df( tab )
}


#' Most common value
#'
#' Internal function for \link{get_properties} to find most common value.
#'
#' @param x vector
#'
#' @return most common value in `x`
#'
#' @details
#' internal function for \link{get_properties}
#'
#' @keywords internal
most_common_val <- function(x) {
  x <- c(x)
  # Count every distinct value, including NA, and return the most frequent
  # one as a character string (NA can legitimately be the most common value).
  counts <- table(x, useNA = "ifany")
  if (length(counts) == 0) return(NA_character_)
  counts <- sort(counts, decreasing = TRUE)
  return(as.character(names(counts)[1]))
}





##############################
### Functions called to paste rg_stats into DGF
###############################

#' Generate Statistics Based on Variable Type
#'
#' Generates needed graphics for rg_stats column of the DGF. Used inside R/01-00-CREATE-DGF.R
#'
#' @param VNAME A character string specifying the name of the variable in the data frame. (From vname column of the DGF)
#' @param df A data frame containing the variable to be visualized.
#' @param VCLASS A character string indicating the class of the variable (e.g., "numeric", "factor", "logical", or other).
#'
#' @return Data table as JSON text string needed to store in the DGF to later generate the appropriate plot when rendering the RG.
#'
#' @details
#' The function calls different helper functions based on `VCLASS`:
#' \itemize{
#'   \item `"numeric"`: Calls `get_graphics_num(VNAME, df)`
#'   \item `"factor"`: Calls `get_graphics_fact(VNAME, df)`
#'   \item `"logical"`: Calls `get_graphics_log(VNAME, df)`
#'   \item Other classes: Calls `get_graphics_chr(VNAME, df)`
#' }
#' @export
get_stats <- function(VNAME, df, VCLASS){

  if(VCLASS == "numeric"){
    return(get_stats_num(VNAME,df))
  }else if(VCLASS == "factor"){
    return(get_stats_fact(VNAME,df))
  }else if(VCLASS == "logical"){
    return(get_stats_log(VNAME,df))
  }else(
    return(get_stats_chr(VNAME,df))
  )
}



### Character ---------------------------

#' Summary statistics for a character variable (internal)
#'
#' Free text has no meaningful numeric distribution, so this profiles the
#' *shape* of the strings instead: how long they are, in characters and in
#' words.
#'
#' @param VNAME Character; the variable name (a column of `df`).
#' @param df The dataset being profiled.
#'
#' @return A JSON string: minimum, median, mean, max and skew, reported in
#'   parallel for character count and word count. Stored in the DGF's
#'   `rg_stats` column and read back by [paste_stats_chr()].
#' @noRd
get_stats_chr <-  function(VNAME, df){

  x <- unlist(df[[VNAME]])

  #number of characters
  n <- nchar(x)
  n <- n[!is.na(n)] #remove NA

  #number of spaces
  spaces <- stringr::str_count(x, "[:blank:]") + 1
  spaces <- spaces[!is.na(spaces)] #remove NA

  tab <-
    data.frame(STAT =  c( "Minimum", "Median",  "Mean", "Max", "Skew"),
               CHARACTERS = round(c(min(n, na.rm = TRUE),
                                    median(n, na.rm = TRUE),
                                    mean(n, na.rm = TRUE),
                                    max(n, na.rm = TRUE),
                                    psych::skew(n)), 2),
               WORDS = round(c(min(spaces, na.rm = TRUE),
                               median(spaces, na.rm = TRUE),
                               mean(spaces, na.rm = TRUE),
                               max(spaces, na.rm = TRUE),
                               psych::skew(spaces)), 2))

  ## Testing histogram in table - isn't saving as JSON object properly - can add back in later
  #
  ## top-6 full strings by frequency (for the MOST COMMON table). Words are
  ## atomised for the word cloud, so the whole strings are tabulated here.
  xc <- as.character(x)
  xc <- xc[ !is.na(xc) & trimws(xc) != "" & xc != "." ]
  tt <- sort( table(xc), decreasing = TRUE )
  k  <- seq_len( min(6, length(tt)) )
  common <- data.frame( Value     = names(tt)[k],
                        Frequency = as.integer(tt)[k],
                        stringsAsFactors = FALSE )

  data_list <- list(
    STATS = tab,
    HIST = list(htmltools::HTML(kableExtra::spec_hist(n)$svg_text), htmltools::HTML(kableExtra::spec_hist(spaces)$svg_text)),
    COMMON = common
  )

  #return tab as json object
  ret <- jsonlite::toJSON(data_list, pretty = TRUE, auto_unbox = TRUE)

  return(ret)


}


### Logical ------------------------

#' Summary statistics for a logical variable (internal)
#'
#' Tabulates the frequency of each of the two values, counting `NA` as its own
#' category so missingness is reported rather than dropped.
#'
#' @param VNAME Character; the variable name (a column of `df`).
#' @param df The dataset being profiled.
#'
#' @return A JSON string: a Value/Frequency table, stored in the DGF's
#'   `rg_stats` column and read back by [paste_stats_log()].
#'
#' @details Duplicates the tabulation [get_graphics_log()] performs; the two
#'   could share one pass over the column.
#' @noRd
get_stats_log <-  function(VNAME, df){

  f <- as.character(df[[VNAME]])

  f[ is.na(f) ] <- "NA"
  tab <- as.data.frame(table( f ))
  colnames(tab) <- c("Value", "Frequency")


  ret <- jsonify_df(tab)
  return(ret)




}



### Factor ------------------------

#' Summary statistics for a factor variable (internal)
#'
#' Tabulates level frequencies in descending order, capped at the 50 most
#' common, so a high-cardinality factor cannot flood the report.
#'
#' @param VNAME Character; the variable name (a column of `df`).
#' @param df The dataset being profiled.
#'
#' @return A JSON string: a Value/Frequency table, stored in the DGF's
#'   `rg_stats` column. The render pairs it with the editable labels in
#'   `dd_f_level` to build the level | frequency | meaning table.
#' @noRd
get_stats_fact <-  function(VNAME, df){

  x <- df[[VNAME]]

  # Store the level frequencies (descending), capped at 50, so the render can
  # build the combined FACTOR LEVELS table (level | frequency | meaning).
  tab <- sort( table(x), decreasing = TRUE )
  if( length(tab) > 50 ) tab <- tab[ seq_len(50) ]
  tab <- data.frame(tab)
  colnames(tab) <- c("Value", "Frequency")


  #return tab as json object
  ret <- jsonify_df(tab)
  return(ret)

}


### Numeric ----------------------------
#' Summary statistics for a numeric variable (internal)
#'
#' Builds the quantile and shape table shown in the report's STATS block.
#'
#' @param VNAME Character; the variable name (a column of `df`).
#' @param df The dataset being profiled.
#'
#' @return A JSON string: minimum, the 5th/25th/50th/75th/95th percentiles,
#'   mean, maximum, skew and kurtosis. Stored in the DGF's `rg_stats` column
#'   and read back by [paste_stats_num()] and [paste_quantiles()].
#' @noRd
get_stats_num <- function( VNAME, df ){

  x <- df[[VNAME]]

  tab <- data.frame(
    STAT = c("Minimum", "Q - 05", "Q - 25", "Median", "Mean",
             "Q - 75", "Q - 95", "Maximum", "Skew", "Kurtosis"),
    VAL = c(min(x, na.rm = TRUE),
            quantile( x, probs=0.05, na.rm=T, names=F ),
            quantile( x, probs=0.25, na.rm=T, names=F ),
            quantile( x, probs=0.50, na.rm=T, names=F ),
            mean(x, na.rm = T),
            quantile( x, probs=0.75, na.rm=T, names=F ),
            quantile( x, probs=0.95, na.rm=T, names=F ),
            max(x, na.rm = TRUE),
            psych::skew(x),
            psych::kurtosi(x))
  )

  tab$VAL <- round(tab$VAL , 2)
  f <- function(x){ format(x,big.mark=",") }
  tab$VAL <- sapply( tab$VAL, f )

  ret <- jsonify_df(tab)
  return(ret)

}



############################
### Required Internal Functions
#############################


#' Serialize a named list of statistics to indented JSON (internal)
#'
#' @param df A named list or data frame of statistics.
#'
#' @return A JSON string, line-broken and indented so the cell stays legible
#'   when a curator opens the DGF in Excel.
#'
#' @details The gsub chain is purely cosmetic whitespace - it only shapes how
#'   the JSON reads in a spreadsheet cell. Use [jsonify_df()] for rectangular
#'   tables, which get a different layout.
#' @seealso [json_to_list()], which reads these back at render time.
#' @noRd
jsonify_stats <- function( df ) {
  jd <- jsonlite::toJSON( df )
  jd <- gsub( ",", ", \n    ", jd )
  jd <- gsub( "\\{", "  \\{ \n    ", jd )
  jd <- gsub( ":", "  :  ", jd )
  jd <- gsub( '","', '",  "', jd )
  jd <- gsub( "\\}", "\n  \\}", jd )
  jd <- gsub( "\\[", "\\[ \n", jd )
  jd <- gsub( "\\]", "\n\\]", jd )
  return(jd)
}

#' Serialize a data frame to indented JSON (internal)
#'
#' @param df A data frame, typically a two-column value/frequency table.
#'
#' @return A JSON string with one record per line, so the cell stays legible
#'   when a curator opens the DGF in Excel.
#'
#' @details The gsub chain is purely cosmetic whitespace. Use [jsonify_stats()]
#'   for a flat named list of scalars.
#' @seealso [json_to_df()], which reads these back at render time.
#' @noRd
jsonify_df <- function( df )
{
  jd <- jsonlite::toJSON( df )
  jd <- gsub( "\\{", "  \\{  ", jd )
  jd <- gsub( ":", " :  ", jd )
  jd <- gsub( '",', '"  ,  ', jd )
  jd <- gsub( '","', '",  "', jd )
  jd <- gsub( "\\},", "  \\}, \n", jd )
  jd <- gsub( "\\[", "\\[ \n", jd )
  jd <- gsub( "\\]", "\n\\]", jd )
  jd <- gsub( "\\}\n", "  \\}\n", jd )
  return(jd)
}





##################################
### Get_example functions
###################################
#' Example values for a variable's preview block (internal)
#'
#' Collects the variable's most frequent values into one delimited block for
#' the report's PREVIEW section.
#'
#' @param VNAME Character; the variable name (a column of `df`).
#' @param df The dataset being profiled (already display-formatted, so the
#'   preview shows values as a reader will see them).
#'
#' @return A single `" ;; "`-delimited string, stored in the DGF's `rg_preview`
#'   column and read back by [paste_preview_num()] / [paste_preview_chr()].
#'
#' @details Values are truncated to 48 characters each and the block to 400,
#'   which is what keeps a long free-text field from overflowing its cell.
#'   Not used for logical or factor variables - those show a level table.
#' @noRd
get_examples <- function(VNAME, df){

  x <- df[[VNAME]] #this should be the input data set

  if( max(nchar(as.character(x)),na.rm=T) > 48 )
  { x <- purrr::map_chr( x, function(x){ substr(x,1,48) } ) }

  t <- table( x ) |> sort( d=T )
  txt <- paste0( names(t[1:min(length(t), 2000)]), collapse=" ;; " )
  BLOCK <- substr( txt,   1, 400 ) |> trimws()
  BLOCK <- gsub( " ?;{1,2} ?$", "", BLOCK )
  return( BLOCK )

}



