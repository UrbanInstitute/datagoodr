test_that("get_design compiles layouts for every renderable type", {
  d <- get_design()
  expect_s3_class(d, "data.frame")
  # TYPE is the ontology vocabulary (see dg_type_of / the schema)
  expect_setequal(unique(d$TYPE),
                  c("number", "text", "categorical", "boolean",
                    "identifier", "temporal"))
  expect_true(nrow(d) > 0)
})

test_that("create_all_sections renders markdown for each variable type", {
  dgf <- build_demo_dgf()

  for (ty in c("boolean", "categorical", "number", "text")) {
    sub <- dgf[dgf$desired_data_type == ty, ]
    skip_if(nrow(sub) == 0)
    out <- suppressMessages(suppressWarnings(
      capture.output(create_all_sections(sub))
    ))
    # each section should emit a parent grid and a page break
    expect_true(any(grepl("parent", out)),
                info = paste("no parent div for type", ty))
    expect_true(any(grepl("pagebreak", out)),
                info = paste("no pagebreak for type", ty))
    # DATA TYPE and MAX NCHAR are always populated. The ontology coordinate
    # rows (SUBTYPE/CLASS/FORMAT) render only when non-blank, so the generic
    # demo columns (no subtype/class/format) show just these two and omit the
    # empty attribute rows.
    expect_true(any(grepl("DATA TYPE", out)))
    expect_true(any(grepl("MAX NCHAR", out)))
    expect_false(any(grepl("SUBTYPE", out)))   # blank -> conditionally hidden
  }
})

test_that("factor sections render a LEVELS table and numeric sections STATS + quantiles", {
  dgf <- build_demo_dgf()

  fac <- suppressMessages(suppressWarnings(
    capture.output(create_all_sections(dgf[dgf$desired_data_type == "categorical", ]))))
  expect_true(any(grepl("LEVELS", fac)))

  num <- suppressMessages(suppressWarnings(
    capture.output(create_all_sections(dgf[dgf$desired_data_type == "number", ]))))
  # STATS carries the quantile columns with short labels (MIN/Q05/Q50/.../MAX);
  # Skew/Kurtosis render beneath it in the DISTRIBUTION SHAPE table
  expect_true(any(grepl("STATS", num)))
  expect_true(any(grepl("Q50", num)))
  expect_true(any(grepl("DISTRIBUTION SHAPE", num)))
})

test_that("ontology attribute rows render only when populated", {
  dgf <- build_demo_dgf()

  # a plain column carries no subtype/class/format -> those rows are omitted
  plain <- suppressMessages(suppressWarnings(
    capture.output(create_all_sections(dgf[dgf$var_name == "num", ]))))
  expect_true(any(grepl("DATA TYPE", plain)))
  expect_false(any(grepl("SUBTYPE", plain)))
  expect_false(any(grepl("FORMAT", plain)))

  # stamp the class.subclass coordinate on a column and it appears
  i <- dgf$var_name == "cat"
  dgf$desired_data_class[i] <- "mutually_exclusive.geographic"
  filled <- suppressMessages(suppressWarnings(
    capture.output(create_all_sections(dgf[i, ]))))
  expect_true(any(grepl("CLASS", filled)))
  expect_true(any(grepl("mutually_exclusive.geographic", filled)))
})
