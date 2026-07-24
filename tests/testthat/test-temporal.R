# The temporal type: rough date detection, a unit-independent frequency table at
# build time, and a unit-driven graphic chosen at render. Changing the unit in
# the DGF re-charts without a rebuild - the property tested last.

dt <- function(...) datagoodr:::detect_temporal(...)

test_that("detect_temporal catches dates and rejects non-dates", {
  expect_true(dt(c("2015-01-01", "2016-06-15", "2017-12-31")))
  expect_true(dt(as.Date("2020-01-01") + 0:9))
  expect_true(dt(c("01/15/2015", "06/30/2016")))          # m/d/Y
  expect_false(dt(1:20))                                  # bare numbers (would-be years)
  expect_false(dt(paste("note", 1:5)))                    # free text
  expect_false(dt(rep(c("A", "B"), 5)))
})

test_that("create_dgf detects a date column as temporal with unit=date", {
  set.seed(1)
  dts <- format(seq(as.Date("2015-01-01"), as.Date("2016-12-31"), by = "day"), "%Y-%m-%d")
  raw <- data.frame(event_date = sample(dts, 200, replace = TRUE),
                    amount = round(rnorm(200, 100, 10), 2),
                    stringsAsFactors = FALSE)
  dgf <- suppressMessages(suppressWarnings(
    { utils::capture.output(d <- create_dgf(raw, file = tempfile("dgf"), open = FALSE)); d }))
  i <- dgf$var_name == "event_date"
  expect_equal(dgf$desired_data_type[i], "temporal")
  expect_equal(dgf$stable_data_unit[i], "date")           # default unit
  # graphic payload is a value/count table
  tab <- datagoodr:::json_to_df(dgf$rg_graphics[i])
  expect_true(all(c("Value", "Count") %in% names(tab)))
})

test_that("a date the detector library catches but detect_temporal misses is reconciled", {
  # "1-Jul-14" is a valid date, but detect_temporal()'s numeric formats miss it;
  # is_abbr_month_date() catches it. The enrichment must promote it to temporal
  # AND reconcile the profile + unit, so it is NOT left with a character-path
  # wordcloud graphic and a blank unit (the pre-reconciliation bug).
  expect_false(datagoodr:::detect_temporal(c("1-Jul-14", "15-Mar-16", "3-Jan-15")))
  d   <- c("1-Jul-14","15-Mar-16","3-Jan-15","21-Nov-12","9-Feb-13",
           "30-Jun-16","2-Aug-15","5-Sep-11","19-Oct-10","7-Dec-17")
  raw <- data.frame(evt = rep(d, 5), n = seq_len(50), stringsAsFactors = FALSE)
  dgf <- suppressMessages(suppressWarnings(
    { utils::capture.output(x <- create_dgf(raw, file = tempfile("dgf"), open = FALSE)); x }))
  i <- dgf$var_name == "evt"
  expect_equal(dgf$desired_data_type[i], "temporal")
  expect_equal(dgf$stable_data_unit[i], "date")            # reconciled unit
  # profile reconciled to the temporal path: a value/count table, not a wordcloud
  tab <- datagoodr:::json_to_df(dgf$rg_graphics[i])
  expect_true(all(c("Value", "Count") %in% names(tab)))
})

test_that("the temporal graphic renders for every unit", {
  mk <- function(v) {
    tt <- table(v)
    datagoodr:::jsonify_df(data.frame(Value = names(tt), Count = as.integer(tt),
                                      stringsAsFactors = FALSE))
  }
  set.seed(1)
  dts <- format(seq(as.Date("2015-01-01"), as.Date("2016-12-31"), by = "day"), "%Y-%m-%d")
  cases <- list(
    date  = mk(sample(dts, 300, replace = TRUE)),
    hour  = mk(sample(0:23, 400, replace = TRUE)),
    week  = mk(sample(1:52, 400, replace = TRUE)),
    month = mk(sample(month.abb, 300, replace = TRUE)),
    dow   = mk(sample(c("Mon","Tue","Wed","Thu","Fri"), 300, replace = TRUE)),
    year  = mk(sample(1990:2020, 400, replace = TRUE)))
  units <- c(date="date", hour="hour", week="week", month="month", dow="dow", year="year")

  for (k in names(cases)) {
    datagoodr:::set_xx(list(rg_graphics = cases[[k]], stable_data_unit = units[[k]]))
    grDevices::png(tempfile(fileext = ".png"))
    err <- tryCatch({ datagoodr:::paste_temporal_graphic("rg_graphics"); NULL },
                    error = function(e) conditionMessage(e))
    grDevices::dev.off()
    expect_null(err, info = paste("unit", k))
  }
})

test_that("a blank unit falls back to a bar chart without error", {
  tt <- table(sample(2010:2015, 100, replace = TRUE))
  g <- datagoodr:::jsonify_df(data.frame(Value = names(tt), Count = as.integer(tt),
                                         stringsAsFactors = FALSE))
  datagoodr:::set_xx(list(rg_graphics = g, stable_data_unit = ""))
  png(tempfile(fileext = ".png"))
  expect_error(datagoodr:::paste_temporal_graphic("rg_graphics"), NA)
  grDevices::dev.off()
})

test_that("changing the unit re-charts from the same build-time data", {
  # the elegant property: the frequency table is unit-independent, so retyping
  # the unit changes the chart with no rebuild. Here we just confirm both a
  # numeric-unit and the date-unit path accept the SAME payload.
  tt <- table(c("2015-01-01","2015-01-01","2016-06-15"))
  g <- datagoodr:::jsonify_df(data.frame(Value = names(tt), Count = as.integer(tt),
                                         stringsAsFactors = FALSE))
  for (u in c("date", "")) {
    datagoodr:::set_xx(list(rg_graphics = g, stable_data_unit = u))
    png(tempfile(fileext = ".png"))
    expect_error(datagoodr:::paste_temporal_graphic("rg_graphics"), NA, info = u)
    grDevices::dev.off()
  }
})

test_that("temporal is a renderable class with a layout", {
  expect_true("temporal" %in% datagoodr:::.dgf_valid_classes)
  expect_true("temporal" %in% get_design("rg")$TYPE)
})
