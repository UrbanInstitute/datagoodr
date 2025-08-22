# library( dplyr )

# path <- "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/datagood"
# setwd( path )


#' Format values as 9-digit EINs (internal)
#'
#' Converts a numeric or character value to a 9-digit string by left-padding
#' with zeros. Returns `NA` unchanged.
#'
#' @param x A numeric or character value representing an EIN.
#'
#' @return A character string of length 9, padded with leading zeros if needed,
#'   or `NA` if the input is missing.
#'
#' @keywords internal
#' @noRd
as_EIN <- function(x){
  if(is.na(x)){
    return(x)}
  else{
    x %>%
    stringr::str_pad(9, side="left", pad="0" ) %>%
    return()}
}

#' Pad numeric or character values to two digits (internal)
#'
#' Converts a numeric or character value into a two-character string by
#' left-padding with zeros. Returns `NA` unchanged.
#'
#' @param x A numeric or character value to be padded.
#'
#' @return A character string of length 2, padded with a leading zero if needed,
#'   or `NA` if the input is missing.
#'
#' @keywords internal
#' @noRd
as_mm <- function(x) {
  if(is.na(x)){
    return(x)}
  else{
  x <- x %>%
    stringr::str_pad( 2, side="left", pad="0" )
  return(x)}
}


#' Format values as 4-digit years (internal)
#'
#' Converts a numeric or character value into a character string representing a
#' year. Returns `NA` unchanged and warns if any element has more than 4
#' characters.
#'
#' @param x A numeric or character value representing a year.
#'
#' @return A character string representing the year, or `NA` if the input is
#'   missing.
#'
#' @keywords internal
#' @noRd
as_yyyy <- function(x) {
  if(is.na(x)){
    return(x)}
  else{
    x <- as.character(x)
  if( max(nchar(x)) > 4 )
  { warning( "YYYY elements have nchar > 4" ) }
  return(x)}
}


#' Convert values to "YYYY-MM" format (internal)
#'
#' Converts a numeric or character value representing year and month into a
#' string formatted as `"YYYY-MM"`. Returns `NA` unchanged.
#'
#' @param x A numeric or character value in the form `YYYYMM`.
#'
#' @return A character string in `"YYYY-MM"` format, or `NA` if the input is
#'   missing.
#'
#' @keywords internal
#' @noRd
as_yyyymm <- function(x) {
  if(is.na(x)){
    return(x)}
  else{x <- as.character(x)
  yyyy <- substr( x, 1, 4 )
  mm <- substr( x, 5, 6 )
  yyyymm <- paste0( yyyy, "-", mm )
  return(yyyymm)}
}
