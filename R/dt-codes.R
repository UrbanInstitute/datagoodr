##############################
### Data type family: simple codes / lookups
###############################
## Detectors for roman numerals, HTTP status, unix time, US ZIP, UK and
## Canadian postal codes, US state, and ISO country code. The two large
## lookups reference package data rather than inline lists: US states use base
## R `datasets::state.abb`; ISO country codes use the internal `.iso3166_alpha2`
## table built by data-raw/build_lookups.R into sysdata.rda.


#' Is it a Roman numeral?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a well-formed uppercase Roman numeral.
#' @examples
#' is_roman(c("XIV", "MMXXIV", "IIII", "", NA))
#' @family code detectors
#' @export
is_roman <- function(x) {
  x <- as.character(x)
  out <- nzchar(x) &
    grepl("^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it an HTTP status code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a three-digit code in 100-599.
#' @examples
#' is_http_status(c("200", "404", "099", "600", NA))
#' @family code detectors
#' @export
is_http_status <- function(x) {
  x <- as.character(x)
  n <- suppressWarnings(as.integer(x))
  out <- grepl("^\\d{3}$", x) & !is.na(n) & n >= 100 & n <= 599
  out[is.na(x)] <- NA
  out
}

#' Is it a Unix timestamp (seconds)?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 9-10 digit epoch-seconds value.
#' @details Inherently loose: any 9-10 digit integer in the plausible epoch
#'   range matches. Intended as a weak signal, corrected in the DGF if wrong.
#' @examples
#' is_unix_time(c("1513036980", "946684800", "12345", NA))
#' @family code detectors
#' @export
is_unix_time <- function(x) {
  x <- as.character(x)
  n <- suppressWarnings(as.numeric(x))
  out <- grepl("^\\d{9,10}$", x) & !is.na(n) & n >= 1e8 & n <= 9999999999
  out[is.na(x)] <- NA
  out
}

#' Is it a US ZIP code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `NNNNN` or `NNNNN-NNNN`.
#' @examples
#' is_zip_code(c("98052", "98052-6399", "1234", NA))
#' @family code detectors
#' @export
is_zip_code <- function(x) {
  x <- as.character(x)
  out <- grepl("^\\d{5}(-\\d{4})?$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a UK postcode?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a UK postcode like `SW1A 1AA`.
#' @examples
#' is_uk_postcode(c("SW1A 1AA", "IV40 8AJ", "12345", NA))
#' @family code detectors
#' @export
is_uk_postcode <- function(x) {
  x <- as.character(x)
  out <- grepl("^[A-Za-z]{1,2}[0-9][A-Za-z0-9]? ?[0-9][A-Za-z]{2}$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a Canadian postal code (or FSA)?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 3-char FSA (`V5K`) or full `A1A 1A1`.
#' @examples
#' is_ca_postal_code(c("V5K", "K1A 0B1", "12345", NA))
#' @family code detectors
#' @export
is_ca_postal_code <- function(x) {
  x <- as.character(x)
  out <- grepl("^[A-Za-z][0-9][A-Za-z]( ?[0-9][A-Za-z][0-9])?$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a US state abbreviation?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a USPS two-letter state code (plus `DC`).
#' @examples
#' is_us_state(c("WA", "dc", "ZZ", NA))
#' @family code detectors
#' @export
is_us_state <- function(x) {
  x <- as.character(x)
  out <- toupper(x) %in% c(datasets::state.abb, "DC")
  out[is.na(x)] <- NA
  out
}

#' Is it an ISO 3166-1 country code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a valid alpha-2 country code (e.g. `US`).
#' @details Case-insensitive lookup against the internal `.iso3166_alpha2`
#'   table (built by `data-raw/build_lookups.R` from the ISOcodes package).
#'   Note this overlaps [is_us_state()] for shared two-letter codes (e.g. `MT`);
#'   `guess_data_type()`'s specificity ranking resolves such ties.
#' @examples
#' is_country_code(c("US", "gb", "ZZ", NA))
#' @family code detectors
#' @export
is_country_code <- function(x) {
  x <- as.character(x)
  out <- toupper(x) %in% .iso3166_alpha2
  out[is.na(x)] <- NA
  out
}
