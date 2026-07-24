##############################
### Data type family: government / entity IDs
###############################
## SSN, EIN, DEA (checksum), Chinese resident ID (checksum), SAM.gov UEI, and
## NAICS industry code. SSN applies the standard issuance validity rules; DEA
## and the Chinese ID validate a check digit.


#' Is it a US Social Security Number?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `ddd-dd-dddd` passing SSN issuance rules
#'   (area not 000/666/900-999, group not 00, serial not 0000).
#' @examples
#' is_ssn(c("540-39-4268", "000-12-3456", NA))
#' @family gov detectors
#' @export
is_ssn <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\d{3}-\\d{2}-\\d{4}$", x)
  a <- suppressWarnings(as.integer(substr(x, 1, 3)))
  g <- substr(x, 5, 6)
  s <- substr(x, 8, 11)
  valid <- ok & !is.na(a) & a != 0 & a != 666 & a < 900 & g != "00" & s != "0000"
  valid[is.na(valid)] <- FALSE
  out <- valid
  out[is.na(x)] <- NA
  out
}

#' Is it a US Employer Identification Number (EIN)?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `dd-ddddddd`.
#' @examples
#' is_ein(c("15-4464349", "154464349", NA))
#' @family gov detectors
#' @export
is_ein <- function(x) {
  x <- as.character(x)
  out <- grepl("^\\d{2}-\\d{7}$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a DEA registration number?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for two letters + seven digits whose DEA
#'   check digit is valid.
#' @examples
#' is_dea(c("AP5836727", "AP5836728", NA))
#' @family gov detectors
#' @export
is_dea <- function(x) {
  x <- as.character(x)
  ok <- grepl("^[A-Za-z]{2}\\d{7}$", x)
  chk <- vapply(seq_along(x), function(i) {
    if (is.na(ok[i]) || !ok[i]) return(FALSE)
    d <- as.integer(strsplit(substr(x[i], 3, 9), "")[[1]])
    ((d[1] + d[3] + d[5]) + 2 * (d[2] + d[4] + d[6])) %% 10 == d[7]
  }, logical(1))
  out <- ok & chk
  out[is.na(x)] <- NA
  out
}

#' Is it a Chinese resident identity card number?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for an 18-character ID whose ISO 7064
#'   mod-11-2 check character is valid.
#' @examples
#' is_chinese_resident_id(c("141002197808194474", NA))
#' @family gov detectors
#' @export
is_chinese_resident_id <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\d{17}[0-9Xx]$", x)
  w <- c(7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2)
  map <- c("1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2")  # rem 0..10
  chk <- vapply(seq_along(x), function(i) {
    if (is.na(ok[i]) || !ok[i]) return(FALSE)
    d <- as.integer(strsplit(substr(x[i], 1, 17), "")[[1]])
    toupper(substr(x[i], 18, 18)) == map[(sum(d * w) %% 11) + 1]
  }, logical(1))
  out <- ok & chk
  out[is.na(x)] <- NA
  out
}

#' Is it a SAM.gov Unique Entity Identifier (UEI)?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 12-character alphanumeric UEI (no
#'   letters `I`/`O`, first character not `0`).
#' @examples
#' is_uei(c("ABC123DEF456", "O1234567890X", NA))
#' @family gov detectors
#' @export
is_uei <- function(x) {
  x <- as.character(x)
  out <- grepl("^[A-HJ-NP-Z1-9][A-HJ-NP-Z0-9]{11}$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a NAICS industry code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 2-6 digit code present in the NAICS
#'   code list at any level (`.naics`, rolled up from the 2022 NAICS index).
#' @examples
#' is_naics(c("11", "541511", "99", NA))
#' @family gov detectors
#' @export
is_naics <- function(x) {
  x <- as.character(x)
  out <- grepl("^\\d{2,6}$", x) & (x %in% .naics)
  out[is.na(x)] <- NA
  out
}
