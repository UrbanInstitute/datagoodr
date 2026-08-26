# as_* rule functions: the executable side of the format vocabulary. The compact
# label compiles to strptime and parses delimiter-agnostically, so one label
# (e.g. "mmddyyyy") covers /, -, and space separators, ordinals, and AM/PM.

test_that("read_date is delimiter-agnostic and order-aware", {
  expect_equal(read_mmddyyyy(c("3/15/2020", "03-15-2020", "3 15 2020")),
               as.Date(rep("2020-03-15", 3)))
  expect_equal(read_yyyymmdd("2020-03-15"), as.Date("2020-03-15"))
  expect_equal(read_ddmmyyyy("15/03/2020"), as.Date("2020-03-15"))
})

test_that("text months and ordinals parse", {
  expect_equal(read_Mdyyyy("Feb 4, 2020"),    as.Date("2020-02-04"))
  expect_equal(read_dMyyyy("4-Feb-2020"),     as.Date("2020-02-04"))
  expect_equal(read_Mdyyyy("Feb 4th, 2020"),  as.Date("2020-02-04"))  # ordinal
})

test_that("datetime labels carry time and convert 12h -> 24h", {
  dt <- read_mmddyyyyhhiiA("3/15/2020 2:30 PM")
  expect_s3_class(dt, "POSIXct")
  expect_equal(format(dt, "%Y-%m-%d %H:%M", tz = "UTC"), "2020-03-15 14:30")
})

test_that("the format label compiles to both strptime patterns", {
  # one label names the ELEMENT ORDER, not the punctuation, so it compiles to a
  # delimited pattern and a run-together one; read_date() picks per value.
  cf <- datagoodr:::.format_to_strptime("mmddyyyy")
  expect_equal(cf$delimited, "%m-%d-%Y")
  expect_equal(cf$packed,    "%m%d%Y")
  expect_false(cf$has_time)
  expect_true(datagoodr:::.format_to_strptime("HHii")$has_time)
})

test_that("a compact label reads both the delimited and run-together forms", {
  expect_equal(read_yyyymmdd("20190315"), as.Date("2019-03-15"))   # was NA
  expect_equal(read_yyyymmdd("2019-03-15"), as.Date("2019-03-15"))
  expect_equal(read_mmddyyyy(c("03/15/2019", "03152019")),
               as.Date(rep("2019-03-15", 2)))
})

test_that("as_id keeps identifiers as trimmed text (leading zeros survive)", {
  expect_equal(as_id(c(" 06037 ", "36061")), c("06037", "36061"))
  expect_type(as_id(6037L), "character")
})

test_that("unparseable values become NA, not errors", {
  expect_true(is.na(read_mmddyyyy("not a date")))
  expect_true(is.na(read_yyyymmdd(NA)))
})
