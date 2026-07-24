##############################
### Data type family: research / scholarly IDs
###############################
## DOI, ORCID, ISBN, ISSN (scholarly) and NPI (health provider). All but DOI
## carry a check digit that is validated, so a right-shaped-but-invalid value
## is rejected.


#' Is it a DOI?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a `10.<registrant>/<suffix>` DOI.
#' @examples
#' is_doi(c("10.1109/ICDCSW.2017.43", "not-a-doi", NA))
#' @family research-id detectors
#' @export
is_doi <- function(x) {
  x <- as.character(x)
  out <- grepl("^10\\.\\d{4,9}/[[:graph:]]+$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it an ORCID iD?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a `dddd-dddd-dddd-dddC` ORCID whose
#'   ISO 7064 mod-11-2 check digit is valid (`C` may be `X`).
#' @examples
#' is_orcid(c("0000-0002-0488-8591", "0000-0002-0488-8590", NA))
#' @family research-id detectors
#' @export
is_orcid <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\d{4}-\\d{4}-\\d{4}-\\d{3}[0-9Xx]$", x)
  chk <- vapply(seq_along(x), function(i) {
    if (is.na(ok[i]) || !ok[i]) return(FALSE)
    body <- gsub("-", "", x[i])
    d <- as.integer(strsplit(substr(body, 1, 15), "")[[1]])
    total <- 0L
    for (dig in d) total <- ((total + dig) * 2) %% 11
    rem <- (12 - total) %% 11
    chr <- if (rem == 10) "X" else as.character(rem)
    toupper(substr(body, 16, 16)) == chr
  }, logical(1))
  out <- ok & chk
  out[is.na(x)] <- NA
  out
}

#' Is it an ISBN (10 or 13)?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a valid ISBN-10 or ISBN-13 (dashes/spaces
#'   ignored) whose check digit is correct.
#' @examples
#' is_isbn(c("140955525-9", "978-3-16-148410-0", "140955525-8", NA))
#' @family research-id detectors
#' @export
is_isbn <- function(x) {
  x <- as.character(x)
  chk <- vapply(x, function(one) {
    if (is.na(one)) return(FALSE)
    s <- gsub("[- ]", "", one)
    if (grepl("^\\d{9}[0-9Xx]$", s)) {
      d <- strsplit(toupper(s), "")[[1]]
      v <- ifelse(d == "X", 10L, suppressWarnings(as.integer(d)))
      if (any(is.na(v))) return(FALSE)
      return(sum(v * (10:1)) %% 11 == 0)
    }
    if (grepl("^\\d{13}$", s)) {
      d <- as.integer(strsplit(s, "")[[1]])
      w <- rep(c(1L, 3L), length.out = 13)
      return(sum(d * w) %% 10 == 0)
    }
    FALSE
  }, logical(1), USE.NAMES = FALSE)
  out <- chk
  out[is.na(x)] <- NA
  out
}

#' Is it an ISSN?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `dddd-dddC` with a valid mod-11 check
#'   digit (`C` may be `X`).
#' @examples
#' is_issn(c("0003-021X", "0161-9268", "0003-0210", NA))
#' @family research-id detectors
#' @export
is_issn <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\d{4}-\\d{3}[0-9Xx]$", x)
  chk <- vapply(seq_along(x), function(i) {
    if (is.na(ok[i]) || !ok[i]) return(FALSE)
    s <- gsub("-", "", toupper(x[i]))
    d <- as.integer(strsplit(substr(s, 1, 7), "")[[1]])
    last <- substr(s, 8, 8)
    chkv <- if (last == "X") 10L else as.integer(last)
    (sum(d * (8:2)) + chkv) %% 11 == 0
  }, logical(1))
  out <- ok & chk
  out[is.na(x)] <- NA
  out
}

#' Is it an NPI (US health provider)?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 10-digit NPI whose Luhn check digit
#'   (over the `80840` prefix + first 9 digits) is valid.
#' @examples
#' is_npi(c("1225155880", "1234567890", NA))
#' @family research-id detectors
#' @export
is_npi <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\d{10}$", x)
  chk <- ok & .luhn_ok(ifelse(ok, paste0("80840", x), "0"))
  out <- ok & chk
  out[is.na(x)] <- NA
  out
}
