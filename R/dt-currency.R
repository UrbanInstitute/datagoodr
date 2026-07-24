##############################
### Data type family: currency
###############################
## Detectors for the currency family. Each detector is a boolean predicate:
## character vector in -> logical vector out, NA-safe, never errors. The
## guessing (which type is this column?) happens in the aggregation layer,
## R/02-01-guess-data-type.R; these functions only answer "is this an X?".
##
## To add a family, drop an R/dt-<family>.R file with its is_*() detectors,
## a data-raw/datatypes/<family>.R file with its positive examples, and one
## line per type in R/00-data-type-registry.R.


#' ISO 4217 currency codes (alpha-3)
#'
#' Active alpha-3 currency codes from ISO 4217, used as the lookup table for
#' [is_currency_code()] and [is_currency_code_symbol()]. Family-local reference
#' data (kept beside the detectors that use it).
#'
#' @source ISO 4217 <https://www.iso.org/iso-4217-currency-codes.html>
#' @keywords internal
#' @noRd
iso4217_codes <- c(
  "AED","AFN","ALL","AMD","ANG","AOA","ARS","AUD","AWG","AZN","BAM","BBD","BDT",
  "BGN","BHD","BIF","BMD","BND","BOB","BRL","BSD","BTN","BWP","BYN","BZD","CAD",
  "CDF","CHF","CLP","CNY","COP","CRC","CUP","CVE","CZK","DJF","DKK","DOP","DZD",
  "EGP","ERN","ETB","EUR","FJD","FKP","GBP","GEL","GHS","GIP","GMD","GNF","GTQ",
  "GYD","HKD","HNL","HRK","HTG","HUF","IDR","ILS","INR","IQD","IRR","ISK","JMD",
  "JOD","JPY","KES","KGS","KHR","KMF","KPW","KRW","KWD","KYD","KZT","LAK","LBP",
  "LKR","LRD","LSL","LYD","MAD","MDL","MGA","MKD","MMK","MNT","MOP","MRU","MUR",
  "MVR","MWK","MXN","MYR","MZN","NAD","NGN","NIO","NOK","NPR","NZD","OMR","PAB",
  "PEN","PGK","PHP","PKR","PLN","PYG","QAR","RON","RSD","RUB","RWF","SAR","SBD",
  "SCR","SDG","SEK","SGD","SHP","SLE","SOS","SRD","SSP","STN","SYP","SZL","THB",
  "TJS","TMT","TND","TOP","TRY","TTD","TWD","TZS","UAH","UGX","USD","UYU","UZS",
  "VES","VND","VUV","WST","XAF","XCD","XOF","XPF","YER","ZAR","ZMW","ZWL"
)

#' Is it an ISO 4217 currency code?
#'
#' Tests whether each element is a valid three-letter ISO 4217 currency code
#' (e.g. `"USD"`, `"eur"`). Matching is case-insensitive.
#'
#' @param x A character vector of candidate values.
#'
#' @return A logical vector the same length as `x`: `TRUE` where the value is a
#'   valid ISO 4217 code, `FALSE` otherwise, `NA` where `x` is `NA`.
#'
#' @details A code-list lookup, not a syntactic check: `"ZZZ"` has the right
#'   shape but is not a real code and returns `FALSE`.
#'
#' @examples
#' is_currency_code(c("USD", "eur", "ZZZ", NA))
#' #> TRUE TRUE FALSE NA
#'
#' @seealso [is_currency_symbol()], [is_currency_code_symbol()], [guess_data_type()]
#' @family currency detectors
#' @export
is_currency_code <- function(x) {
  x <- as.character(x)
  out <- toupper(x) %in% iso4217_codes
  out[is.na(x)] <- NA
  out
}

#' Is it a currency symbol + amount?
#'
#' Tests whether each element is a currency symbol immediately followed by a
#' numeric amount with at most two decimals, e.g. `"$12.30"`, `"€299.10"`,
#' `"¥1222"`, `"£49.99"`. Recognised symbols are `$`, `€` (euro),
#' `¥` (yen), and `£` (pound).
#'
#' @param x A character vector of candidate values.
#'
#' @return A logical vector the same length as `x`: `TRUE` where the value
#'   matches the symbol+amount pattern, `FALSE` otherwise, `NA` where `x` is
#'   `NA`.
#'
#' @details Rejects thousands separators (`"$1,000"`), more than two decimals
#'   (`"$1.234"`), and a bare symbol (`"$"`). Extend the character class in the
#'   regex to admit more symbols.
#'
#' @examples
#' is_currency_symbol(c("$12.30", "¥1222", "$1,000", "$", NA))
#' #> TRUE TRUE FALSE FALSE NA
#'
#' @seealso [is_currency_code()], [is_currency_code_symbol()], [guess_data_type()]
#' @family currency detectors
#' @export
is_currency_symbol <- function(x) {
  x <- as.character(x)
  out <- grepl("^[$€¥£]\\d+(\\.\\d{1,2})?$", x)
  out[is.na(x)] <- NA
  out
}

#' Is it a currency code + symbol + amount?
#'
#' Tests whether each element is an ISO 4217 code immediately followed by a
#' currency symbol and a numeric amount with at most two decimals, e.g.
#' `"USD$12.30"`, `"EUR€299.10"`, `"JPY¥22"`, `"GBP£1222"`. The prefix
#' must be a real ISO 4217 code; the symbol must be one of `$`, `€`,
#' `¥`, `£`.
#'
#' @param x A character vector of candidate values.
#'
#' @return A logical vector the same length as `x`: `TRUE` where both the syntax
#'   matches and the prefix is a valid ISO 4217 code, `FALSE` otherwise, `NA`
#'   where `x` is `NA`.
#'
#' @details The code and symbol are not cross-checked for consistency (e.g.
#'   `"USD€10"` passes), because market data frequently pairs an offshore symbol
#'   with a settlement code.
#'
#' @examples
#' is_currency_code_symbol(c("USD$12.30", "ZZZ$1", "USD 10", NA))
#' #> TRUE FALSE FALSE NA
#'
#' @seealso [is_currency_code()], [is_currency_symbol()], [guess_data_type()]
#' @family currency detectors
#' @export
is_currency_code_symbol <- function(x) {
  x <- as.character(x)
  m <- regmatches(x, regexec("^([A-Z]{3})[$€¥£]\\d+(\\.\\d{1,2})?$", x))
  ok_syntax <- lengths(m) > 0
  code <- vapply(m, function(mm) if (length(mm) >= 2) mm[2] else NA_character_,
                 character(1))
  out <- ok_syntax & (code %in% iso4217_codes)
  out[is.na(x)] <- NA
  out
}
