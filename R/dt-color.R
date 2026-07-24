##############################
### Data type family: color
###############################
## Detectors for hex, RGB, HSL, and CMYK color notations.


#' Is it a hex color?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `#RGB` or `#RRGGBB`.
#' @examples
#' is_hex_color(c("#4d9cf8", "#fff", "4d9cf8", NA))
#' @family color detectors
#' @export
is_hex_color <- function(x) {
  x <- as.character(x)
  out <- grepl("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it an RGB triple?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for three comma-separated integers 0-255.
#' @examples
#' is_rgb_color(c("220,220,220", "128, 64, 32", "300,0,0", NA))
#' @family color detectors
#' @export
is_rgb_color <- function(x) {
  x <- as.character(x)
  ok <- grepl("^[0-9, ]+$", x)
  rng <- .field_check(x, ",", matrix(c(0, 0, 0, 255, 255, 255), ncol = 2))
  out <- ok & rng
  out[is.na(x)] <- NA
  out
}

#' Is it an HSL triple?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `H, S%, L%` with hue 0-360 and S/L 0-100%.
#' @examples
#' is_hsl_color(c("195, 100%, 27%", "0, 0%, 0%", "195, 100, 27", NA))
#' @family color detectors
#' @export
is_hsl_color <- function(x) {
  x <- as.character(x)
  ok <- grepl("^\\s*\\d{1,3}\\s*,\\s*\\d{1,3}\\s*%\\s*,\\s*\\d{1,3}\\s*%\\s*$", x)
  y <- gsub("%", "", x)
  rng <- .field_check(y, ",", matrix(c(0, 0, 0, 360, 100, 100), ncol = 2))
  out <- ok & rng
  out[is.na(x)] <- NA
  out
}

#' Is it a CMYK quadruple?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for four comma-separated values in 0-1.
#' @examples
#' is_cmyk_color(c("0.0,0.31,0.37,0.0", "1,1,1,1", "0,0,0", NA))
#' @family color detectors
#' @export
is_cmyk_color <- function(x) {
  x <- as.character(x)
  ok <- grepl("^[0-9., ]+$", x)
  rng <- .field_check(x, ",", matrix(c(0, 0, 0, 0, 1, 1, 1, 1), ncol = 2))
  out <- ok & rng
  out[is.na(x)] <- NA
  out
}
