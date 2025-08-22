# library( dplyr )

# path <- "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/datagood"
# setwd( path )

#' Pad numeric or character values to two digits (internal)
#'
#' Converts a numeric or character vector into two-character strings by
#' left-padding with zeros as needed. Useful for formatting months or other
#' two-digit codes.
#'
#' @param x A numeric or character vector to be padded.
#'
#' @return A character vector where each element has at least two characters,
#'   padded with leading zeros if necessary.
#'
#' @keywords internal
#' @noRd
as_mm <- function(x) {
  x <- x %>%
    stringr::str_pad( 2, side="left", pad="0" )
  return(x)
}

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

#' Load the Data Guide File (DGF) (internal)
#'
#' Reads the "DGF" sheet from an Excel file and returns it as a data frame.
#'
#' @param filename Character string specifying the path to the Excel file.
#'   Defaults to `"DGF.xlsx"`.
#'
#' @return A `data.frame` containing the contents of the "DGF" sheet.
#'
#' @keywords internal
#' @noRd
load_dgf <- function( filename="DGF.xlsx" )
{
  dgf <-
    openxlsx::read.xlsx(
      xlsxFile=filename,
      sheet="DGF" )
  return(dgf)
}
#
# fn <- "DGF-CORE-CO-2019.xlsx"
# dgf <- load_dgf( fn )
#
# d2 <- load_dgf( )


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

# rules <- get_convert_rules( wb )

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

# fake_fx <- function(x){ return(x) }
#
# rules1 <- c("as.numeric","as.character","fake_fx","as_mm","as_yy")
# rules2 <- c("as.numeric","as.character","fake_fx")
#
# is_function( rules )
# is_function( rules2 )


#' Validate JSON strings (internal)
#'
#' Checks whether each element of a character vector is valid JSON.
#'
#' @param v A character vector containing JSON strings to validate.
#'
#' @return A logical vector indicating whether each element is valid JSON
#'   (`TRUE`) or not (`FALSE`).
#'
#' @keywords internal
#' @noRd
validate_json <- function(v)
{
  is.valid <- sapply( v, jsonlite::validate, USE.NAMES=F )
  return( is.valid )
}
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

# x <- check_json( dgf )

# if( ! is.null(x) )
# { lapply( x, get_json_error ) }
#

#' Retrieve JSON parsing error message (internal)
#'
#' Returns the error message from `jsonlite::validate()` if a JSON string is
#' invalid.
#'
#' @param x A single JSON string to check.
#'
#' @return A character string containing the error message if the JSON is
#'   invalid, or `NULL` if the JSON is valid.
#'
#' @keywords internal
#' @noRd
get_json_error <- function(x)
{
  r <- jsonlite::validate(x)
  error.message <- attr( r, "err" )
  return( error.message )
}

# lapply( x, get_json_error )



#' Display invalid JSON strings and their errors (internal)
#'
#' Prints error messages for each invalid JSON string in a vector, followed by
#' the offending string itself.
#'
#' @param v A character vector of JSON strings to check.
#'
#' @return Invisibly returns `NULL`.
#'
#' @keywords internal
#' @noRd
show_invalid <- function(v)
{
  not.valid <- ! validate_json(v)
  nv <- v[ not.valid ]
  show_problem <- function(x)
  { print(get_json_error(x)); cat(paste0(x,"\n\n")) }
  sapply( nv, show_problem, USE.NAMES=F )
  return(invisible(NULL))
}

# lapply( x, show_invalid )
#
#
#
# sapply( rules, find )
#
# c("as.character()", "as_mm()", "as.factor()", NA, "as.numeric()",
# "as_yyyy()", "as_yyyymm()")
#
#
# as.factor()
#
#
# dput( unique( d$dgf_raw_convert ) )
# c("as.character()", "as_mm()", "as.factor()", NA, "as.numeric()",
# "as_yyyy()", "as_yyyymm()")
