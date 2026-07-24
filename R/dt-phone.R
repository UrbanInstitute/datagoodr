##############################
### Data type family: phone numbers
###############################
## US/NANP phone numbers, +-prefixed international numbers, and bare MSISDN
## subscriber numbers. Phone formats are loose by nature; these accept the
## common separators.


#' Is it a US / NANP phone number?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for common US formats such as `510-577-3201`,
#'   `(309) 647-1820`, `1-650-384-9911`, `650 231 1123`.
#' @examples
#' is_phone(c("(309) 647-1820", "510-577-3201", "12345", NA))
#' @family phone detectors
#' @export
is_phone <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^(\\+?1[-. ]?)?(\\(\\d{3}\\)[-. ]?|\\d{3}[-. ]?)",
                      "\\d{3}[-. ]?\\d{4}$"), x)
  out[is.na(x)] <- NA
  out
}

#' Is it an international (+ prefixed) phone number?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a `+`-prefixed number with 8-15 digits
#'   and common separators/parentheses.
#' @examples
#' is_intl_phone(c("+1-4250013981", "+61 3 6216 0864", "4250013981", NA))
#' @family phone detectors
#' @export
is_intl_phone <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\+\\d{1,3}[0-9 ().-]{6,18}$", x)
  ndig <- nchar(gsub("[^0-9]", "", x))
  out <- ok & ndig >= 8 & ndig <= 15
  out[is.na(x)] <- NA
  out
}

#' Is it an MSISDN (mobile subscriber number)?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a bare 10-15 digit MSISDN.
#' @details Loose by construction: any 10-15 digit run matches. Best used with
#'   a variable-name hint.
#' @examples
#' is_msisdn(c("919961345678", "13109976224", "12345", NA))
#' @family phone detectors
#' @export
is_msisdn <- function(x) {
  x <- as.character(x)
  out <- grepl("^\\d{10,15}$", x)
  out[is.na(x)] <- NA
  out
}
