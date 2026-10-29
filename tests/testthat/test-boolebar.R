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

test_that("a curated level dictionary names the categories on the bar", {
  dgf <- build_demo_dgf()
  i   <- match("flag", dgf$var_name)

  # curate the levels the way a user would in Excel (or data-raw/example-guides.R)
  dgf$dd_f_levels[i] <- datagoodr:::jsonify_df(
    data.frame(level = c("yes", "no"), label = c("in force", "lapsed")))

  xx <- datagoodr:::.rail_context(dgf)[["flag"]]
  set_xx(xx)
  expect_equal(datagoodr:::.level_labels(c("yes", "no")), c("in force", "lapsed"))

  # a level with no entry keeps its code -- which is what leaves NA alone,
  # since the dictionary describes the data's levels and not missingness
  expect_equal(datagoodr:::.level_labels(c("yes", "NA")), c("in force", "NA"))
})

test_that("an uncurated dictionary leaves the codes alone", {
  dgf <- build_demo_dgf()
  xx  <- datagoodr:::.rail_context(dgf)[["flag"]]
  set_xx(xx)
  # seeded labels equal their codes, so there is nothing to say twice
  expect_equal(datagoodr:::.level_labels(c("yes", "no")), c("yes", "no"))
})

test_that("ordering still reads the codes, not the curated labels", {
  # "1 (straight)" is not a word .bool_is_true() knows, so a bar built from
  # curated labels must still have been ordered on the codes beneath them
  o <- datagoodr:::.boolebar_order(c("0", "1"), c(18, 14))
  expect_equal(c("0", "1")[o], c("1", "0"))
})

test_that("booleplot fits long category names instead of clipping them", {
  # curated labels are far longer than the codes the left margin was sized
  # for; before this they ran off the device edge ("...V-shaped)")
  long <- c(`0 (V-shaped, inline six)` = 18, `1 (straight, inline four)` = 14)
  expect_silent(draw(booleplot(long)))

  # and the short case is untouched
  expect_silent(draw(booleplot(c(yes = 41, no = 19))))
})
