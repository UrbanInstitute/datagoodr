test_that("inspect_dgf accepts a freshly built DGF", {
  dgf <- build_demo_dgf()
  res <- suppressMessages(capture.output(out <- inspect_dgf(dgf)))
  expect_true(out$valid)
  expect_length(out$problems, 0)
})

test_that("inspect_dgf flags an unrenderable desired_data_type", {
  dgf <- build_demo_dgf()
  dgf$desired_data_type[1] <- "mystery"
  out <- inspect_dgf(dgf, verbose = FALSE)
  expect_false(out$valid)
  expect_true("invalid_vtype_class" %in% names(out$problems))
})

test_that("inspect_dgf flags invalid JSON cells", {
  dgf <- build_demo_dgf()
  dgf$rg_properties[1] <- "{ not : valid json ,, }"
  out <- inspect_dgf(dgf, verbose = FALSE)
  expect_false(out$valid)
  expect_true("invalid_json" %in% names(out$problems))
})

test_that("inspect_dgf flags undefined convert/format functions", {
  dgf <- build_demo_dgf()
  dgf$stable_data_format[1] <- "definitely_not_a_function"
  out <- inspect_dgf(dgf, verbose = FALSE)
  expect_false(out$valid)
  expect_true("missing_functions" %in% names(out$problems))
})

test_that("inspect_dgf flags missing required columns", {
  dgf <- build_demo_dgf()
  dgf$prov_current_hash <- NULL
  out <- inspect_dgf(dgf, verbose = FALSE)
  expect_false(out$valid)
  expect_true("missing_columns" %in% names(out$problems))
})

test_that("built-in format functions round-trip through the namespace", {
  expect_equal(as_EIN("542015951"), "542015951")
  expect_equal(as_EIN(12345), "000012345")
  expect_equal(as_mm(8), "08")
  expect_equal(as_yyyymm("201905"), "2019-05")
  expect_true(is.na(as_mm(NA)))
})
