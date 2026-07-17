# The calendar heatmap (ported from Paul Bleicher / Humedica, GPL-2+). It draws
# to the current device via lattice + grid; the tests confirm it runs for the
# input forms the temporal renderer feeds it.

test_that("calendar_heat renders for Date input", {
  skip_if_not_installed("lattice")
  skip_if_not_installed("grid")
  dts  <- seq(as.Date("2015-01-01"), as.Date("2015-12-31"), by = "day")
  vals <- seq_along(dts)
  png(tempfile(fileext = ".png"))
  expect_error(datagoodr:::calendar_heat(dts, vals, varname = "Test"), NA)
  grDevices::dev.off()
})

test_that("calendar_heat renders for character-date input and a colour variant", {
  skip_if_not_installed("lattice")
  skip_if_not_installed("grid")
  dts <- format(seq(as.Date("2015-01-01"), as.Date("2016-06-30"), by = "day"), "%Y-%m-%d")
  png(tempfile(fileext = ".png"))
  expect_error(
    datagoodr:::calendar_heat(dts, seq_along(dts), color = "r2b", varname = "X"), NA)
  grDevices::dev.off()
})

test_that("the attribution and licence notice are preserved in the source", {
  # the port must keep provenance - the user asked for this explicitly. Only
  # checkable against the source tree (skipped on an installed package).
  f <- test_path("..", "..", "R", "03-02-calendar-heat.R")
  skip_if(!file.exists(f), "source tree not available")
  txt <- paste(readLines(f, warn = FALSE), collapse = "\n")
  expect_match(txt, "Paul Bleicher")
  expect_match(txt, "Humedica")
  expect_match(txt, "GNU General Public License")
})
