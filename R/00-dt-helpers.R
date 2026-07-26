##############################
### Detector helpers (internal)
###############################
## Small shared utilities used by the dt-<family>.R detectors. Loaded before
## the detector files (00- prefix), so they are available when detectors are
## defined. Not exported.


#' Check delimited numeric fields against per-field ranges
#'
#' Vectorized: splits each string on `sep`, and returns `TRUE` where there are
#' exactly `nrow(range)` numeric fields, each within its `[lo, hi]` row of
#' `range`. `NA`/malformed input yields `FALSE` (callers set `NA` separately).
#'
#' @param x Character vector.
#' @param sep Regex field separator (e.g. `","`, `"\\\\."`).
#' @param range A two-column matrix of `[lo, hi]` bounds, one row per field.
#' @return A logical vector the length of `x`.
#' @keywords internal
#' @noRd
.field_check <- function(x, sep, range) {
  n <- nrow(range)
  parts <- strsplit(as.character(x), sep)
  vapply(parts, function(p) {
    if (length(p) != n) return(FALSE)
    v <- suppressWarnings(as.numeric(trimws(p)))
    if (any(is.na(v))) return(FALSE)
    all(v >= range[, 1] & v <= range[, 2])
  }, logical(1))
}


#' Is a character column SAFE to promote to numeric? (internal)
#'
#' Used by `create_dgf(read_as_text = TRUE)`: after reading every column as
#' character (which preserves the source exactly), a column is promoted to
#' numeric only when it is safe to do so. TRUE requires that every non-blank
#' value:
#'   * parses as a plain decimal/integer/scientific number (no thousands
#'     separators, currency symbols, etc.),
#'   * is not a leading-zero integer (e.g. a ZIP `06037`, which `as.numeric`
#'     would silently corrupt to `6037`), and
#'   * if integer-like, has at most 15 digits (past the 2^53 double-exact range
#'     a long ID would lose precision).
#' Everything else stays character, keeping zero-padded codes and long IDs intact
#' for the factor / temporal / identifier / detector path.
#'
#' @param x A vector (coerced to character).
#' @return A single logical.
#' @keywords internal
#' @noRd
.safe_numeric <- function(x) {
  v <- as.character(x)
  v <- v[!is.na(v) & nzchar(trimws(v))]
  if (length(v) == 0L) return(FALSE)
  u <- unique(trimws(v))
  if (!all(grepl("^-?([0-9]+\\.?[0-9]*|\\.[0-9]+)([eE][-+]?[0-9]+)?$", u)))
    return(FALSE)
  if (any(grepl("^-?0[0-9]", u))) return(FALSE)          # leading-zero integer
  int_like <- !grepl("[.eE]", u)
  if (any(int_like) &&
      max(nchar(gsub("[^0-9]", "", u[int_like]))) > 15L)  # past 2^53 exact range
    return(FALSE)
  TRUE
}
