# Rule guards: an as_* rule is guarded by whether it can actually parse the data.
# check_dgf_rules() reports the miss rate per rule; apply_rule_col() warns inline
# when a rule does not fit (the is_* guard, realized via parse success).

test_that("check_dgf_rules confirms a fitting rule and flags a stale one", {
  raw <- data.frame(founded = c("3/15/2020", "1/2/2019", "12/31/2021"),
                    stringsAsFactors = FALSE)
  dgf <- suppressMessages(suppressWarnings(
    { utils::capture.output(d <- create_dgf(raw, file = tempfile("dgf"), open = FALSE)); d }))
  dgf$raw_to_stable_transform[dgf$var_name == "founded"] <- "as_mmddyyyy"

  ok <- check_dgf_rules(dgf, raw)
  expect_equal(ok$rule, "as_mmddyyyy")
  expect_equal(ok$stage, "reformat")
  expect_true(all(ok$fits))                       # rule parses the mm/dd/yyyy data

  # same rule, but the data is now ISO -> as_mmddyyyy no longer parses -> flagged
  iso <- data.frame(founded = c("2020-03-15", "2019-01-02", "2021-12-31"),
                    stringsAsFactors = FALSE)
  bad <- check_dgf_rules(dgf, iso)
  expect_false(all(bad$fits))
  expect_gt(bad$miss_rate[1], 0.2)
})

test_that("apply_rule_col warns when a rule does not fit the column", {
  expect_warning(
    datagoodr:::apply_rule_col(c("apple", "banana", "cherry"),
                               "as_mmddyyyy", var = "fruit"),
    "did not fit")
})

test_that("update_dgf attaches stale_rules for curated rules that no longer fit", {
  raw <- data.frame(founded = c("3/15/2020", "1/2/2019", "12/31/2021"),
                    stringsAsFactors = FALSE)
  dgf <- suppressMessages(suppressWarnings(
    { utils::capture.output(d <- create_dgf(raw, file = tempfile("dgf"), open = FALSE)); d }))
  dgf$raw_to_stable_transform[dgf$var_name == "founded"] <- "as_mmddyyyy"

  iso <- data.frame(founded = c("2020-03-15", "2019-01-02", "2021-12-31"),
                    stringsAsFactors = FALSE)
  u <- suppressMessages(suppressWarnings(
    { utils::capture.output(x <- update_dgf(dgf, iso, file = tempfile("d2"),
                                            verbose = FALSE, open = FALSE)); x }))
  stale <- attr(u, "stale_rules")
  expect_true(!is.null(stale) && nrow(stale) == 1)
  expect_equal(stale$var_name, "founded")
  expect_false(stale$fits)
})

test_that("check_dgf_rules ignores variables without rules", {
  raw <- data.frame(x = c("a", "b"), stringsAsFactors = FALSE)
  dgf <- suppressMessages(suppressWarnings(
    { utils::capture.output(d <- create_dgf(raw, file = tempfile("dgf"), open = FALSE)); d }))
  expect_equal(nrow(check_dgf_rules(dgf, raw)), 0)
})
