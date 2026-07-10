# Value-formatting helpers referenced from a DGF's `vconvert` / `vformat`
# columns. Each is applied element-wise to a single value, so they accept and
# return length-1 inputs and pass NA through unchanged. These are the built-in
# counterparts to user-supplied "polishing" functions such as dollarize().


#' Format a value as a zero-padded 9-digit EIN
#'
#' Left-pads an Employer Identification Number to nine digits with leading
#' zeros. `NA` is returned unchanged.
#'
#' @param x A single EIN value (numeric or character).
#'
#' @return A 9-character EIN string, or `NA` if `x` is `NA`.
#' @seealso [as_mm()], [as_yyyy()], [as_yyyymm()]
#' @export
#' @importFrom stringr str_pad
as_EIN <- function(x) {
  if (is.na(x)) return(x)
  stringr::str_pad(x, 9, side = "left", pad = "0")
}


#' Format a value as a zero-padded two-digit month
#'
#' Left-pads a month number to two digits (e.g. `8` becomes `"08"`). `NA` is
#' returned unchanged.
#'
#' @param x A single month value (numeric or character).
#'
#' @return A 2-character month string, or `NA` if `x` is `NA`.
#' @seealso [as_EIN()], [as_yyyy()], [as_yyyymm()]
#' @export
#' @importFrom stringr str_pad
as_mm <- function(x) {
  if (is.na(x)) return(x)
  stringr::str_pad(x, 2, side = "left", pad = "0")
}


#' Format a value as a four-digit year
#'
#' Coerces a year to character, warning if it has more than four digits. `NA`
#' is returned unchanged.
#'
#' @param x A single year value (numeric or character).
#'
#' @return The year as a character string, or `NA` if `x` is `NA`.
#' @seealso [as_mm()], [as_yyyymm()]
#' @export
as_yyyy <- function(x) {
  if (is.na(x)) return(x)
  x <- as.character(x)
  if (max(nchar(x)) > 4) warning("YYYY elements have nchar > 4")
  x
}


#' Format a YYYYMM value as "YYYY-MM"
#'
#' Splits a six-character `YYYYMM` value into a hyphenated `"YYYY-MM"` string.
#' `NA` is returned unchanged.
#'
#' @param x A single `YYYYMM` value (numeric or character).
#'
#' @return A `"YYYY-MM"` character string, or `NA` if `x` is `NA`.
#' @seealso [as_yyyy()], [as_mm()]
#' @export
as_yyyymm <- function(x) {
  if (is.na(x)) return(x)
  x <- as.character(x)
  paste0(substr(x, 1, 4), "-", substr(x, 5, 6))
}
