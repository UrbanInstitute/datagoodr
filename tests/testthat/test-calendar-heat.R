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
# A daily calendar for spans of up to 3 years; longer spans show three years
# ("top3" or "spread") or fold all years onto one ("fold"); always one image.

test_that("parse_dates reads written-out month names", {
  d <- datagoodr:::parse_dates(c("Dec 27, 1981", "December 27, 1981",
                                 "27 Dec 1981", "27-Dec-1981", "1981-12-27"))
  expect_true(all(d == as.Date("1981-12-27")))
})

# draw the date graphic for dates in [from, to]; return the number of images
images_for_span <- function(from, to, calendar = "top3") {
  set.seed(1)
  d <- sample(seq(as.Date(from), as.Date(to), by = "day"), 500, replace = TRUE)
  tab <- as.data.frame(table(Value = format(d, "%b %d, %Y")), stringsAsFactors = FALSE)
  names(tab)[2] <- "Count"
  datagoodr:::set_xx(list(rg_graphics = as.character(jsonlite::toJSON(tab)),
                          desired_semantic_type = "temporal:date:calendar"))
  dir <- tempfile("cal"); dir.create(dir)
  grDevices::png(file.path(dir, "p%03d.png"))
  datagoodr:::paste_temporal_graphic("rg_graphics", calendar = calendar)
  grDevices::dev.off()
  length(list.files(dir, pattern = "\\.png$"))
}

test_that("one image for a single year, a 3-year span, and a long span", {
  skip_if_not_installed("lattice")
  expect_equal(images_for_span("2021-01-01", "2021-12-31"), 1)   # daily calendar
  expect_equal(images_for_span("2020-03-01", "2022-11-30"), 1)   # daily calendar
  for (m in c("top3", "spread", "fold"))
    expect_equal(images_for_span("1960-01-01", "2005-12-31", m), 1, info = m)
})

test_that("top3 picks the three busiest years, in year order", {
  by <- c(`1990` = 5, `1995` = 50, `2001` = 10, `2003` = 40, `2010` = 45)
  expect_equal(datagoodr:::.pick_calendar_years(by, "top3"), c(1995L, 2003L, 2010L))
})

test_that("spread picks one early, one middle and one late year, repeatably", {
  by <- setNames(rep(1, 30), 1981:2010)
  y1 <- datagoodr:::.pick_calendar_years(by, "spread", key = "debut")
  y2 <- datagoodr:::.pick_calendar_years(by, "spread", key = "debut")
  expect_identical(y1, y2)                       # same years on every render
  expect_true(y1[1] %in% 1981:1990)
  expect_true(y1[2] %in% 1991:2000)
  expect_true(y1[3] %in% 2001:2010)
  # the caller's random state is untouched
  set.seed(42); a <- runif(1)
  set.seed(42); invisible(datagoodr:::.pick_calendar_years(by, "spread", "x")); b <- runif(1)
  expect_equal(a, b)
})

test_that("three or fewer populated years are all shown", {
  by <- c(`1990` = 3, `2005` = 1)
  expect_equal(datagoodr:::.pick_calendar_years(by, "top3"), c(1990L, 2005L))
})

test_that("an unknown calendar mode falls back to top3 with a warning", {
  expect_warning(m <- datagoodr:::.calendar_mode("weekly"), "Unknown calendar mode")
  expect_equal(m, "top3")
})

test_that("calendar_heat draws only the requested years", {
  skip_if_not_installed("lattice")
  dts <- as.Date(c("1990-05-01", "2000-05-01", "2010-05-01"))
  dir <- tempfile("cal"); dir.create(dir)
  grDevices::png(file.path(dir, "p%03d.png"))
  p <- datagoodr:::calendar_heat(dts, c(1, 2, 3), years = c(1990, 2000, 2010))
  grDevices::dev.off()
  expect_equal(length(list.files(dir)), 1)
})

test_that("winsor caps both tails of the colour scale", {
  skip_if_not_installed("lattice")
  dts  <- seq(as.Date("2015-01-01"), as.Date("2015-12-31"), by = "day")
  vals <- c(rep(1:5, length.out = length(dts) - 1), 500)   # one extreme day
  dir <- tempfile("cal"); dir.create(dir)
  grDevices::png(file.path(dir, "p%03d.png"))
  p <- datagoodr:::calendar_heat(dts, vals, winsor = c(0.05, 0.95))
  grDevices::dev.off()
  # the plotted range stops at the 95th percentile, not at the outlier
  z <- p$panel.args.common$z
  if (is.null(z)) z <- lattice::trellis.last.object()$panel.args.common$z
  expect_true(max(z, na.rm = TRUE) < 500)
  expect_equal(max(z, na.rm = TRUE), unname(quantile(vals, 0.95)))
})
