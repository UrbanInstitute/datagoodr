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


# --- date graphic: one image per variable (fixed 2026-10-27) ----------------
# A daily calendar for spans of up to 3 years, one calendar folding all years
# that, and always exactly one image.

test_that("parse_dates reads written-out month names", {
  d <- datagoodr:::parse_dates(c("Dec 27, 1981", "December 27, 1981",
                                 "27 Dec 1981", "27-Dec-1981", "1981-12-27"))
  expect_true(all(d == as.Date("1981-12-27")))
})

# draw the date graphic for dates in [from, to]; return the number of images
images_for_span <- function(from, to) {
  set.seed(1)
  d <- sample(seq(as.Date(from), as.Date(to), by = "day"), 500, replace = TRUE)
  tab <- as.data.frame(table(Value = format(d, "%b %d, %Y")), stringsAsFactors = FALSE)
  names(tab)[2] <- "Count"
  datagoodr:::set_xx(list(rg_graphics = as.character(jsonlite::toJSON(tab)),
                          desired_semantic_type = "temporal:date:calendar"))
  dir <- tempfile("cal"); dir.create(dir)
  grDevices::png(file.path(dir, "p%03d.png"))
  datagoodr:::paste_temporal_graphic("rg_graphics")
  grDevices::dev.off()
  length(list.files(dir, pattern = "\\.png$"))
}

test_that("one image for a single year, a 3-year span, and a long span", {
  skip_if_not_installed("lattice")
  expect_equal(images_for_span("2021-01-01", "2021-12-31"), 1)   # daily calendar
  expect_equal(images_for_span("2020-03-01", "2022-11-30"), 1)   # daily calendar
  expect_equal(images_for_span("1960-01-01", "2005-12-31"), 1)   # folded calendar
})
