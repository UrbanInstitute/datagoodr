##############################
### as_* import / transform rules
###############################
## The executable side of the DGF's format vocabulary. A rule name (e.g.
## "as_mmddyyyy") sits in raw_to_stable_transform (reformat) or
## desired_data_import_rule (coerce), and stabilize_data()/create_dgf() apply it
## to a column. Each as_* has a matching is_* detector as its guard.
##
## The temporal parsers take the compact format notation and turn it into a
## delimiter-agnostic parse: the notation maps 1:1 onto strptime %-codes, and the
## input's delimiters are normalized so `mm/dd/yyyy`, `mm-dd-yyyy`, and
## `mm dd yyyy` all parse under the single label `mmddyyyy`. Applied as a
## transform, the result is a Date/POSIXct that writes back to the governed CSV
## in ISO form; applied as an import rule, it is the typed column itself.
##
## Notation letters: y year, m month (num), M month (text), d day, H 24-hour,
## h 12-hour, i minute, s second, A am/pm, W weekday, T timezone. Doubling sets
## width (yyyy vs yy); see the format vocabulary in the temporal ontology.

#' @keywords internal
#' @noRd
.dt_tokens <- c("MMMM", "WWWW", "yyyy", "MMM", "WWW", "yy", "mm", "dd",
                "HH", "hh", "ii", "ss", "M", "H", "h", "m", "d", "i", "s",
                "A", "T")

#' @keywords internal
#' @noRd
.dt_code <- c(MMMM = "%B", WWWW = "%A", yyyy = "%Y", MMM = "%b", WWW = "%a",
              yy = "%y", mm = "%m", dd = "%d", HH = "%H", hh = "%I", ii = "%M",
              ss = "%S", M = "%b", H = "%H", h = "%I", m = "%m", d = "%d",
              i = "%M", s = "%S", A = "%p", T = "%Z")

## tokens that imply a time-of-day component (-> POSIXct rather than Date)
#' @keywords internal
#' @noRd
.dt_time_tokens <- c("HH", "hh", "ii", "ss", "H", "h", "i", "s", "A", "T")

#' Split a compact date/time format into its tokens (internal)
#' @keywords internal
#' @noRd
.tokenize_dt_format <- function(fmt) {
  toks <- character(0); i <- 1L; n <- nchar(fmt)
  while (i <= n) {
    hit <- FALSE
    for (t in .dt_tokens) {
      L <- nchar(t)
      if (i + L - 1L <= n && substr(fmt, i, i + L - 1L) == t) {
        toks <- c(toks, t); i <- i + L; hit <- TRUE; break
      }
    }
    if (!hit) i <- i + 1L   # skip an unrecognized character (delimiters etc.)
  }
  toks
}

#' Translate a compact date/time format to a strptime pattern (internal)
#'
#' @return A list with `strptime` (e.g. `"%m-%d-%Y"`) and `has_time` (logical).
#' @keywords internal
#' @noRd
.format_to_strptime <- function(fmt) {
  toks <- .tokenize_dt_format(fmt)
  if (!length(toks)) stop("Unrecognized date/time format: '", fmt, "'.")
  list(strptime = paste(.dt_code[toks], collapse = "-"),
       has_time = any(toks %in% .dt_time_tokens))
}

#' Parse dates/datetimes under a compact format label
#'
#' Delimiter-agnostic: strips ordinal suffixes (`4th`), collapses any run of
#' non-alphanumeric characters to a single separator, and applies the strptime
#' pattern the label compiles to. Returns `Date` for date-only labels and
#' `POSIXct` for labels carrying a time component.
#'
#' @param x A character vector of date/time strings.
#' @param format A compact format label (e.g. `"mmddyyyy"`, `"yyyymmddHHiiss"`).
#' @param tz Timezone for datetime parsing. Defaults to `"UTC"`.
#' @return A `Date` or `POSIXct` vector; unparseable values become `NA`.
#' @examples
#' as_date(c("3/15/2020", "1-2-2020"), "mmddyyyy")
#' as_datetime("3/15/2020 2:30 PM", "mmddyyyyhhiiA")
#' @seealso the `is_*` date detectors that guard these rules
#' @export
as_date <- function(x, format, tz = "UTC") {
  cf <- .format_to_strptime(format)
  xn <- as.character(x)
  xn <- gsub("([0-9])(st|nd|rd|th)", "\\1", xn, ignore.case = TRUE)  # ordinals
  xn <- gsub("[^A-Za-z0-9]+", "-", trimws(xn))                       # delimiters
  if (cf$has_time) {
    as.POSIXct(xn, format = cf$strptime, tz = tz)
  } else {
    as.Date(xn, format = cf$strptime)
  }
}

#' @rdname as_date
#' @export
as_datetime <- function(x, format, tz = "UTC") {
  cf <- .format_to_strptime(format)
  xn <- gsub("[^A-Za-z0-9]+", "-",
             trimws(gsub("([0-9])(st|nd|rd|th)", "\\1", as.character(x),
                         ignore.case = TRUE)))
  as.POSIXct(xn, format = cf$strptime, tz = tz)
}

## Named convenience wrappers -- the values that go in a DGF rule cell. Each is
## `as_<format label>`; add more as needed (or call as_date(x, "<label>")).
#' @rdname as_date
#' @export
as_yyyymmdd <- function(x) as_date(x, "yyyymmdd")
#' @rdname as_date
#' @export
as_mmddyyyy <- function(x) as_date(x, "mmddyyyy")
#' @rdname as_date
#' @export
as_ddmmyyyy <- function(x) as_date(x, "ddmmyyyy")
#' @rdname as_date
#' @export
as_mdyyyy <- function(x) as_date(x, "mdyyyy")
#' @rdname as_date
#' @export
as_dMyyyy <- function(x) as_date(x, "dMyyyy")
#' @rdname as_date
#' @export
as_Mdyyyy <- function(x) as_date(x, "Mdyyyy")
#' @rdname as_date
#' @export
as_yyyymmddHHiiss <- function(x) as_datetime(x, "yyyymmddHHiiss")
#' @rdname as_date
#' @export
as_mmddyyyyhhiiA <- function(x) as_datetime(x, "mmddyyyyhhiiA")

#' Coerce a column to an identifier (character, trimmed)
#'
#' The import rule for identifier columns: keep the value as text (so leading
#' zeros and long numeric IDs survive) and trim surrounding whitespace.
#'
#' @param x A vector.
#' @return A trimmed character vector.
#' @examples
#' as_id(c(" 06037 ", "36061"))
#' @export
as_id <- function(x) trimws(as.character(x))
