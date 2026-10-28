# preflight_dgf(): find degenerate columns in seconds, before create_dgf() spends minutes.

finding <- function(pf, var, rule) pf[pf$var_name %in% var & pf$rule == rule, , drop = FALSE]

test_that("a clean dataset has no findings", {
  pf <- preflight_dgf(make_demo_df())
  expect_s3_class(pf, "dgf_preflight")
  expect_equal(nrow(pf), 0)
  expect_named(pf, c("var_name", "rule", "severity", "detail", "suggestion"))
  expect_equal(attr(pf, "n_rows"), 60); expect_equal(attr(pf, "n_cols"), 4)
  expect_output(print(pf), "no degenerate columns found")
})

test_that("each degenerate column is found, and ordinary columns are not", {
  pf <- preflight_dgf(degenerate_df())

  # single value: a constant, and one value plus blanks, are told apart
  expect_match(finding(pf, "const", "constant")$detail,  "every row is '2023'")
  expect_match(finding(pf, "flag_x", "single_value_with_blanks")$detail, "one value \\('X'\\) in 40 of 120 rows")
  expect_match(finding(pf, "flag_x", "single_value_with_blanks")$suggestion, "checkbox")
  expect_equal(nrow(finding(pf, "const", "single_value_with_blanks")), 0)   # the two cases do not overlap
  expect_equal(nrow(finding(pf, "flag_x", "constant")), 0)

  expect_equal(nrow(finding(pf, "empty", "all_missing")), 1)
  expect_equal(finding(pf, "notes", "long_values")$severity, "info")
  expect_match(finding(pf, "notes", "long_values")$detail, "longest 1500")
  expect_match(finding(pf, "bool_mix", "mixed_boolean_encoding")$detail, "4 ways")
  expect_match(finding(pf, "id_copy", "duplicate_column")$detail, "'id'")

  zero <- pf[pf$rule == "leading_zero_code", "var_name"]
  expect_true(all(c("id", "code", "id_copy") %in% zero))

  # ordinary columns raise nothing
  expect_false(any(pf$var_name %in% c("amount", "kind")))
})

test_that("blank means NA, empty or whitespace-only", {
  df <- data.frame(a = c("X", " ", "\t", "", NA, "  "), b = c("p", "q", "r", "s", "t", "u"))
  pf <- preflight_dgf(df)
  expect_match(finding(pf, "a", "single_value_with_blanks")$detail, "one value \\('X'\\) in 1 of 6 rows")
})

test_that("placeholders, non-finite numbers and over-cap timestamps are reported", {
  old <- options(datagoodr.temporal.max_values = 20L); on.exit(options(old), add = TRUE)
  n  <- 60
  df <- data.frame(
    phone = c(rep("0000000000", 2), sprintf("%010.0f", 5550000000 + seq_len(n - 2))),
    ratio = c("1.5", "Inf", "NaN", rep("2", n - 3)),
    ts    = format(as.POSIXct("2024-01-01", tz = "UTC") + seq(0, by = 3600 * 5, length.out = n), "%Y-%m-%dT%H:%M:%S"),
    stringsAsFactors = FALSE)
  pf <- preflight_dgf(df)

  expect_match(finding(pf, "phone", "placeholder_value")$detail, "2 row.*0000000000")
  expect_equal(finding(pf, "phone", "placeholder_value")$severity, "info")     # 5% of rows: under the warn bar
  expect_match(finding(pf, "ratio", "non_finite")$detail, "2 row")
  hc <- finding(pf, "ts", "high_cardinality_temporal")
  expect_equal(nrow(hc), 1)
  expect_match(hc$suggestion, "hour|day|minute")
})

test_that("findings are ordered errors, then warnings, then notes", {
  pf <- preflight_dgf(degenerate_df())
  expect_false(is.unsorted(match(pf$severity, c("error", "warn", "info"))))
  expect_true(all(pf$severity %in% c("error", "warn", "info")))
})

test_that("preflight_dgf reads a .csv path, as text", {
  csv <- tempfile(fileext = ".csv"); utils::write.csv(degenerate_df(), csv, row.names = FALSE)
  pf  <- preflight_dgf(csv)
  expect_true("leading_zero_code" %in% pf$rule)        # zeros survive only if read as text
  expect_error(preflight_dgf(42), "data frame")
})

test_that("print summarises findings by rule", {
  out <- utils::capture.output(print(preflight_dgf(degenerate_df())))
  expect_match(out[1], "^preflight_dgf: 10 columns, 120 rows")
  expect_true(any(grepl("\\[warn\\] constant: 1 column", out)))
  expect_true(any(grepl("\\[warn\\] single_value_with_blanks: 1 column", out)))
  expect_true(any(grepl("-> ", out)))
})

test_that("smoke_n runs the build on a sample and reports a failure by variable", {
  df <- degenerate_df()
  expect_false("smoke_test_failed" %in% preflight_dgf(df, smoke_n = 60)$rule)     # the fixed build survives

  testthat::local_mocked_bindings(
    create_dgf = function(...) stop("create_dgf(): statistics (factor) failed for variable 'kind': boom", call. = FALSE))
  pf <- preflight_dgf(df, smoke_n = 60)
  f  <- finding(pf, "kind", "smoke_test_failed")
  expect_equal(nrow(f), 1)
  expect_equal(f$severity, "error")
  expect_match(f$detail, "60-row sample.*boom")
  expect_equal(pf$severity[1], "error")                                           # errors sort first
})

test_that("smoke_n does not disturb the session's random numbers", {
  df <- degenerate_df()                              # (the fixture seeds the RNG itself: build it first)
  set.seed(123); invisible(runif(1)); state <- .Random.seed
  preflight_dgf(df, smoke_n = 40)
  expect_identical(.Random.seed, state)
})


# ---- create_dgf(preflight =) -----------------------------------------------------------------
test_that("create_dgf reports degenerate columns, keeps the findings, and still builds", {
  expect_message(
    suppressWarnings(utils::capture.output(
      dgf <- create_dgf(degenerate_df(), file = tempfile("pf"), open = FALSE))),
    "preflight: .* column\\(s\\) need attention .*constant x1")
  expect_s3_class(attr(dgf, "preflight"), "dgf_preflight")
  expect_true(all(c("constant", "single_value_with_blanks") %in% attr(dgf, "preflight")$rule))
  expect_equal(nrow(dgf), 10)
})

test_that("preflight = 'error' stops before any profiling, naming the columns", {
  expect_error(
    suppressMessages(utils::capture.output(
      create_dgf(degenerate_df(), file = tempfile("pf"), open = FALSE, preflight = "error"))),
    "preflight_dgf\\(\\) flagged .* column\\(s\\): .*const")
})

test_that("preflight = 'off' is silent and attaches nothing; clean data is silent by default", {
  expect_no_message(
    dgf <- quiet_dgf_noisy(degenerate_df(), preflight = "off"))
  expect_null(attr(dgf, "preflight"))

  expect_no_message(dgf2 <- quiet_dgf_noisy(make_demo_df()))
  expect_equal(nrow(attr(dgf2, "preflight")), 0)
  expect_error(create_dgf(make_demo_df(), preflight = "sometimes"), "should be one of")
})


# ---- errors name the variable ------------------------------------------------------------------
test_that("a profiling failure names the variable and the step", {
  testthat::local_mocked_bindings(get_stats = function(VNAME, df, VCLASS) stop("boom"))
  expect_error(
    suppressMessages(utils::capture.output(
      create_dgf(make_demo_df(), file = tempfile("pf"), open = FALSE, preflight = "off"))),
    "create_dgf\\(\\): statistics \\(.*\\) failed for variable '(num|cat|flag|notes)': boom")
})


test_that("a placeholder on a negligible share of rows is not reported", {
  n  <- 3000
  df <- data.frame(name = c("None", rep("Acme", n - 1)), site = c(rep("N/A", 600), rep("example.org", n - 600)),
                   stringsAsFactors = FALSE)
  pf <- preflight_dgf(df)
  expect_equal(nrow(finding(pf, "name", "placeholder_value")), 0)        # 1 of 3,000 rows (0.03%)
  hit <- finding(pf, "site", "placeholder_value")
  expect_equal(nrow(hit), 1)
  expect_equal(hit$severity, "warn")                                     # 20% of rows
})
