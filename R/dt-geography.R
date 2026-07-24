##############################
### Data type family: geography
###############################
## Census/geographic identifiers. The FIPS hierarchy is anchored on the valid
## 2-digit state FIPS prefix (internal .state_fips, built by
## data-raw/build_lookups.R) plus an exact code length -- a strong, data-free
## signal. NCES locale, urban/rural designations, and census regions are small
## fixed vocabularies. CBSA/CSA codes and Census urban-area (UACE) codes need
## external code lists and are a separate step.
##
## NOTE: 5-digit numeric geocodes are inherently ambiguous by value alone
## (a ZIP, a county FIPS, and a CBSA code can share digits). These detectors
## coexist; true disambiguation needs the variable-name hint planned for
## guess_data_type().

## helper: n-digit string whose first two digits are a valid state FIPS
#' @keywords internal
#' @noRd
.fips_of_width <- function(x, n) {
  x <- as.character(x)
  out <- grepl(paste0("^\\d{", n, "}$"), x) & (substr(x, 1, 2) %in% .state_fips)
  out[is.na(x)] <- NA
  out
}

#' Is it a state FIPS code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a valid 2-digit state/territory FIPS.
#' @examples
#' is_state_fips(c("06", "36", "03", NA))
#' @family geography detectors
#' @export
is_state_fips <- function(x) {
  x <- as.character(x)
  out <- grepl("^\\d{2}$", x) & (x %in% .state_fips)
  out[is.na(x)] <- NA
  out
}

#' Is it a county FIPS code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 5-digit code with a valid state prefix.
#' @examples
#' is_county_fips(c("06037", "36061", "99001", NA))
#' @family geography detectors
#' @export
is_county_fips <- function(x) .fips_of_width(x, 5)

#' Is it a census tract FIPS code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for an 11-digit code with a valid state prefix.
#' @examples
#' is_tract_fips(c("06037206200", NA))
#' @family geography detectors
#' @export
is_tract_fips <- function(x) .fips_of_width(x, 11)

#' Is it a census block-group FIPS code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 12-digit code with a valid state prefix.
#' @examples
#' is_block_group_fips(c("060372062001", NA))
#' @family geography detectors
#' @export
is_block_group_fips <- function(x) .fips_of_width(x, 12)

#' Is it a census block FIPS code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 15-digit code with a valid state prefix.
#' @examples
#' is_block_fips(c("060372062001001", NA))
#' @family geography detectors
#' @export
is_block_fips <- function(x) .fips_of_width(x, 15)

#' Is it an NCES locale code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 2-digit NCES locale code (11-13, 21-23,
#'   31-33, 41-43 = City/Suburb/Town/Rural x Large/Midsize/Small).
#' @examples
#' is_nces_locale(c("11", "23", "44", NA))
#' @family geography detectors
#' @export
is_nces_locale <- function(x) {
  x <- as.character(x)
  out <- grepl("^[1-4][1-3]$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it an urban/rural designation?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for common urban/rural designation words.
#' @examples
#' is_urban_rural(c("Urban", "rural", "Suburban", "banana", NA))
#' @family geography detectors
#' @export
is_urban_rural <- function(x) {
  labels <- c("urban", "rural", "suburban", "suburb", "exurban", "exurb",
              "metropolitan", "metro", "micropolitan", "city", "town",
              "village", "hamlet")
  x <- as.character(x)
  out <- tolower(trimws(x)) %in% labels
  out[is.na(x)] <- NA
  out
}

#' Is it a CBSA code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 5-digit Core Based Statistical Area
#'   code in the Census delineation (`.cbsa` lookup).
#' @examples
#' is_cbsa(c("10180", "35620", "99999", NA))
#' @family geography detectors
#' @export
is_cbsa <- function(x) {
  x <- as.character(x)
  out <- grepl("^\\d{5}$", x) & (x %in% .cbsa)
  out[is.na(x)] <- NA
  out
}

#' Is it a CSA code?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a 3-digit Combined Statistical Area code
#'   in the Census delineation (`.csa` lookup).
#' @examples
#' is_csa(c("101", "408", "999", NA))
#' @family geography detectors
#' @export
is_csa <- function(x) {
  x <- as.character(x)
  out <- grepl("^\\d{3}$", x) & (x %in% .csa)
  out[is.na(x)] <- NA
  out
}

#' Is it a metropolitan-area name?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a CBSA or CSA title (e.g.
#'   `"New York-Newark-Jersey City, NY-NJ-PA"`), matched case-insensitively
#'   against the `.metro_area_names` lookup. The lookup stores both the full
#'   title and a state-suffix-stripped variant, so `"Corpus Christi, TX"` and
#'   `"Corpus Christi"` both match.
#' @details Exact-match on official Census titles; free-form metro names
#'   (`"NYC metro"`) will miss. Distinct from [is_city_name()], which won't
#'   match these hyphenated multi-city titles.
#' @examples
#' is_metro_area_name(c("Abilene-Sweetwater, TX", "Chicago", NA))
#' @family geography detectors
#' @export
is_metro_area_name <- function(x) {
  x <- as.character(x)
  norm <- gsub("\\s+", " ", tolower(trimws(x)))
  out <- norm %in% .metro_area_names
  out[is.na(x)] <- NA
  out
}

#' Is it a US census region or division?
#'
#' @param x A character vector.
#' @return Logical vector; `TRUE` for a census region (Northeast/Midwest/South/
#'   West) or one of the nine census divisions.
#' @examples
#' is_census_region(c("Northeast", "Pacific", "banana", NA))
#' @family geography detectors
#' @export
is_census_region <- function(x) {
  labels <- c("northeast", "midwest", "south", "west",
              "new england", "middle atlantic", "east north central",
              "west north central", "south atlantic", "east south central",
              "west south central", "mountain", "pacific")
  x <- as.character(x)
  out <- tolower(trimws(x)) %in% labels
  out[is.na(x)] <- NA
  out
}
