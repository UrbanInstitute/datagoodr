##############################
### Data type family: scientific / bio identifiers
###############################
## Detectors for Ensembl, UniProt, ICD-9, ICD-10, dbSNP, ASIN, and ADS bibcode.


#' Is it an Ensembl gene/transcript/protein ID?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `ENS[species]<G/T/P/E><11 digits>`.
#' @examples
#' is_ensembl_id(c("ENSG00000139618", "ENSMUSG00000102659", NA))
#' @family scibio detectors
#' @export
is_ensembl_id <- function(x) {
  x <- as.character(x)
  out <- grepl("^ENS[A-Z]{0,3}[EGTP][0-9]{11}$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a UniProt accession?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a UniProtKB accession pattern.
#' @examples
#' is_uniprot_id(c("P33667", "Q9BWD1", "ZZ", NA))
#' @family scibio detectors
#' @export
is_uniprot_id <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^([OPQ][0-9][A-Z0-9]{3}[0-9]|",
                      "[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2})$"), x)
  out[is.na(x)] <- NA
  out
}

#' Is it an ICD-9 code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a numeric or E/V ICD-9-CM code.
#' @examples
#' is_icd9_code(c("078.11", "V70.0", "E880.9", NA))
#' @family scibio detectors
#' @export
is_icd9_code <- function(x) {
  x <- as.character(x)
  out <- grepl("^(\\d{3}|E\\d{3}|V\\d{2})(\\.\\d{1,2})?$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it an ICD-10 code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `<letter><2 digits>[.<up to 4 alnum>]`.
#' @examples
#' is_icd10_code(c("I61", "D76.0", "S72.001A", NA))
#' @family scibio detectors
#' @export
is_icd10_code <- function(x) {
  x <- as.character(x)
  out <- grepl("^[A-Z][0-9]{2}(\\.[A-Z0-9]{1,4})?$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a dbSNP reference SNP ID?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `rs` followed by digits.
#' @examples
#' is_snp_id(c("rs3918290", "rs429358", "3918290", NA))
#' @family scibio detectors
#' @export
is_snp_id <- function(x) {
  x <- as.character(x)
  out <- grepl("^rs[0-9]+$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it an Amazon ASIN?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a `B0` + 8 alphanumeric ASIN.
#' @examples
#' is_asin(c("B01L7DYXL0", "B08N5WRWNW", "140955525", NA))
#' @family scibio detectors
#' @export
is_asin <- function(x) {
  x <- as.character(x)
  out <- grepl("^B0[0-9A-Z]{8}$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it an ADS bibcode?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for the 19-character ADS bibcode form.
#' @examples
#' is_bibcode(c("2004PASP..116...98K", "2003A&A...405..175M", NA))
#' @family scibio detectors
#' @export
is_bibcode <- function(x) {
  x <- as.character(x)
  out <- grepl("^[0-9]{4}[A-Za-z0-9.&]{14}[A-Za-z.]$", x)
  out[is.na(x)] <- NA
  out
}
