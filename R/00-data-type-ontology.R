##############################
### Detector -> ontology crosswalk
###############################
## Maps each registered detector type to its ontology coordinates
##   c(data_type, data_subtype, data_class, data_format)
## per data-types/research_data_type_ontology_v2.csv. This is what lets
## guess_data_type() return an ontology-anchored answer instead of a bare
## detector name. Keyed by the same type names as .data_type_registry; add one
## line here when you add a detector.
##
## `.loose_detectors` marks types whose patterns fire broadly (phone, msisdn,
## bare numeric codes); guess_data_type() uses it to break pass-rate ties in
## favor of the more specific detector.


#' @keywords internal
#' @noRd
.data_type_ontology <- list(
  # currency
  currency_code        = c("categorical", "nominal",    "category",            "code"),
  currency_symbol      = c("number",      "continuous", "currency",            "currency"),
  currency_code_symbol = c("number",      "continuous", "currency",            "currency"),
  # web / network
  email = c("text", "token", "email",           "plain"),
  url   = c("text", "token", "url",             "plain"),
  ipv4  = c("text", "token", "network_address", "plain"),
  ipv6  = c("text", "token", "network_address", "plain"),
  mac   = c("text", "token", "network_address", "plain"),
  # color
  hex_color  = c("text", "token", "color", "hex"),
  rgb_color  = c("text", "token", "color", "rgb"),
  hsl_color  = c("text", "token", "color", "hsl"),
  cmyk_color = c("text", "token", "color", "cmyk"),
  # hash / uuid
  md5    = c("identifier", "hash_id", "record_id", "plain"),
  sha1   = c("identifier", "hash_id", "record_id", "plain"),
  sha256 = c("identifier", "hash_id", "record_id", "plain"),
  guid   = c("identifier", "text_id", "record_id", "plain"),
  # scientific / bio IDs
  ensembl_id = c("identifier",  "text_id", "entity_id",           "plain"),
  uniprot_id = c("identifier",  "text_id", "entity_id",           "plain"),
  icd9_code  = c("categorical", "nominal", "classification_code", "code"),
  icd10_code = c("categorical", "nominal", "classification_code", "code"),
  snp_id     = c("identifier",  "text_id", "entity_id",           "plain"),
  asin       = c("identifier",  "text_id", "administrative_id",   "plain"),
  bibcode    = c("identifier",  "text_id", "entity_id",           "plain"),
  # codes / lookups
  roman          = c("categorical", "ordinal", "ordered_category", "roman"),
  http_status    = c("categorical", "nominal", "category",         "code"),
  unix_time      = c("temporal",    "point",   "datetime",         "epoch"),
  zip_code       = c("categorical", "nominal", "geography",        "code"),
  uk_postcode    = c("categorical", "nominal", "geography",        "code"),
  ca_postal_code = c("categorical", "nominal", "geography",        "code"),
  us_state       = c("categorical", "nominal", "geography",        "code"),
  country_code   = c("categorical", "nominal", "geography",        "code"),
  # date / time (detector name -> data_format)
  iso_date         = c("temporal", "point",    "calendar_date", "yyyymmdd"),
  iso_datetime     = c("temporal", "point",    "timestamp",     "yyyymmddHHiiss"),
  us_date          = c("temporal", "point",    "calendar_date", "mmddyyyy"),
  us_datetime      = c("temporal", "point",    "timestamp",     "mmddyyyyhhiiA"),
  abbr_month_date  = c("temporal", "point",    "calendar_date", "dMyyyy"),
  rfc2822_datetime = c("temporal", "point",    "timestamp",     "rfc2822"),
  long_date        = c("temporal", "point",    "calendar_date", "long"),
  month_year       = c("temporal", "period",   "month",         "Myyyy"),
  month_day        = c("temporal", "point",    "calendar_date", "Md"),
  clock_time       = c("temporal", "point",    "time_of_day",   "hhii"),
  date_range       = c("temporal", "interval", "date_range",    "range"),
  hijri_date       = c("temporal", "point",    "calendar_date", "hijri"),
  # address
  street_address = c("text",        "line",    "address",   "plain"),
  po_box         = c("text",        "line",    "address",   "plain"),
  city_name      = c("categorical", "nominal", "geography", "label"),
  city_state     = c("categorical", "nominal", "geography", "label"),
  state_zip      = c("categorical", "nominal", "geography", "label"),
  address        = c("text",        "line",    "address",   "plain"),
  # geography
  # all FIPS default to categorical/geography; create_dgf() promotes to
  # identifier/geographic_id when % distinct is near-unique (a key, not a group)
  state_fips       = c("categorical", "nominal", "geography",      "code"),
  county_fips      = c("categorical", "nominal", "geography",      "code"),
  tract_fips       = c("categorical", "nominal", "geography",      "code"),
  block_group_fips = c("categorical", "nominal", "geography",      "code"),
  block_fips       = c("categorical", "nominal", "geography",      "code"),
  cbsa             = c("categorical", "nominal", "geography",      "code"),
  csa              = c("categorical", "nominal", "geography",      "code"),
  metro_area_name  = c("categorical", "nominal", "geography",      "label"),
  nces_locale      = c("categorical", "nominal", "category",       "code"),
  urban_rural      = c("categorical", "nominal", "category",       "label"),
  census_region    = c("categorical", "nominal", "geography",      "label"),
  # government / entity IDs
  ssn                 = c("identifier",  "numeric_id", "administrative_id",   "plain"),
  ein                 = c("identifier",  "numeric_id", "administrative_id",   "plain"),
  dea                 = c("identifier",  "text_id",    "administrative_id",   "plain"),
  chinese_resident_id = c("identifier",  "numeric_id", "administrative_id",   "plain"),
  uei                 = c("identifier",  "text_id",    "administrative_id",   "plain"),
  naics               = c("categorical", "nominal",    "classification_code", "code"),
  # phone
  phone      = c("text", "token", "phone", "plain"),
  intl_phone = c("text", "token", "phone", "plain"),
  msisdn     = c("text", "token", "phone", "plain"),
  # research / scholarly IDs
  doi   = c("identifier", "text_id",    "administrative_id", "plain"),
  orcid = c("identifier", "numeric_id", "administrative_id", "plain"),
  isbn  = c("identifier", "numeric_id", "administrative_id", "plain"),
  issn  = c("identifier", "numeric_id", "administrative_id", "plain"),
  npi   = c("identifier", "numeric_id", "administrative_id", "plain")
)

## Types whose detectors fire broadly (loose regex / short numeric codes).
## Used only as a tie-breaker: when two detectors tie on pass rate, the one
## NOT in this set wins.
## Types whose detectors are expensive (fuzzy/approximate matching). Run only
## as a fallback when no fast detector is confident. None yet -- the future
## fuzzy city/name matchers land here. Keeps the fast/slow cascade a no-op today.
#' @keywords internal
#' @noRd
.slow_detectors <- character(0)

#' @keywords internal
#' @noRd
.loose_detectors <- c("phone", "intl_phone", "msisdn", "unix_time",
                      "http_status", "roman", "state_fips", "county_fips",
                      "nces_locale", "us_state", "country_code")

#' Ontology coordinates for a detector type
#'
#' @param nm A registered type name (e.g. `"us_state"`).
#' @return A named character vector `c(data_type, data_subtype, data_class,
#'   data_format)`, or all-`NA` if the type is not mapped.
#' @keywords internal
#' @noRd
data_type_ontology <- function(nm) {
  v <- .data_type_ontology[[nm]]
  if (is.null(v)) v <- c(NA_character_, NA_character_, NA_character_, NA_character_)
  stats::setNames(v, c("data_type", "data_subtype", "data_class", "data_format"))
}
