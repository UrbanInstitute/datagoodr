# retype_dgf() applies a user's type correction and re-profiles the variable, so
# the report renders it as the corrected type. This is the Step-1 -> Step-2 loop
# (create_dgf guesses, user corrects) made to actually work.

demo <- function() {
  set.seed(1)
  dts <- format(seq(as.Date("2015-01-01"), as.Date("2016-12-31"), by = "day"), "%Y-%m-%d")
  data.frame(
    founded_year = sample(1950:2015, 80, replace = TRUE),      # guessed number
    month_name   = sample(month.abb, 80, replace = TRUE),      # guessed categorical
    fips         = rep(c("06001", "36061"), 40),               # guessed identifier
    revenue      = round(rnorm(80, 1000, 50), 2),
    stringsAsFactors = FALSE
  )
}

build <- function(df = demo()) {
  suppressMessages(suppressWarnings(utils::capture.output(
    dgf <- create_dgf(df, file = tempfile("dgf"), open = FALSE)
  )))
  dgf
}

test_that("retype_dgf changes the type and unit of a variable", {
  df <- demo(); dgf <- build(df)
  out <- retype_dgf(dgf, df,
                    types = c(founded_year = "temporal"),
                    units = c(founded_year = "year"))
  i <- out$var_name == "founded_year"
  expect_equal(out$desired_data_type[i], "temporal")
  expect_equal(out$desired_data_class[i], "period.year")
})

test_that("retype_dgf re-profiles so the new graphic payload is present", {
  df <- demo(); dgf <- build(df)
  # month_name was guessed categorical (a treemap payload); retype to temporal
  before <- dgf$rg_graphics[dgf$var_name == "month_name"]
  out <- retype_dgf(dgf, df,
                    types = c(month_name = "temporal"),
                    units = c(month_name = "month"))
  after <- out$rg_graphics[out$var_name == "month_name"]
  expect_false(identical(before, after))                 # re-profiled
  # the temporal payload is a Value/Count table the graphic can read
  tab <- datagoodr:::json_to_df(after)
  expect_true(all(c("Value", "Count") %in% names(tab)))
})

test_that("a retyped temporal actually renders its graphic", {
  df <- demo(); dgf <- build(df)
  out <- retype_dgf(dgf, df,
                    types = c(founded_year = "temporal"),
                    units = c(founded_year = "year"))
  i <- match("founded_year", out$var_name)
  datagoodr:::set_xx(list(rg_graphics = out$rg_graphics[i],
                          desired_data_class = out$desired_data_class[i]))
  grDevices::png(tempfile(fileext = ".png"))
  err <- tryCatch({ datagoodr:::paste_temporal_graphic("rg_graphics"); NULL },
                  error = function(e) conditionMessage(e))
  grDevices::dev.off()
  expect_null(err)
})

test_that("retype_dgf leaves untouched variables verbatim", {
  df <- demo(); dgf <- build(df)
  out <- retype_dgf(dgf, df, types = c(founded_year = "temporal"),
                    units = c(founded_year = "year"))
  keep <- out$var_name != "founded_year"
  expect_equal(out[keep, ], dgf[keep, ])
})

test_that("retype_dgf warns on a variable not in the DGF or data", {
  df <- demo(); dgf <- build(df)
  expect_warning(retype_dgf(dgf, df, types = c(nope = "temporal")), "Not in DGF")
})

test_that("units-only retype needs no data re-profile", {
  df <- demo(); dgf <- build(df)
  # fips is already an identifier; give an unrelated var a unit without a type
  out <- retype_dgf(dgf, df, units = c(revenue = "year"))
  expect_equal(out$desired_data_class[out$var_name == "revenue"], "period.year")
})
