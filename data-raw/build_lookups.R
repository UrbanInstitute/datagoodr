## data-raw/build_lookups.R
## -------------------------------------------------------------------------
## Builds internal lookup tables that detectors need but users never call, and
## stores them in R/sysdata.rda (internal, non-exported, lazy-loaded into the
## namespace). Larger reference lists live here rather than inline in the
## detector source.
##
## IMPORTANT: sysdata.rda holds ALL internal objects together, so this script
## LOADS the existing objects (the layout.* design tables) and re-saves them
## alongside the new lookups -- never overwrite sysdata.rda with only the new
## object.
##
## Run from the package root after changing a lookup source:
##   Rscript data-raw/build_lookups.R
## -------------------------------------------------------------------------

## --- ISO 3166-1 alpha-2 country codes (source: ISOcodes, build-time only) ---
if (!requireNamespace("ISOcodes", quietly = TRUE)) {
  stop("Install the 'ISOcodes' package to build the country-code lookup.")
}
.iso3166_alpha2 <- sort(unique(ISOcodes::ISO_3166_1$Alpha_2))

## --- US city/place names (source: maps::us.cities, build-time only) ---------
## Normalized for exact matching: strip the trailing state abbrev, lowercase,
## keep letters and spaces only, dedupe. No stemming (see conversation): exact
## normalized membership, with a possible fuzzy slow-tier pass added later.
if (!requireNamespace("maps", quietly = TRUE)) {
  stop("Install the 'maps' package to build the city-name lookup.")
}
.us_cities <- {
  city <- sub(" [A-Z]{2}$", "", maps::us.cities$name)
  norm <- tolower(trimws(city))
  norm <- gsub("[^a-z ]", "", norm)
  sort(unique(norm[nzchar(norm)]))
}

## --- CBSA / CSA codes (source: Census 2023 delineation, cbsa1_2023.xlsx) -----
## Both codes live in "List 1". CSA is blank for micropolitan/standalone CBSAs.
cbsa_raw <- suppressWarnings(suppressMessages(
  readxl::read_excel("data-raw/cbsa1_2023.xlsx", sheet = 1, skip = 2)))
.cbsa <- {
  v <- unique(as.character(cbsa_raw[["CBSA Code"]]))
  v[grepl("^[0-9]{5}$", v)]
}
.csa <- {
  v <- unique(as.character(cbsa_raw[["CSA Code"]]))
  v[!is.na(v) & grepl("^[0-9]{3}$", v)]
}
## Metro-area NAMES (CBSA + CSA titles), normalized. Store the full title and
## a state-suffix-stripped variant so "New York-Newark-Jersey City, NY-NJ-PA"
## and "New York-Newark-Jersey City" both match.
.metro_area_names <- {
  titles <- unique(c(cbsa_raw[["CBSA Title"]], cbsa_raw[["CSA Title"]]))
  titles <- titles[!is.na(titles) & nzchar(titles)]
  no_state <- sub(",\\s*[A-Za-z.-]+$", "", titles)
  nrm <- function(s) gsub("\\s+", " ", tolower(trimws(s)))
  sort(unique(c(nrm(titles), nrm(no_state))))
}

## --- NAICS codes at all levels (source: 2022_NAICS_Index_File.xlsx) ----------
## The index lists 6-digit codes; roll them up so 2-6 digit codes all validate.
naics_raw <- suppressWarnings(suppressMessages(
  readxl::read_excel("data-raw/2022_NAICS_Index_File.xlsx", sheet = 1)))
.naics <- {
  c6 <- unique(as.character(naics_raw[[1]]))
  c6 <- c6[grepl("^[0-9]{6}$", c6)]
  sort(unique(unlist(lapply(2:6, function(k) substr(c6, 1, k)))))
}

## --- valid US state/territory FIPS codes (anchor for the FIPS hierarchy) -----
## Most states come from maps::state.fips; union in the gaps (AK, HI) and the
## territories so the anchor is complete without emitting a long literal.
.state_fips <- sort(unique(c(
  sprintf("%02d", maps::state.fips$fips),  # 50 states + DC (a couple missing)
  "02", "15",                              # Alaska, Hawaii (if absent above)
  "60", "66", "69", "72", "78"             # AS, GU, MP, PR, VI territories
)))

## --- merge with existing internal objects and re-save -----------------------
e <- new.env()
load("R/sysdata.rda", envir = e)
assign(".iso3166_alpha2", .iso3166_alpha2, envir = e)
assign(".us_cities", .us_cities, envir = e)
assign(".state_fips", .state_fips, envir = e)
assign(".cbsa", .cbsa, envir = e)
assign(".csa", .csa, envir = e)
assign(".metro_area_names", .metro_area_names, envir = e)
assign(".naics", .naics, envir = e)
save(list = ls(e, all.names = TRUE), envir = e,
     file = "R/sysdata.rda", version = 2)

cat("sysdata.rda objects:", length(ls(e, all.names = TRUE)), "\n")
cat("country codes stored:", length(.iso3166_alpha2), "\n")
cat("city names stored:", length(.us_cities), "\n")
cat("state FIPS stored:", length(.state_fips), "\n")
cat("CBSA / CSA stored:", length(.cbsa), "/", length(.csa), "\n")
cat("NAICS codes stored:", length(.naics), "\n")
