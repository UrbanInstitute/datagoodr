test_that("create_dgf returns one row per variable with the expected columns", {
  df  <- make_demo_df()
  dgf <- build_demo_dgf(df)

  expect_s3_class(dgf, "data.frame")
  expect_equal(nrow(dgf), ncol(df))
  expect_true(all(c("vname", "vtype_class", "rg_properties",
                    "rg_stats", "rg_graphics", "rg_hash") %in% names(dgf)))
})

test_that("create_dgf classifies each variable type correctly", {
  dgf <- build_demo_dgf()
  types <- setNames(dgf$vtype_class, dgf$vname)

  expect_equal(unname(types["num"]),   "numeric")
  expect_equal(unname(types["cat"]),   "factor")
  expect_equal(unname(types["flag"]),  "logical")   # 2-level category -> logical
  expect_equal(unname(types["notes"]), "character")
})

test_that("create_dgf writes both .csv and .xlsx outputs", {
  f <- tempfile("dgf-out")
  suppressMessages(suppressWarnings(
    capture.output(create_dgf(make_demo_df(), file = f))
  ))
  expect_true(file.exists(paste0(f, ".csv")))
  expect_true(file.exists(paste0(f, ".xlsx")))
})

test_that("create_dgf stores valid JSON in the rg_ columns", {
  dgf <- build_demo_dgf()
  # rg_properties is populated for every variable and should be valid JSON
  expect_true(all(validate_json(dgf$rg_properties)))
})
