# boolebar() draws a boolean variable as ONE bar divided into its categories,
# the compact guide's boolean graphic. These tests drive it on a null device:
# what matters is that every shape is placed without error, that degenerate
# input is refused rather than drawn wrong, and that no category goes
# unlabelled however narrow its part.

draw <- function(expr) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  force(expr)
}

test_that("boolebar draws the shapes it is given", {
  expect_silent(draw(boolebar(c(`TRUE` = 412, `FALSE` = 174, `NA` = 17))))
  expect_silent(draw(boolebar(c(yes = 41, no = 19))))          # 2 categories
  expect_silent(draw(boolebar(c(`TRUE` = 60))))                # 1 category
  # slivers: a part under a percent still has to be placed and labelled
  expect_silent(draw(boolebar(c(`TRUE` = 9880, `FALSE` = 110, `NA` = 10))))
})

test_that("boolebar refuses input it cannot draw", {
  expect_error(draw(boolebar(numeric(0))), "at least one value")
  expect_error(draw(boolebar(c(a = 1, b = NA))), "finite")
  expect_error(draw(boolebar(c(a = -1, b = 2))), "nonnegative")
  expect_error(draw(boolebar(c(a = 0, b = 0))), "nonzero")
})

test_that("an empty category is dropped rather than drawn at zero width", {
  expect_silent(draw(boolebar(c(`TRUE` = 50, `FALSE` = 0, `NA` = 50))))
})

test_that("categories are ordered true, false, missing", {
  o <- datagoodr:::.boolebar_order(c("NA", "FALSE", "TRUE"), c(5, 30, 65))
  expect_equal(c("NA", "FALSE", "TRUE")[o], c("TRUE", "FALSE", "NA"))

  # the stored labels are whatever the data said, so yes/no sorts the same way
  o <- datagoodr:::.boolebar_order(c("no", "yes"), c(19, 41))
  expect_equal(c("no", "yes")[o], c("yes", "no"))

  # an unrecognised pair falls back to frequency, missing still last
  o <- datagoodr:::.boolebar_order(c("NA", "b", "a"), c(1, 10, 20))
  expect_equal(c("NA", "b", "a")[o], c("a", "b", "NA"))
})

test_that("the font falls back rather than warning when it cannot be drawn", {
  # a family no device can resolve must not leak "font family not found"
  # warnings into the report, which is what knitr would print above the chart
  expect_silent(draw(boolebar(c(`TRUE` = 3, `FALSE` = 1),
                              family = "No Such Font At All")))
})

test_that("paste_boolebar draws from the DGF's graphics payload", {
  dgf <- build_demo_dgf()
  xx  <- datagoodr:::.rail_context(dgf)[["flag"]]
  set_xx(xx)
  out <- capture.output(draw(paste_boolebar("rg_graphics", "VALUES")))
  expect_true(any(grepl("**VALUES**", out, fixed = TRUE)))
})

test_that("the compact guide draws booleans as a bar, the default as a stack", {
  rg <- get_design()
  cp <- get_design(compact = TRUE)
  expect_true("paste_booleplot" %in% trimws(rg$FUNCTION))
  expect_false("paste_booleplot" %in% trimws(cp$FUNCTION))
  expect_true("paste_boolebar" %in% trimws(cp$FUNCTION))
})
