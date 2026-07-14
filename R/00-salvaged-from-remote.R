# ---------------------------------------------------------------------------
# Salvaged from origin/main (tag v0.0.0-dev, the pre-reconciliation remote).
#
# These functions existed only on the remote branch and had no local
# equivalent. They are collected here (rather than in their original remote
# files, which otherwise duplicated our own functions) so nothing committed
# to the remote is lost. Some may currently be unused - they may support
# pipeline steps not yet implemented locally. Revisit in a cleanup sweep and
# either wire them in or drop the ones that are truly orphaned.
# ---------------------------------------------------------------------------

### check_json()  --  from R/02-01-ingest-raw-utils.R @ origin/main
#' Check JSON validity in DGF factor levels (internal)
#'
#' Validates the JSON strings stored in the `dgf_f_levels` column of a data
#' guide file (DGF) and identifies any invalid entries.
#'
#' @param dgf A `data.frame` containing the DGF, with a column
#'   `dgf_f_levels` containing JSON strings.
#'
#' @return `NULL` if all JSON strings are valid; otherwise, returns a character
#'   vector of invalid JSON entries.
#'
#' @keywords internal
#' @noRd
check_json <- function( dgf ) {

  v <- dgf$dgf_f_levels
  v <- drop_empty( v )
  x <- validate_json( v )

  if( all(x) )
  { return(NULL) }

  return( v[!x] ) # invalid cases
}


### drop_empty()  --  from R/02-01-ingest-raw-utils.R @ origin/main
#' Remove missing or empty elements from a vector (internal)
#'
#' Filters out `NA` values and empty strings (`""`) from a vector.
#'
#' @param x A vector to clean.
#'
#' @return A vector with all `NA` values and empty strings removed.
#'
#' @keywords internal
#' @noRd
drop_empty <- function(x) {
  x <- x[ ! is.na(x) ]
  x <- x[ x != "" ]
  return(x)
}


### get_convert_rules()  --  from R/02-01-ingest-raw-utils.R @ origin/main
#' Extract conversion rules from the DGF (internal)
#'
#' Retrieves the unique, non-missing raw conversion rules from a data guide file
#' (DGF) and removes any trailing parentheses from function names.
#'
#' @param dgf A `data.frame` containing the data guide file. Must include the
#'   column `dgf_raw_convert`.
#'
#' @return A character vector of unique conversion rule names, with parentheses
#'   removed.
#'
#' @keywords internal
#' @noRd
get_convert_rules <- function( dgf ) {

  rules <-
    dgf$dgf_raw_convert %>%
    na.omit() %>%
    unique()

  rules <-
    gsub( "\\(\\)", "", rules )

  return( rules )
}


### is_function()  --  from R/02-01-ingest-raw-utils.R @ origin/main
#' Check if conversion rules are defined as functions (internal)
#'
#' Verifies that each entry in a vector of rule names corresponds to an existing
#' function in the R environment. Prints messages indicating any missing
#' functions or confirming that all functions exist.
#'
#' @param rules A character vector of function names to check.
#'
#' @return Invisibly returns a character vector of missing function names if
#'   any are not defined; otherwise, returns `NULL`.
#'
#' @keywords internal
#' @noRd
is_function <- function( rules ) {

  fx <-
    rules %>%
    sapply( find )

  missing <-
    names(fx)[ as.character(fx) == "character(0)" ]

  if( length(missing) > 0 )
  {
    cat( "\nThe following functions \n" )
    cat( "are not defined: \n\n" )
    cat( paste0( " - ", missing, "()", collapse="\n" ) )
    cat( "\n\nAdd them to 'dgf.R'\n\n" )
    return( invisible( missing ) )
  }

  cat( "\nAll import rules are valid functions.\n\n" )

}


### customize_template()  --  from R/05-build-functions.R @ origin/main
#' Copy and open a Quarto template for customization (internal)
#'
#' Copies a Quarto template from the package to a specified working directory
#' and opens it for editing.
#'
#' @param template Character string specifying the template file name. Defaults
#'   to `"rg.qmd"`.
#' @param wd Character string specifying the working directory to copy the
#'   template to. Defaults to the current working directory.
#'
#' @return Invisibly returns `NULL`.
#'
#' @keywords internal
#' @noRd
customize_template <- function( template="rg.qmd", wd=NULL ) {

  # lib.path <- (.libPaths())[1]
  # pkg.path <- paste0( lib.path, "/", "datagood" )

  # online template?
  # download.file(
  #   url = URL,
  #   destfile = "./custom.qmd" )

  if( is.null(wd) ){ wd <- getwd() }
  qmd.path <- system.file( "qmd", template, package = "datagood" )
  file.copy( from=qmd.path, to=wd, overwrite=FALSE )

  filepath <- paste0( wd, "/", template )
  shell( filepath )
}


### is_missing()  --  from R/01-03-get-stats.R @ origin/main
#' Check missing data
#'
#' internal function for get_properties to return amount of missing data
#'
#' @param x vector
#'
#' @return number of missing values in `x`
#'
#' @details
#' internal function for \link{get_properties}
#'
#' @keywords internal
is_missing <- function(x) {
  v1 <- is.na(x)
  v2 <- is.nan(x)
  v3 <- is.infinite(x)
  v4 <- grepl( "^[ ]{0,}$", x )
  v5 <- x == "NA"
  v6 <- x == "."
  missing <- v1 | v2 | v3 | v4 | v5 | v6
  return( sum( missing, na.rm=T ) )
}


### make3()  --  from R/03-02-histogram.R @ origin/main
# FORMAT NUMBER LABELS
# SO THEY ARE ALWAYS A
# UNIFORM WIDTH FOR GRAPHS
#' Format numbers into human-readable strings for graphing
#'
#' Converts numeric values into rounded or abbreviated strings, using K/M/B/T
#' suffixes for thousands, millions, billions, and trillions.
#'
#' @param x A numeric value to format.
#'
#' @return A character string representing the formatted number.
#'
#' @details
#' - Negative numbers are rounded to 3 decimal places.
#' - Numbers between 0 and 10 are rounded to 2 decimal places.
#' - Numbers between 10 and 100 are rounded to 1 decimal place.
#' - Numbers in the thousands, millions, billions, and trillions are
#'   abbreviated with `K`, `M`, `B`, or `T`.
#' - Numbers ≥ 10^15 are returned as `"BFN"`.
#'
#' @keywords internal
#' @noRd
make3 <- function(x){
  # need to fix for
  # large negative nums
  if( x < 0 ){
    x <- paste0( round(x,3) )
    return(x)
  }
  if( x >= 0 & x < 10 ){
    x <- paste0( round(x,2)  )
    return(x)
  }
  if( x >= 10 & x < 100 ){
    x <- paste0( round(x,1)  )
    return(x)
  }
  if( x > 10^2 & x < 10^6 ){
    x <- paste0( round(x/(10^3),0), "K" )
    return(x)
  }
  if( x >= 10^6 & x < 10^9 ){
    x <- paste0( round(x/(10^6),0), "M" )
    return(x)
  }
  if( x >= 10^9 & x < 10^12 ){
    x <- paste0( round(x/(10^9),0), "B" )
    return(x)
  }
  if( x >= 10^12 & x < 10^15 ){
    x <- paste0( round(x/(10^12),0), "T" )
    return(x)
  }
  if( x >= 10^15 ){
    x <- "BFN"
    return(x)
  }
}


### trim_txt_block()  --  from R/03-00-BUILD-RG-DICT.R @ origin/main
## function to trim a text block to the first 48 characters
#' Trim and summarize a delimited text block
#'
#' Splits a text string on `;;`, trims whitespace,
#' truncates long values, and constructs a condensed summary block.
#'
#' @param x A character string, typically containing values separated by `;;`.
#'
#' @return A single character string (`BLOCK`) that represents a condensed
#'   summary of the most frequent values in `x`. The output is truncated to
#'   400 characters.
#'
#' @details
#' - The input string is split on `;;` and each piece is trimmed.
#' - Values longer than 48 characters are truncated.
#' - A frequency table of values is constructed, and the most common values
#'   are joined back together with `;;`.
#' - At most 200 values are included, and the result is truncated to 400
#'   characters.
#'
#' @keywords internal
#' @noRd
trim_txt_block <- function( x ){

  x <- stringr::str_split(x, ";;", simplify = FALSE)[[1]]
  x <- x |> trimws()

  if( max(nchar(as.character(x)),na.rm=T) > 48 )
  { x <- purrr::map_chr( x, function(x){ substr(x,1,48) } ) }

  t <- table( x ) |> sort( d=T )
  n <- length(t)
  max.n <- min(length(x) , 200)


  txt <- paste0( names(t)[1:max.n], collapse=" ;; " )
  BLOCK <- substr( txt,   1, 400 ) |> trimws()
  BLOCK <- gsub( " ?;{1,2} ?$", "", BLOCK )
  return( BLOCK )
}


