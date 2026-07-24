## data-raw/datatypes/currency.R
## -------------------------------------------------------------------------
## Positive (valid) example values for the CURRENCY family, one vector per
## type. These are the raw fixtures the AutoType functions scramble into
## labelled valid/negative test cases (see data-raw/build_test_cases.R).
##
## Each vector name must match a type key in R/00-data-type-registry.R, and
## becomes the element name in the bundled `data_type_tests` object. To add a
## new family, drop a new data-raw/datatypes/<family>.R file, its detectors in
## R/dt-<family>.R, and one registry line per type, then re-run
## data-raw/build_test_cases.R.
##
## Provenance: seeded from the AutoType benchmark (Yan & He, SIGMOD'18),
## then cleaned and expanded for a representative sample. Cleaning notes are
## inline where a source value was invalid.
## -------------------------------------------------------------------------


## ==========================================================================
## Currency
## ==========================================================================

## currency_code -- ISO 4217 alpha-3 codes (source: currency.txt).
## Cleaned: source "ORN" is not an ISO 4217 code (typo for "ERN",
## Eritrean Nakfa) and was corrected. Expanded across regions/reserve
## currencies for coverage.
currency_code <- c(
  "AUD", "CAD", "CNY", "DKK", "EUR", "HKD", "INR", "JPY", "RUB", "THB",
  "SGD", "SEK", "USD", "TRY", "ERN", "GBP", "CHF", "NZD", "MXN", "BRL",
  "ZAR", "KRW", "NOK", "PLN", "AED", "SAR", "IDR", "PHP", "MYR", "ILS"
)

## currency_symbol -- leading symbol + amount, <= 2 decimals
## (source: currency2.txt). Symbols: $ euro yen pound. Expanded to cover
## whole amounts, one/two decimals, small and large magnitudes.
currency_symbol <- c(
  "$12.30", "€299.10", "¥19", "£1222", "$1", "€21",
  "¥22", "£1.10", "$100", "€3000", "¥998", "$2",
  "$444", "$111", "$0.99", "€5.50", "£49.99", "$1000000",
  "¥5000", "€12.34", "$75", "£100", "€0.50", "$3.14",
  "¥250"
)

## currency_code_symbol -- ISO code + symbol + amount, <= 2 decimals
## (source: currency3.txt). Cleaned: source "CNH" (offshore RMB market
## code) is not ISO 4217 and was corrected to "CNY". Prefix must be a real
## ISO code; symbol is one of $ euro yen pound.
currency_code_symbol <- c(
  "USD$12.30", "EUR€299.10", "USD$1", "EUR€21", "JPY¥22",
  "GBP£1222", "AUD$100", "EUR€3000", "CNY¥998", "GBP£1.10",
  "USD$100", "CAD$2", "CAD$444", "USD$111", "NZD$50", "SGD$75.25",
  "HKD$300", "USD$0.99", "EUR€1000", "JPY¥5000", "GBP£10",
  "AUD$1.50", "USD$999999", "CHF$42.00", "MXN$250"
)
