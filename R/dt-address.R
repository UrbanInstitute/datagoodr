##############################
### Data type family: address
###############################
## A decomposed address family: atomic component detectors (street, PO box,
## city, city+state, state+zip) each classify a column that is JUST that part,
## and a composite is_address() scans a single string for the PRESENCE of
## several components and fires when >= min_flags of them co-occur. Atomic
## detectors use whole-string (^...$) matching; the composite uses substring
## search with the same building blocks.
##
## City matching is exact against the normalized internal .us_cities lookup
## (built from maps::us.cities by data-raw/build_lookups.R). No stemming: a
## fuzzy slow-tier pass can be added later if real-data recall needs it.


## street-type suffixes (shared by the atomic and composite street checks)
#' @keywords internal
#' @noRd
.street_suffix <- paste0(
  "(St|Street|Ave|Avenue|Blvd|Boulevard|Rd|Road|Dr|Drive|Ln|Lane|Ct|Court|",
  "Pl|Place|Ter|Terrace|Cir|Circle|Hwy|Highway|Pkwy|Parkway|Way|Trl|Trail|",
  "Sq|Square|Loop|Pike|Row)")

## normalize a string for city membership: lowercase, letters/spaces only
#' @keywords internal
#' @noRd
.norm_city <- function(x) {
  x <- tolower(trimws(as.character(x)))
  gsub("[^a-z ]", "", x)
}

## does a full state name / abbreviation name a US state?
#' @keywords internal
#' @noRd
.is_state_token <- function(s) {
  s <- trimws(s)
  (toupper(s) %in% c(datasets::state.abb, "DC")) |
    (tolower(s) %in% tolower(c(datasets::state.name, "District of Columbia")))
}

#' Is it a street address?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `<number> <name> <street-type>`.
#' @examples
#' is_street_address(c("2325 140th St", "1225 S Walnut St", "Bloomington", NA))
#' @family address detectors
#' @export
is_street_address <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^\\d+\\s+([NSEW]\\.?\\s+)?[A-Za-z0-9. '-]+\\s+",
                      .street_suffix, "\\.?$"), x, ignore.case = TRUE)
  out[is.na(x)] <- NA
  out
}

#' Is it a PO box?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for PO box variants (`PO Box 12`, `P.O.B. 3`).
#' @examples
#' is_po_box(c("PO Box 1234", "P.O. Box 56", "POB 789", NA))
#' @family address detectors
#' @export
is_po_box <- function(x) {
  x <- as.character(x)
  out <- grepl(paste0("^(p\\.?\\s?o\\.?\\s?box|pob|p\\.?o\\.?b\\.?|",
                      "post\\s?office\\s?box)\\s*#?\\s*\\d+$"),
               x, ignore.case = TRUE)
  out[is.na(x)] <- NA
  out
}

#' Is it a US city / place name?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a name in the normalized `.us_cities`
#'   lookup (case/punctuation-insensitive). Coverage is the ~1,000 larger US
#'   cities (maps::us.cities); smaller towns will miss.
#' @examples
#' is_city_name(c("Chicago", "New Orleans", "Nowheresville", NA))
#' @family address detectors
#' @export
is_city_name <- function(x) {
  x <- as.character(x)
  out <- .norm_city(x) %in% .us_cities
  out[is.na(x)] <- NA
  out
}

#' Is it a "City, State" value?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `<anything>, <state abbrev or name>`.
#' @examples
#' is_city_state(c("Bloomington, IN", "Bloomington, Indiana", "just text", NA))
#' @family address detectors
#' @export
is_city_state <- function(x) {
  x <- as.character(x)
  m <- regmatches(x, regexec("^\\s*(.+?),\\s*([A-Za-z. ]{2,})\\s*$", x))
  out <- vapply(m, function(mm) length(mm) == 3 && .is_state_token(mm[3]),
                logical(1))
  out[is.na(x)] <- NA
  out
}

#' Is it a "State ZIP" value?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for `<state abbrev or name>[,] <ZIP>`.
#' @examples
#' is_state_zip(c("IN 47401", "Indiana 47401", "CA, 90210", NA))
#' @family address detectors
#' @export
is_state_zip <- function(x) {
  x <- as.character(x)
  m <- regmatches(x, regexec("^\\s*([A-Za-z. ]{2,}),?\\s+(\\d{5}(-\\d{4})?)\\s*$", x))
  out <- vapply(m, function(mm) length(mm) >= 3 && .is_state_token(mm[2]),
                logical(1))
  out[is.na(x)] <- NA
  out
}

#' Is it a full postal address?
#'
#' Scans each string for address components (street, PO box, city, state, ZIP)
#' and returns `TRUE` when at least `min_flags` of them are present. A single
#' component (just a ZIP, just a city) scores 1 and is better handled by the
#' atomic detector; a full address scores 3-5.
#'
#' @param x A character vector.
#' @param min_flags Minimum number of distinct components required (default 3).
#' @return Logical vector; `TRUE` where `>= min_flags` components co-occur.
#' @examples
#' is_address(c("1225 S Walnut St, Bloomington, IN 47401", "Chicago", NA))
#' @family address detectors
#' @export
is_address <- function(x, min_flags = 3) {
  x <- as.character(x)
  state_alt <- paste(c(datasets::state.abb, "DC"), collapse = "|")

  f_street <- grepl(paste0("\\b\\d+\\s+[A-Za-z0-9. '-]+\\s+", .street_suffix,
                           "\\b"), x, ignore.case = TRUE)
  f_pobox  <- grepl("\\bp\\.?\\s?o\\.?\\s?box\\b|\\bpob\\b|\\bpost\\s?office\\s?box\\b",
                    x, ignore.case = TRUE)
  f_state  <- grepl(paste0("(,\\s*|\\s)(", state_alt, ")(\\b|,)"), x)
  f_zip    <- grepl("\\b\\d{5}(-\\d{4})?\\b", x)
  f_city   <- vapply(strsplit(x, ","), function(parts) {
    any(.norm_city(parts) %in% .us_cities)
  }, logical(1))

  flags <- f_street + f_pobox + f_state + f_zip + f_city
  out <- flags >= min_flags
  out[is.na(x)] <- NA
  out
}
