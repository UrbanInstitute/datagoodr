test_that("create_dgf returns one row per variable with the expected columns", {
  df  <- make_demo_df()
  dgf <- build_demo_dgf(df)

  expect_s3_class(dgf, "data.frame")
  expect_equal(nrow(dgf), ncol(df))
  expect_true(all(c("var_name", "desired_data_type", "rg_properties",
                    "rg_stats", "rg_graphics", "prov_current_hash") %in% names(dgf)))
})

test_that("create_dgf includes the metadata/schema columns", {
  dgf <- build_demo_dgf()
  # the six prefix families are all present
  expect_true(all(c("dd_vlabel", "raw_data_type", "desired_data_type",
                    "desired_data_class", "dd_data_unit",
                    "rg_max_chr", "validate_rules", "prov_current_hash")
                  %in% names(dgf)))
  # rg_max_chr is the max character width
  expect_true(is.numeric(dgf$rg_max_chr) || all(grepl("^[0-9]+$", dgf$rg_max_chr)))
})

test_that("dd_f_levels captures a two-column level/label dictionary", {
  dgf <- build_demo_dgf()
  # 'cat' is a factor with levels A, B, C
  lv <- dgf$dd_f_levels[dgf$var_name == "cat"]
  expect_true(validate_json(lv))
  tab <- jsonlite::fromJSON(lv)
  expect_setequal(names(tab), c("level", "label"))
  expect_setequal(tab$level, c("A", "B", "C"))
  expect_equal(tab$level, tab$label)   # label seeded to the code
})

test_that("create_dgf classifies each variable type correctly", {
  dgf <- build_demo_dgf()
  types <- setNames(dgf$desired_data_type, dgf$var_name)

  # desired_data_type is the ontology vocabulary
  expect_equal(unname(types["num"]),   "number")
  expect_equal(unname(types["cat"]),   "categorical")
  expect_equal(unname(types["flag"]),  "boolean")   # 2-level category -> boolean
  expect_equal(unname(types["notes"]), "text")
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

test_that("a type-changing stable_data_format on a numeric column does not break stats", {
  # dollarize() turns numbers into "$1,234" strings. The preview should show
  # the formatted values, but numeric stats/graphics must still be computed on
  # the underlying numbers (regression test for the get_stats_num crash).
  df <- data.frame(rev = c(0, 1000, 100, 250000, 2000, 55, 42000, 9))
  f  <- tempfile("dgf-fmt")
  expect_error(
    suppressMessages(suppressWarnings(
      capture.output(dgf <- create_dgf(df, stable_data_format = "dollarize", file = f))
    )),
    NA
  )
  expect_equal(dgf$desired_data_type, "number")
  expect_match(dgf$rg_preview, "\\$")             # preview is formatted
  expect_true(validate_json(dgf$rg_stats))        # numeric stats produced
})

test_that("read_as_text preserves zero-padded codes and long IDs, promotes safe numerics", {
  df <- data.frame(
    zip    = c("06037", "36061", "48201", "90210", "02139", "10001"),  # leading zero
    bigid  = c("1234567890123456", "2234567890123456", "3234567890123456",
               "4234567890123456", "5234567890123456", "6234567890123456"), # 16-digit
    amount = c("10.5", "22.1", "3.7", "88.0", "45.2", "7.9"),           # clean numeric
    stringsAsFactors = FALSE)
  dgf <- suppressMessages(suppressWarnings(
    { utils::capture.output(d <- create_dgf(df, file = tempfile("dgf"), open = FALSE)); d }))
  ty <- setNames(dgf$desired_data_type, dgf$var_name)

  # a zero-padded code is NOT promoted to number, and its leading zero survives
  expect_false(unname(ty["zip"]) == "number")
  expect_match(dgf$raw_first5[dgf$var_name == "zip"], "06037")
  # a 16-digit id stays text (past the double integer-safe range)
  expect_false(unname(ty["bigid"]) == "number")
  # a clean decimal column promotes to number
  expect_equal(unname(ty["amount"]), "number")
})
