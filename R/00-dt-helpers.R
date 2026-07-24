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
