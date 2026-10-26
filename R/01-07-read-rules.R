##############################
### read_* / as_* rules
###############################
## The executable side of the DGF's format vocabulary. Two families, and the
## split is the point:
##
##   read_<format>(x)   INGEST a value written in <format>; return the canonical
##                      or typed value. The name states the INPUT.
##   as_<type>(x)       COERCE a value into <type>. The name states the OUTPUT.
##
## That makes the DGF's two bridge columns distinguishable on sight:
##
##   raw_to_stable_transform    takes a read_*   (ingest the raw written form)
##   desired_data_import_rule   takes an as_*    (coerce into the target type)
##
## A rule sitting in the wrong column is now visible without running it.
##
## The temporal readers take the compact format notation and turn it into a
## delimiter-aware parse: the notation maps 1:1 onto strptime %-codes. A mask
## that carries separators (`mm/dd/yyyy`, `mm-dd-yyyy`, `mm dd yyyy`) parses
## delimiter-agnostically under the single label `mmddyyyy`; a mask with NO
## separators (`yyyymmdd`) parses the run-together form `20190315`. Applied as a
## transform, the result is a Date/POSIXct that writes back to the governed CSV
## in ISO form; applied as an import rule, it is the typed column itself.
##
## Notation letters: y year, m month (num), M month (text), d day, H 24-hour,
## h 12-hour, i minute, s second, A am/pm, W weekday, T timezone. Doubling sets
## width (yyyy vs yy); see the format vocabulary in the temporal ontology.
##
## NOTE (formex seam): formex's date "genome" (`.DATE_FORMATS`) is a broader
## tolerant parser and should be preferred for free-form date columns. These
## readers are kept for the COMPACT-LABEL cases formex does not cover --- an
## undelimited `yyyymm`, a zero-stripped EIN, an `FY`-prefixed year --- and for
## the case where the DGF names one exact input format on purpose.

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
#'
#' @return A character vector of tokens.
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

#' Translate a compact date/time format to strptime patterns (internal)
#'
#' A compact label (`mmddyyyy`) names the ELEMENT ORDER, not the punctuation, so
#' one label has to read both the delimited form (`03/15/2019`) and the
#' run-together form (`03152019`). Two patterns are compiled --- one joined by
#' `-`, one concatenated --- and [read_date()] picks per value depending on
#' whether that value carries separators. This is what lets `read_yyyymmdd()`
#' read `20190315`, the case the compact label exists for.
#'
#' @return A list with `delimited`, `packed` (strptime patterns) and `has_time`.
#' @keywords internal
#' @noRd
.format_to_strptime <- function(fmt) {
  toks <- .tokenize_dt_format(fmt)
  if (!length(toks)) stop("Unrecognized date/time format: '", fmt, "'.")
  list(delimited = paste(.dt_code[toks], collapse = "-"),
       packed    = paste(.dt_code[toks], collapse = ""),
       has_time  = any(toks %in% .dt_time_tokens))
}

#' Parse a vector under a compact label, choosing the pattern per value (internal)
#'
#' @keywords internal
#' @noRd
.read_dt <- function(x, format, tz = "UTC", force_time = FALSE) {
  cf <- .format_to_strptime(format)
  xn <- as.character(x)
  xn <- gsub("([0-9])(st|nd|rd|th)", "\\1", xn, ignore.case = TRUE)  # ordinals
  xn <- trimws(xn)
  has_sep <- grepl("[^A-Za-z0-9]", xn)          # does THIS value carry separators?
  xd <- gsub("[^A-Za-z0-9]+", "-", xn)          # normalize whatever they are

  want_time <- force_time || cf$has_time
  out <- if (want_time) as.POSIXct(rep(NA_real_, length(xn)), tz = tz)
         else as.Date(rep(NA_real_, length(xn)), origin = "1970-01-01")

  parse1 <- function(v, pat) {
    if (want_time) as.POSIXct(v, format = pat, tz = tz)
    else as.Date(v, format = pat)
  }
  if (any(has_sep, na.rm = TRUE))
    out[which(has_sep)] <- parse1(xd[which(has_sep)], cf$delimited)
  if (any(!has_sep, na.rm = TRUE))
    out[which(!has_sep)] <- parse1(xn[which(!has_sep)], cf$packed)
  out
}

#' Read dates/datetimes written in a compact format
#'
#' Ingests values written in the format named by `format` and returns them
#' typed. When the format carries separators the parse is delimiter-agnostic:
#' ordinal suffixes (`4th`) are stripped and any run of non-alphanumeric
#' characters is normalized, so `mm/dd/yyyy`, `mm-dd-yyyy` and `mm dd yyyy` all
#' read under the single label `mmddyyyy`. When the format carries none
#' (`yyyymmdd`), the run-together form is read as written.
#'
#' @param x A character vector of date/time strings.
#' @param format A compact format label (e.g. `"mmddyyyy"`, `"yyyymmddHHiiss"`).
#' @param tz Timezone for datetime parsing. Defaults to `"UTC"`.
#' @return A `Date` or `POSIXct` vector; unreadable values become `NA`.
#' @examples
#' read_date(c("3/15/2020", "1-2-2020"), "mmddyyyy")
#' read_date("20190315", "yyyymmdd")
#' read_datetime("3/15/2020 2:30 PM", "mmddyyyyhhiiA")
#' @seealso [as_id()] for the coercion direction; the `is_*` date detectors in
#'   \pkg{formex} that guard these rules.
#' @export
read_date <- function(x, format, tz = "UTC") {
  .read_dt(x, format, tz = tz, force_time = FALSE)
}

#' @rdname read_date
#' @export
read_datetime <- function(x, format, tz = "UTC") {
  .read_dt(x, format, tz = tz, force_time = TRUE)
}

## Named convenience wrappers -- the values that go in a DGF's
## raw_to_stable_transform cell. Each is `read_<format label>`; add more as
## needed (or call read_date(x, "<label>")).
#' @rdname read_date
#' @export
read_yyyymmdd <- function(x) read_date(x, "yyyymmdd")
#' @rdname read_date
#' @export
read_mmddyyyy <- function(x) read_date(x, "mmddyyyy")
#' @rdname read_date
#' @export
read_ddmmyyyy <- function(x) read_date(x, "ddmmyyyy")
#' @rdname read_date
#' @export
read_mdyyyy <- function(x) read_date(x, "mdyyyy")
#' @rdname read_date
#' @export
read_dMyyyy <- function(x) read_date(x, "dMyyyy")
#' @rdname read_date
#' @export
read_Mdyyyy <- function(x) read_date(x, "Mdyyyy")
#' @rdname read_date
#' @export
read_yyyymmddHHiiss <- function(x) read_datetime(x, "yyyymmddHHiiss")
#' @rdname read_date
#' @export
read_mmddyyyyhhiiA <- function(x) read_datetime(x, "mmddyyyyhhiiA")

#' Coerce a column to an identifier (character, trimmed)
#'
#' The import rule for identifier columns: keep the value as text (so leading
#' zeros and long numeric IDs survive) and trim surrounding whitespace. This is
#' an `as_*` --- it names the TYPE it produces, and belongs in
#' `desired_data_import_rule`, not `raw_to_stable_transform`.
#'
#' @param x A vector.
#' @return A trimmed character vector.
#' @examples
#' as_id(c(" 06037 ", "36061"))
#' @seealso [read_date()] for the ingest direction.
#' @export
as_id <- function(x) trimws(as.character(x))
