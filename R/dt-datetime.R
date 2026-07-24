##############################
### Data type family: date / time
###############################
## Detectors for common date/time representations, grouped by form. Several
## AutoType date files map onto one detector here (e.g. all ISO datetime
## variants -> is_iso_datetime). These are the single source of truth for a
## column's temporal type: create_dgf() reconciles its build-time profile class
## and stable_data_unit to whatever they detect (via guess_dgf_types()), so a
## date these catch is typed, profiled, and united as temporal even when the
## cheaper detect_temporal() base-pass misses its string form.
##
## `.mon` and `.wd` are internal alternations matching full-or-abbreviated
## English month and weekday names.

#' @keywords internal
#' @noRd
.mon <- paste0("(Jan(uary)?|Feb(ruary)?|Mar(ch)?|Apr(il)?|May|Jun(e)?|",
               "Jul(y)?|Aug(ust)?|Sep(tember)?|Oct(ober)?|Nov(ember)?|Dec(ember)?)")

#' @keywords internal
#' @noRd
.wd <- paste0("(Mon(day)?|Tue(sday)?|Wed(nesday)?|Thu(rsday)?|Fri(day)?|",
              "Sat(urday)?|Sun(day)?)")

## helper: TRUE where month in 1-12 and day in 1-31 (vectorized, NA -> FALSE)
#' @keywords internal
#' @noRd
.valid_md <- function(mo, dy) {
  ok <- !is.na(mo) & !is.na(dy) & mo >= 1 & mo <= 12 & dy >= 1 & dy <= 31
  ok[is.na(ok)] <- FALSE
  ok
}

#' Is it an ISO 8601 date?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `YYYY-MM-DD` with valid month/day.
#' @examples
#' is_iso_date(c("2016-03-15", "2016-13-01", NA))
#' @family datetime detectors
#' @export
is_iso_date <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\d{4}-\\d{2}-\\d{2}$", x)
  mo <- suppressWarnings(as.integer(substr(x, 6, 7)))
  dy <- suppressWarnings(as.integer(substr(x, 9, 10)))
  out <- ok & .valid_md(mo, dy)
  out[is.na(x)] <- NA
  out
}

#' Is it an ISO 8601 datetime?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `YYYY-MM-DDThh:mm:ss` with optional
#'   fractional seconds and `Z`/offset zone.
#' @examples
#' is_iso_datetime(c("2009-06-15T13:45:30+02:00", "2009-06-15", NA))
#' @family datetime detectors
#' @export
is_iso_datetime <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}",
                      "(\\.\\d+)?(Z|[+-]\\d{2}:?\\d{2})?$"), x)
  out[is.na(x)] <- NA
  out
}

#' Is it a US numeric date (M/D/YY)?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `M/D/YY` or `M/D/YYYY` with valid parts.
#' @examples
#' is_us_date(c("3/3/16", "13/1/2016", NA))
#' @family datetime detectors
#' @export
is_us_date <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\d{1,2}/\\d{1,2}/\\d{2,4}$", x)
  parts <- strsplit(x, "/")
  val <- vapply(parts, function(p) {
    if (length(p) != 3) return(FALSE)
    .valid_md(suppressWarnings(as.integer(p[1])), suppressWarnings(as.integer(p[2])))
  }, logical(1))
  out <- ok & val
  out[is.na(x)] <- NA
  out
}

#' Is it a US numeric datetime with AM/PM?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `M/D/YYYY h:mm[:ss] [AM/PM]` (`/` or `-`).
#' @examples
#' is_us_datetime(c("2/6/1987 6:00:37 AM", "05-13-2009 12:35 PM", NA))
#' @family datetime detectors
#' @export
is_us_datetime <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^\\d{1,2}[/-]\\d{1,2}[/-]\\d{4}\\s+",
                      "\\d{1,2}:\\d{2}(:\\d{2})?\\s*([AP]M)?$"), x, ignore.case = TRUE)
  out[is.na(x)] <- NA
  out
}

#' Is it a day-month-year date with an abbreviated month?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for e.g. `1-Jul-14` or `21/Nov/2012`.
#' @examples
#' is_abbr_month_date(c("1-Jul-14", "21/Nov/2012", NA))
#' @family datetime detectors
#' @export
is_abbr_month_date <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^\\d{1,2}[-/](Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|",
                      "Nov|Dec)[-/]\\d{2,4}$"), x)
  out[is.na(x)] <- NA
  out
}

#' Is it an RFC 2822 / HTTP datetime?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for e.g. `Fri, 06 Feb 1987 06:00:37 GMT`.
#' @examples
#' is_rfc2822_datetime(c("Fri, 06 Feb 1987 06:00:37 GMT", NA))
#' @family datetime detectors
#' @export
is_rfc2822_datetime <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^", .wd, ",\\s+\\d{1,2}\\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|",
                      "Aug|Sep|Oct|Nov|Dec)\\s+\\d{4}\\s+\\d{2}:\\d{2}:\\d{2}\\s+",
                      "(GMT|UTC|[+-]\\d{4})$"), x)
  out[is.na(x)] <- NA
  out
}

#' Is it a verbose English date?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for weekday/month-name dates such as
#'   `Friday, June 16, 1967` or `Mar 15 2016 10:53:29`. Requires a weekday
#'   prefix or a year, to avoid overlapping [is_month_day()].
#' @examples
#' is_long_date(c("Friday, June 16, 1967", "Mar 15 2016 10:53:29", NA))
#' @family datetime detectors
#' @export
is_long_date <- function(x) {
  x <- as.character(x)
  tail <- paste0("\\s+\\d{1,2},?(\\s+\\d{1,4}\\s*(BCE|BC|CE|AD)?)?",
                 "(\\s+\\d{1,2}:\\d{2}(:\\d{2})?\\s*([AP]M)?)?$")
  with_wd <- grepl(paste0("^", .wd, ",?\\s+", .mon, tail), x)  # weekday present
  with_yr <- grepl(paste0("^", .mon,
                          "\\s+\\d{1,2},?\\s+\\d{1,4}\\s*(BCE|BC|CE|AD)?",
                          "(\\s+\\d{1,2}:\\d{2}(:\\d{2})?\\s*([AP]M)?)?$"), x)
  out <- with_wd | with_yr
  out[is.na(x)] <- NA
  out
}

#' Is it a Month-Year value?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `Month YYYY` or `Month, YYYY`.
#' @examples
#' is_month_year(c("February 1987", "August, 2005", NA))
#' @family datetime detectors
#' @export
is_month_year <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^", .mon, ",?\\s+\\d{4}$"), x)
  out[is.na(x)] <- NA
  out
}

#' Is it a Month-Day value (no year)?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `Month D` (e.g. `February 6`).
#' @examples
#' is_month_day(c("February 6", "February 1987", NA))
#' @family datetime detectors
#' @export
is_month_day <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^", .mon, "\\s+\\d{1,2}$"), x)
  out[is.na(x)] <- NA
  out
}

#' Is it a clock time?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `h:mm[:ss] [AM/PM]` with valid h/m.
#' @examples
#' is_clock_time(c("6:00:37 AM", "23:45", "25:00", NA))
#' @family datetime detectors
#' @export
is_clock_time <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\d{1,2}:\\d{2}(:\\d{2})?\\s*([AP]M)?$", x, ignore.case = TRUE)
  hh <- suppressWarnings(as.integer(sub("^(\\d{1,2}):.*$", "\\1", x)))
  mm <- suppressWarnings(as.integer(sub("^\\d{1,2}:(\\d{2}).*$", "\\1", x)))
  valid <- !is.na(hh) & !is.na(mm) & hh >= 0 & hh <= 23 & mm >= 0 & mm <= 59
  valid[is.na(valid)] <- FALSE
  out <- ok & valid
  out[is.na(x)] <- NA
  out
}

#' Is it a date range?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for two ISO or US dates joined by `to`/`-`.
#' @examples
#' is_date_range(c("07/21/16 to 08/19/16", "1972-01-01 - 1972-07-01", NA))
#' @family datetime detectors
#' @export
is_date_range <- function(x) {
  x <- as.character(x)
  d <- "(\\d{1,2}/\\d{1,2}/\\d{2,4}|\\d{4}-\\d{2}-\\d{2})"
  out <- grepl(paste0("^", d, "\\s+(to|-)\\s+", d, "$"), x)
  out[is.na(x)] <- NA
  out
}

#' Is it a Hijri (Islamic-calendar) date?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `D <Islamic month> YYYY`.
#' @examples
#' is_hijri_date(c("11 Shawwal 1430", "5 Muharram 1300", NA))
#' @family datetime detectors
#' @export
is_hijri_date <- function(x) {
  x <- as.character(x)
  months <- paste0("(Muharram|Safar|Rabi|Jumada|Rajab|Sha.?ban|Ramadan|",
                   "Shawwal|Dhu)([ '-]?al[ '-]?[A-Za-z]+)?")
  out <- grepl(paste0("^\\d{1,2}\\s+", months, "\\s+\\d{3,4}$"), x)
  out[is.na(x)] <- NA
  out
}
