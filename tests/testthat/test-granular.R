demo_dgf <- function() build_demo_dgf()

emits <- function(expr) {
  out <- suppressMessages(suppressWarnings(utils::capture.output(expr)))
  length(out) > 0
}

test_that("dg_ element helpers render the right piece per type", {
  dgf <- demo_dgf()
  expect_true(emits(dg_stats(dgf, "num")))
  expect_true(emits(dg_properties(dgf, "num")))
  expect_true(emits(dg_quantiles(dgf, "num")))
  expect_true(emits(dg_preview(dgf, "num")))
  expect_true(emits(dg_preview(dgf, "notes")))     # character
  expect_true(emits(dg_levels(dgf, "cat")))        # factor
  expect_true(emits(dg_field(dgf, "num", "vlabel")))
})

test_that("dg_section renders a full section for one variable", {
  dgf <- demo_dgf()
  out <- suppressMessages(suppressWarnings(
    utils::capture.output(dg_section(dgf, "cat"))))
  expect_true(any(grepl("parent", out)))
  expect_true(any(grepl("LEVELS", out)))
})

test_that("dg_graphic runs for each type without error", {
  dgf <- demo_dgf()
  pdf(NULL)                       # a null device so no plot file is written
  on.exit(dev.off(), add = TRUE)
  for (v in c("num", "cat", "flag", "notes")) {
    expect_error(
      suppressMessages(suppressWarnings(
        utils::capture.output(dg_graphic(dgf, v)))),
      NA)
  }
})

test_that("granular helpers give clear errors for bad input", {
  dgf <- demo_dgf()
  expect_error(dg_stats(dgf, "NOPE"), "not found")
  expect_error(dg_quantiles(dgf, "cat"), "numeric")
  expect_error(dg_preview(dgf, "cat"), "numeric and character")
})

test_that("get_xx errors when no variable context is set", {
  datagoodr:::set_xx(NULL)
  expect_error(datagoodr:::get_xx(), "context")
  # a granular call sets it again
  dgf <- demo_dgf()
  suppressMessages(suppressWarnings(
    utils::capture.output(dg_stats(dgf, "num"))))
  expect_equal(datagoodr:::get_xx()[["VNAME"]], "num")
})
