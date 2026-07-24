##############################
### Data type family: web / network
###############################
## Detectors for email, URL, IPv4, IPv6, and MAC address. See R/dt-currency.R
## for the detector contract (character in -> logical out, NA-safe).


#' Is it an email address?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a syntactically valid email, `NA` for `NA`.
#' @details A pragmatic pattern (local `@` domain `.` TLD), not the full RFC 5322
#'   grammar. Rejects spaces and a missing TLD.
#' @examples
#' is_email(c("a.b@example.com", "no-at-sign", NA))
#' @family web detectors
#' @export
is_email <- function(x) {
  x <- as.character(x)
  out <- grepl("^[[:alnum:]._%+-]+@[[:alnum:]][[:alnum:].-]*\\.[[:alpha:]]{2,}$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a URL?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for an http/https/ftp URL with a dotted host.
#' @examples
#' is_url(c("https://example.com/p?q=1", "example.com", NA))
#' @family web detectors
#' @export
is_url <- function(x) {
  x <- as.character(x)
  out <- grepl(
    "^(https?|ftp)://[[:alnum:]_-]+(\\.[[:alnum:]_-]+)+([:/?#][^[:space:]]*)?$",
    x, ignore.case = TRUE)
  out[is.na(x)] <- NA
  out
}

#' Is it an IPv4 address?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for four dot-separated octets in 0-255.
#' @examples
#' is_ipv4(c("192.168.1.1", "256.1.1.1", NA))
#' @family web detectors
#' @export
is_ipv4 <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\d{1,3}(\\.\\d{1,3}){3}$", x)
  rng <- .field_check(x, "\\.", matrix(c(0, 0, 0, 0, 255, 255, 255, 255), ncol = 2))
  out <- ok & rng
  out[is.na(x)] <- NA
  out
}

#' Is it an IPv6 address?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a full or `::`-compressed IPv6 address.
#' @examples
#' is_ipv6(c("2001:0db8:85a3:0000:0000:8a2e:0370:7334", "1:2:3", NA))
#' @family web detectors
#' @export
is_ipv6 <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0(
    "^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|",   # full 8 groups
    "([0-9a-fA-F]{1,4}:){1,7}:|",                  # trailing ::
    ":(:[0-9a-fA-F]{1,4}){1,7}|",                  # leading ::
    "([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})$"  # single :: in middle
  ), x)
  out[is.na(x)] <- NA
  out
}

#' Is it a MAC address?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for six `:`- or `-`-separated hex octets.
#' @examples
#' is_mac(c("00:1B:44:11:3A:B7", "40-1F-3C-B6-3C-BC", NA))
#' @family web detectors
#' @export
is_mac <- function(x) {
  x <- as.character(x)
  out <- grepl("^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$", x) |
         grepl("^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$", x)
  out[is.na(x)] <- NA
  out
}
