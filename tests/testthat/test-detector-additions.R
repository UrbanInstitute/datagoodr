# is_yyyymm (compact 6-digit YYYYMM year-month) and the relaxed is_ein (accepts a
# plain 9-digit form, with a 00-prefix / degenerate gate). Added when tax-period
# (YYYYMM) columns and bare 9-digit EINs were not being recognized.

test_that("is_yyyymm matches valid YYYYMM year-months only", {
  expect_equal(is_yyyymm(c("201912", "201301", "200006", "209912", "190001")),
               rep(TRUE, 5))
  expect_equal(is_yyyymm(c("201913", "201900", "20191", "2019", "189912", "abc")),
               rep(FALSE, 6))
  expect_true(is.na(is_yyyymm(NA)))
})

test_that("guess_data_type types a YYYYMM column as a monthly date", {
  g <- guess_data_type(c("201701", "201712", "201812", "201912", "201806"),
                       name = "tax_period_end")
  expect_equal(g$guess, "yyyymm")
  expect_equal(unname(g$ontology[["data_type"]]),  "temporal")
  expect_equal(unname(g$ontology[["data_class"]]), "month")
})

test_that("is_ein accepts dashed and plain 9-digit EINs; rejects 00-prefix and degenerate", {
  expect_true(all(is_ein(c("15-4464349", "154464349", "12-3456789"))))
  expect_false(is_ein("00-1234567"))   # 00 prefix is never issued
  expect_false(is_ein("000000000"))    # degenerate
  expect_false(is_ein("111111111"))    # degenerate
  expect_false(is_ein("1234567"))      # too short
  expect_true(is.na(is_ein(NA)))
})
