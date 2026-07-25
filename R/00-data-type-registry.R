##############################
### Data type registry
###############################
## Single source of truth mapping each data type to its detector and a
## human-readable label. This is the one file that must be edited when a new
## type is added -- everything downstream (guess_data_type, the build script,
## the reports) reads from here.
##
## Detectors are referenced BY NAME (a string), not by value, so the registry
## does not depend on file load order: the is_*() functions in R/dt-<family>.R
## are resolved from the package namespace at call time, not when this list is
## evaluated.
##
## The type name (list key) must match the positive-example vector name in
## data-raw/datatypes/<family>.R, so the build script can pair them up.


#' Registry of data types
#'
#' @keywords internal
#' @noRd
.data_type_registry <- list(
  currency_code = list(
    detector = "is_currency_code",
    label    = "currency code (ISO 4217 lookup)"
  ),
  currency_symbol = list(
    detector = "is_currency_symbol",
    label    = "currency symbol + amount (regex, max 2 decimals)"
  ),
  currency_code_symbol = list(
    detector = "is_currency_code_symbol",
    label    = "currency code + symbol + amount (regex + lookup)"
  ),

  # web / network
  email = list(detector = "is_email", label = "email address"),
  url   = list(detector = "is_url",   label = "URL (http/https/ftp)"),
  ipv4  = list(detector = "is_ipv4",  label = "IPv4 address"),
  ipv6  = list(detector = "is_ipv6",  label = "IPv6 address"),
  mac   = list(detector = "is_mac",   label = "MAC address"),

  # color
  hex_color  = list(detector = "is_hex_color",  label = "hex color (#RRGGBB)"),
  rgb_color  = list(detector = "is_rgb_color",  label = "RGB triple (0-255)"),
  hsl_color  = list(detector = "is_hsl_color",  label = "HSL triple (H, S%, L%)"),
  cmyk_color = list(detector = "is_cmyk_color", label = "CMYK quadruple (0-1)"),

  # hash / uuid
  md5    = list(detector = "is_md5",    label = "MD5 digest (32 hex)"),
  sha1   = list(detector = "is_sha1",   label = "SHA-1 digest (40 hex)"),
  sha256 = list(detector = "is_sha256", label = "SHA-256 digest (64 hex)"),
  guid   = list(detector = "is_guid",   label = "GUID / UUID"),

  # scientific / bio identifiers
  ensembl_id = list(detector = "is_ensembl_id", label = "Ensembl gene/transcript ID"),
  uniprot_id = list(detector = "is_uniprot_id", label = "UniProt accession"),
  icd9_code  = list(detector = "is_icd9_code",  label = "ICD-9 code"),
  icd10_code = list(detector = "is_icd10_code", label = "ICD-10 code"),
  snp_id     = list(detector = "is_snp_id",     label = "dbSNP reference SNP ID"),
  asin       = list(detector = "is_asin",       label = "Amazon ASIN"),
  bibcode    = list(detector = "is_bibcode",    label = "ADS bibcode"),

  # simple codes / lookups
  roman           = list(detector = "is_roman",           label = "Roman numeral"),
  http_status     = list(detector = "is_http_status",     label = "HTTP status code"),
  unix_time       = list(detector = "is_unix_time",       label = "Unix timestamp (seconds)"),
  zip_code        = list(detector = "is_zip_code",        label = "US ZIP code"),
  uk_postcode     = list(detector = "is_uk_postcode",     label = "UK postcode"),
  ca_postal_code  = list(detector = "is_ca_postal_code",  label = "Canadian postal code / FSA"),
  us_state        = list(detector = "is_us_state",        label = "US state abbreviation"),
  country_code    = list(detector = "is_country_code",    label = "ISO 3166-1 country code"),

  # date / time
  iso_date         = list(detector = "is_iso_date",         label = "ISO 8601 date"),
  iso_datetime     = list(detector = "is_iso_datetime",     label = "ISO 8601 datetime"),
  us_date          = list(detector = "is_us_date",          label = "US numeric date (M/D/Y)"),
  us_datetime      = list(detector = "is_us_datetime",      label = "US numeric datetime (AM/PM)"),
  abbr_month_date  = list(detector = "is_abbr_month_date",  label = "day-month-year (abbrev. month)"),
  rfc2822_datetime = list(detector = "is_rfc2822_datetime", label = "RFC 2822 / HTTP datetime"),
  long_date        = list(detector = "is_long_date",        label = "verbose English date"),
  month_year       = list(detector = "is_month_year",       label = "Month Year"),
  yyyymm           = list(detector = "is_yyyymm",           label = "Year-month (YYYYMM)"),
  month_day        = list(detector = "is_month_day",        label = "Month Day (no year)"),
  clock_time       = list(detector = "is_clock_time",       label = "clock time"),
  date_range       = list(detector = "is_date_range",       label = "date range"),
  hijri_date       = list(detector = "is_hijri_date",       label = "Hijri (Islamic) date"),

  # address (atomic components + composite)
  street_address = list(detector = "is_street_address", label = "street address"),
  po_box         = list(detector = "is_po_box",         label = "PO box"),
  city_name      = list(detector = "is_city_name",      label = "US city / place name"),
  city_state     = list(detector = "is_city_state",     label = "City, State"),
  state_zip      = list(detector = "is_state_zip",      label = "State ZIP"),
  address        = list(detector = "is_address",        label = "full postal address"),

  # geography
  state_fips       = list(detector = "is_state_fips",       label = "state FIPS code"),
  county_fips      = list(detector = "is_county_fips",      label = "county FIPS code"),
  tract_fips       = list(detector = "is_tract_fips",       label = "census tract FIPS"),
  block_group_fips = list(detector = "is_block_group_fips", label = "census block-group FIPS"),
  block_fips       = list(detector = "is_block_fips",       label = "census block FIPS"),
  nces_locale      = list(detector = "is_nces_locale",      label = "NCES locale code"),
  cbsa             = list(detector = "is_cbsa",             label = "CBSA code"),
  csa              = list(detector = "is_csa",              label = "CSA code"),
  metro_area_name  = list(detector = "is_metro_area_name",  label = "metro-area name (CBSA/CSA title)"),
  urban_rural      = list(detector = "is_urban_rural",      label = "urban/rural designation"),
  census_region    = list(detector = "is_census_region",    label = "US census region/division"),

  # government / entity IDs
  ssn                 = list(detector = "is_ssn",                 label = "US Social Security Number"),
  ein                 = list(detector = "is_ein",                 label = "US Employer ID Number"),
  dea                 = list(detector = "is_dea",                 label = "DEA registration number"),
  chinese_resident_id = list(detector = "is_chinese_resident_id", label = "Chinese resident ID"),
  uei                 = list(detector = "is_uei",                 label = "SAM.gov UEI"),
  naics               = list(detector = "is_naics",               label = "NAICS industry code"),

  # phone
  phone      = list(detector = "is_phone",      label = "US/NANP phone number"),
  intl_phone = list(detector = "is_intl_phone", label = "international phone number"),
  msisdn     = list(detector = "is_msisdn",     label = "MSISDN subscriber number"),

  # research / scholarly IDs
  doi   = list(detector = "is_doi",   label = "DOI"),
  orcid = list(detector = "is_orcid", label = "ORCID iD"),
  isbn  = list(detector = "is_isbn",  label = "ISBN (10 or 13)"),
  issn  = list(detector = "is_issn",  label = "ISSN"),
  npi   = list(detector = "is_npi",   label = "US NPI (health provider)")
)

#' Resolve the registry into a named list of detector functions
#'
#' Looks each detector up by name in the package namespace, so the result is a
#' named list of live functions suitable for [score_data_type()].
#'
#' @param registry The registry list; defaults to the built-in one.
#'
#' @return A named list of detector functions, one per registered data type.
#' @keywords internal
#' @noRd
data_type_detectors <- function(registry = .data_type_registry) {
  ns <- topenv(environment())   # the datagoodr namespace when installed/loaded
  stats::setNames(
    lapply(registry, function(entry) get(entry$detector, envir = ns)),
    names(registry)
  )
}

#' Registry labels as a named character vector
#'
#' @param registry The registry list; defaults to the built-in one.
#' @return A named character vector of human-readable labels.
#' @keywords internal
#' @noRd
data_type_labels <- function(registry = .data_type_registry) {
  vapply(registry, function(entry) entry$label, character(1))
}
