# Compact-format readers referenced from a DGF's `raw_to_stable_transform`
# column. Each INGESTS a value written in one specific format and returns the
# canonical form; the name states the input format, not the output type (see the
# read_* / as_* split documented in R/01-07-read-rules.R).
#
# Applied element-wise to a single value, so they accept and return length-1
# inputs and pass NA through unchanged.
#
# WHY THESE STAY IN datagoodr. formex owns the general detection and transform
# engine, but its recipe verbs miss the compact/damaged forms these cover
# (measured against formex 0.0.0.9000, 2026-08-22):
#
#   read_yyyymm("201903")  -> "2019-03"    formex as_yyyymm -> "2020-03"  (wrong year)
#   read_ein("12345678")   -> "01-2345678" formex as_ein    -> NA         (needs 9 digits)
#   read_yyyy("FY2019")    -> "2019"       formex as_yyyy   -> NA
#
# These are gaps to offer upstream as formex verbs; until they land, the DGF
# needs readers that handle them.


#' Read an EIN written in any common form
#'
#' Ingests an Employer Identification Number however it arrives --- nine digits,
#' hyphenated, or with the leading zero stripped by a spreadsheet --- and
#' returns the canonical hyphenated form `NN-NNNNNNN`. This is the form the
#' type ontology declares as the stable value for
#' `identifier / id / administrative (ein)`, so a datagoodr-stabilized EIN and a
#' formex-stabilized EIN are the same string.
#'
#' @param x A single EIN value (numeric or character).
#'
#' @return A canonical `"NN-NNNNNNN"` EIN string, `NA` if `x` is `NA`, or `NA`
#'   with a warning when `x` does not hold nine or fewer digits.
#' @examples
#' read_ein("12345678")    # leading zero restored
#' read_ein("01-2345678")  # already canonical
#' @seealso [read_mm()], [read_yyyy()], [read_yyyymm()]
#' @export
read_ein <- function(x) {
  if (is.na(x)) return(NA_character_)
  d <- gsub("\\D", "", as.character(x))
  if (!nzchar(d) || nchar(d) > 9) {
    warning("Not readable as an EIN: '", x, "'", call. = FALSE)
    return(NA_character_)
  }
  d <- stringr::str_pad(d, 9, side = "left", pad = "0")
  paste0(substr(d, 1, 2), "-", substr(d, 3, 9))
}


#' Read a month number written at any width
#'
#' Ingests a month number written with or without its leading zero (`8` or
#' `"08"`) and returns the canonical two-digit form. `NA` is returned unchanged.
#'
#' @param x A single month value (numeric or character).
#'
#' @return A 2-character month string, or `NA` if `x` is `NA`.
#' @examples
#' read_mm(8)
#' read_mm("08")
#' @seealso [read_ein()], [read_yyyy()], [read_yyyymm()]
#' @export
#' @importFrom stringr str_pad
read_mm <- function(x) {
  if (is.na(x)) return(x)
  stringr::str_pad(x, 2, side = "left", pad = "0")
}


#' Read a year, plain or fiscal-year labelled
#'
#' Ingests a four-digit year written plainly (`2019`) or with a fiscal-year
#' prefix (`FY2019`, `FY 2019`) and returns the bare four-digit year. `NA` is
#' returned unchanged.
#'
#' @param x A single year value (numeric or character).
#'
#' @return The four-digit year as a character string, or `NA` if `x` is `NA`.
#' @examples
#' read_yyyy(2019)
#' read_yyyy("FY2019")
#' @seealso [read_mm()], [read_yyyymm()]
#' @export
read_yyyy <- function(x) {
  if (is.na(x)) return(x)
  x <- trimws(as.character(x))
  x <- sub("^FY[ -]?", "", x, ignore.case = TRUE)   # fiscal-year prefix
  if (!grepl("^[0-9]{4}$", x)) warning("Not readable as a 4-digit year: '", x, "'",
                                       call. = FALSE)
  x
}


#' Read a compact YYYYMM value
#'
#' Ingests a six-character `YYYYMM` value (`"201903"`), or one already
#' hyphenated (`"2019-03"`), and returns the canonical `"YYYY-MM"` form. `NA` is
#' returned unchanged.
#'
#' @param x A single `YYYYMM` value (numeric or character).
#'
#' @return A `"YYYY-MM"` character string, or `NA` if `x` is `NA`.
#' @examples
#' read_yyyymm(201903)
#' read_yyyymm("2019-03")
#' @seealso [read_yyyy()], [read_mm()]
#' @export
read_yyyymm <- function(x) {
  if (is.na(x)) return(x)
  d <- gsub("\\D", "", as.character(x))
  if (nchar(d) != 6) {
    warning("Not readable as YYYYMM: '", x, "'", call. = FALSE)
    return(NA_character_)
  }
  paste0(substr(d, 1, 4), "-", substr(d, 5, 6))
}
