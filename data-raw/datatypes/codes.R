## data-raw/datatypes/codes.R
## Positive examples for the SIMPLE CODES / LOOKUPS family. Seeded from the
## AutoType benchmark, expanded. Lookup lists (ISO country, US state) live in
## the detectors (R/dt-codes.R); these are just representative positives.

roman <- c(
  "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
  "XL", "L", "XC", "C", "CD", "D", "CM", "M", "MCMLXXXIV", "XXVII",
  "MMXXIV", "XLII"
)

http_status <- c(
  "100", "101", "200", "201", "202", "203", "204", "301", "302", "304",
  "400", "401", "403", "404", "418", "429", "500", "502", "503", "504"
)

unix_time <- c(
  "1513036980", "1503296497", "1451638800", "1360228214", "1497917283",
  "889664400", "219280260", "867781112", "1000000000", "1600000000",
  "1234567890", "946684800"
)

country_code <- c(
  "MA", "AR", "GR", "CD", "KP", "MT", "NO", "NR", "US", "GB", "FR", "DE",
  "JP", "CN", "IN", "BR", "ZA", "AU", "CA", "MX", "IT", "ES"
)

us_state <- c(
  "WA", "OH", "DC", "NY", "PA", "FL", "IL", "UT", "CA", "TX", "MA", "GA",
  "NC", "VA", "AZ", "CO", "MI", "WI", "OR", "MN", "TN", "MO"
)

zip_code <- c(
  "98052", "15206", "32792", "50613", "27292", "48640", "44512", "47150",
  "10001", "90210", "60601", "20500", "02139", "33101", "98052-6399", "10001-0001"
)

uk_postcode <- c(
  "SA43 2BU", "PO12 2DU", "KA20 3LN", "MK43 7TA", "DT4 8US", "SP4 0JF",
  "BS16 1FJ", "IV40 8AJ", "SW1A 1AA", "EC1A 1BB", "W1A 0AX", "M1 1AE"
)

ca_postal_code <- c(
  "V5K", "K0H", "T4A", "T4B", "T9S", "T1L", "T4X", "T2L",
  "K1A 0B1", "M5V 2T6", "H2Y 1C6", "V6B 4Y8"
)
