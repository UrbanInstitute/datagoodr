## data-raw/datatypes/geography.R
## Positive examples for the GEOGRAPHY family. FIPS codes are real Census
## GEOIDs (state prefix + hierarchy). NCES locale, urban/rural, and census
## region are the fixed vocabularies. CBSA/CSA and Census urban-area (UACE)
## codes need external lists and come in a later step.

state_fips <- c(
  "06", "36", "48", "17", "12", "04", "53", "25", "39", "01",
  "72", "02", "15", "11", "51", "37"
)

county_fips <- c(
  "06037", "36061", "48201", "17031", "12086", "04013", "53033", "06075",
  "25025", "39035", "01001", "72127", "51059", "37119", "48453", "06073"
)

tract_fips <- c(
  "06037206200", "36061014500", "17031839100", "48201100000", "12086001000",
  "06075010100", "25025000100", "53033001000", "04013010101", "39035101100"
)

block_group_fips <- c(
  "060372062001", "360610145001", "170318391001", "482011000001",
  "120860010001", "060750101001", "250250001001", "530330010001"
)

block_fips <- c(
  "060372062001001", "360610145001000", "170318391001002", "482011000001003",
  "120860010001000", "060750101001001", "250250001001004", "530330010001002"
)

cbsa <- c(
  "10100", "10140", "10180", "10220", "10300", "35620", "31080", "16980",
  "19100", "26420", "47900", "33100", "12060", "14460", "41860", "38060"
)

csa <- c(
  "101", "220", "364", "408", "348", "176", "206", "288", "548", "122",
  "148", "488"
)

metro_area_name <- c(
  "Aberdeen, SD", "Abilene, TX", "Akron, OH", "Athens-Clarke County, GA",
  "Corpus Christi, TX", "Iowa City, IA", "Abilene-Sweetwater, TX",
  "Portland-Vancouver-Salem, OR-WA", "Fort Wayne-Huntington-Auburn, IN",
  "Birmingham-Cullman-Talladega, AL", "Corpus Christi", "Iowa City"
)

nces_locale <- c(
  "11", "12", "13", "21", "22", "23", "31", "32", "33", "41", "42", "43"
)

urban_rural <- c(
  "Urban", "Rural", "Suburban", "Suburb", "Exurban", "Metropolitan",
  "Micropolitan", "City", "Town", "Village", "urban", "rural"
)

census_region <- c(
  "Northeast", "Midwest", "South", "West", "New England", "Middle Atlantic",
  "Pacific", "Mountain", "South Atlantic", "East North Central",
  "West South Central", "New England"
)
