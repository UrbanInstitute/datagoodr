##############################
### Checksum helpers (internal)
###############################
## Shared check-digit routines for detectors that validate structure AND a
## checksum. Loaded before the dt-<family>.R files. Not exported.


#' Luhn (mod-10) validity of a digit string
#'
#' @param s A character vector of digit strings (the last digit is the check
#'   digit). Non-digit or `NA` elements return `FALSE`.
#' @return A logical vector: `TRUE` where `s` passes the Luhn checksum.
#' @keywords internal
#' @noRd
.luhn_ok <- function(s) {
  s <- as.character(s)
  vapply(s, function(one) {
    if (is.na(one) || !grepl("^[0-9]+$", one)) return(FALSE)
    d <- as.integer(rev(strsplit(one, "")[[1]]))
    if (length(d) < 2) return(FALSE)
    idx <- which(seq_along(d) %% 2 == 0)
    d[idx] <- d[idx] * 2
    d[d > 9] <- d[d > 9] - 9
    sum(d) %% 10 == 0
  }, logical(1), USE.NAMES = FALSE)
}
