# Currency data-type detectors. Two layers of assertions:
#   * spot checks  -- seed-independent, pin the contract of each detector.
#   * fixture recall/precision -- run each detector over the frozen
#     data_type_tests fixture; positives must all pass, and the aggressive
#     mutation tiers (S3 random, SP scramble) must be rejected at a high rate.
# The S1 tier is intentionally NOT asserted: for loosely-structured types it
# mutates only digits and regenerates valid amounts (AutoType's Section 6
# caveat), so it is not a meaningful negative here.

test_that("is_currency_code is an ISO 4217 lookup", {
  expect_equal(is_currency_code(c("USD", "eur", "ZZZ")),
               c(TRUE, TRUE, FALSE))                 # case-insensitive lookup
  expect_true(is.na(is_currency_code(NA)))           # NA propagates
  expect_false(is_currency_code("US"))               # wrong length
})

test_that("is_currency_symbol checks symbol + bounded-decimal amount", {
  expect_true(all(is_currency_symbol(c("$12.30", "€299.10", "¥19", "£1222"))))
  expect_false(is_currency_symbol("$1,000"))         # no thousands separators
  expect_false(is_currency_symbol("$1.234"))         # at most two decimals
  expect_false(is_currency_symbol("$"))              # symbol needs an amount
  expect_false(is_currency_symbol("12.30"))          # amount needs a symbol
  expect_true(is.na(is_currency_symbol(NA)))
})

test_that("is_currency_code_symbol needs a real code, symbol, and amount", {
  expect_true(all(is_currency_code_symbol(c("USD$12.30", "EUR€299.10", "JPY¥22"))))
  expect_false(is_currency_code_symbol("ZZZ$1"))     # syntactic but not a real code
  expect_false(is_currency_code_symbol("USD 10"))    # missing symbol
  expect_false(is_currency_code_symbol("$12.30"))    # missing code
  expect_true(is.na(is_currency_code_symbol(NA)))
})

test_that("every valid fixture case passes its own detector (recall = 1)", {
  detectors <- list(
    currency_code        = is_currency_code,
    currency_symbol      = is_currency_symbol,
    currency_code_symbol = is_currency_code_symbol
  )
  for (nm in names(detectors)) {
    df <- data_type_tests[[nm]]
    valid <- df$case[df$label == "valid"]
    expect_true(all(detectors[[nm]](valid)),
                info = paste("valid cases rejected for", nm))
  }
})

test_that("aggressive negative tiers (S3, SP) are mostly rejected", {
  detectors <- list(
    currency_code        = is_currency_code,
    currency_symbol      = is_currency_symbol,
    currency_code_symbol = is_currency_code_symbol
  )
  for (nm in names(detectors)) {
    df <- data_type_tests[[nm]]
    for (tier in c("S3", "SP")) {
      cases <- df$case[df$label == tier]
      if (length(cases) == 0) next          # e.g. SP is empty for codes
      pass_rate <- mean(detectors[[nm]](cases), na.rm = TRUE)
      expect_lt(pass_rate, 0.15)            # near-zero leakage expected
    }
  }
})

test_that("guess_data_type picks the right type for a clean column", {
  expect_equal(guess_data_type(c("USD", "EUR", "JPY", "GBP", "CAD"))$guess,
               "currency_code")
  expect_equal(guess_data_type(c("$12.30", "€5.50", "£49.99", "¥5000"))$guess,
               "currency_symbol")
  expect_equal(guess_data_type(c("USD$1", "EUR€21", "JPY¥22"))$guess,
               "currency_code_symbol")
})

test_that("guess_data_type returns NA when nothing clears the threshold", {
  res <- guess_data_type(c("apple", "banana", "cherry"))
  expect_true(is.na(res$guess))
})
