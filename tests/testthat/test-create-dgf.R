test_that("create_dgf returns one row per variable with the expected columns", {
  df  <- make_demo_df()
  dgf <- build_demo_dgf(df)

  expect_s3_class(dgf, "data.frame")
  expect_equal(nrow(dgf), ncol(df))
  expect_true(all(c("vname", "vtype_class", "rg_properties",
                    "rg_stats", "rg_graphics", "rg_hash") %in% names(dgf)))
})

test_that("create_dgf includes the metadata/schema columns", {
  dgf <- build_demo_dgf()
  expect_true(all(c("vscope", "vloc", "vlength") %in% names(dgf)))
  # vscope/vloc default to blank, vlength is the max character width
  expect_true(all(dgf$vscope == ""))
  expect_true(is.numeric(dgf$vlength) || all(grepl("^[0-9]+$", dgf$vlength)))
})

test_that("dd_f_level captures a two-column level/label dictionary", {
  dgf <- build_demo_dgf()
  # 'cat' is a factor with levels A, B, C
  lv <- dgf$dd_f_level[dgf$vname == "cat"]
  expect_true(validate_json(lv))
  tab <- jsonlite::fromJSON(lv)
  expect_setequal(names(tab), c("level", "label"))
  expect_setequal(tab$level, c("A", "B", "C"))
  expect_equal(tab$level, tab$label)   # label seeded to the code
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

test_that("a type-changing vformat on a numeric column does not break stats", {
  # dollarize() turns numbers into "$1,234" strings. The preview should show
  # the formatted values, but numeric stats/graphics must still be computed on
  # the underlying numbers (regression test for the get_stats_num crash).
  df <- data.frame(rev = c(0, 1000, 100, 250000, 2000, 55, 42000, 9))
  f  <- tempfile("dgf-fmt")
  expect_error(
    suppressMessages(suppressWarnings(
      capture.output(dgf <- create_dgf(df, vformat = "dollarize", file = f))
    )),
    NA
  )
  expect_equal(dgf$vtype_class, "numeric")
  expect_match(dgf$rg_preview, "\\$")             # preview is formatted
  expect_true(validate_json(dgf$rg_stats))        # numeric stats produced
})
