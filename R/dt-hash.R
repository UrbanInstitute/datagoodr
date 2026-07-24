##############################
### Data type family: hash / uuid
###############################
## Detectors for fixed-length hex digests and UUIDs. Digests are distinguished
## by length (MD5 32, SHA-1 40, SHA-256 64 hex chars).


#' Is it an MD5 digest?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 32-character hex string.
#' @examples
#' is_md5(c("d41d8cd98f00b204e9800998ecf8427e", "abc", NA))
#' @family hash detectors
#' @export
is_md5 <- function(x) {
  x <- as.character(x)
  out <- grepl("^[0-9a-fA-F]{32}$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a SHA-1 digest?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 40-character hex string.
#' @examples
#' is_sha1(c("da39a3ee5e6b4b0d3255bfef95601890afd80709", NA))
#' @family hash detectors
#' @export
is_sha1 <- function(x) {
  x <- as.character(x)
  out <- grepl("^[0-9a-fA-F]{40}$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a SHA-256 digest?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 64-character hex string.
#' @examples
#' is_sha256(c(paste(rep("a", 64), collapse = ""), NA))
#' @family hash detectors
#' @export
is_sha256 <- function(x) {
  x <- as.character(x)
  out <- grepl("^[0-9a-fA-F]{64}$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a GUID / UUID?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for the `8-4-4-4-12` hex UUID form.
#' @examples
#' is_guid(c("f2a59360-1d1a-49e8-9a2f-f9cdf0d5a811", NA))
#' @family hash detectors
#' @export
is_guid <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-",
                      "[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"), x)
  out[is.na(x)] <- NA
  out
}
