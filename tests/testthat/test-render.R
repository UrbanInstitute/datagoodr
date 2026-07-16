test_that("get_design compiles layouts for all four variable types", {
  d <- get_design()
  expect_s3_class(d, "data.frame")
  # TYPE is now the ontology vocabulary (see dg_type_of / the schema)
  expect_setequal(unique(d$TYPE),
                  c("number", "string", "categorical", "boolean"))
  expect_true(nrow(d) > 0)
})

test_that("create_all_sections renders markdown for each variable type", {
  dgf <- build_demo_dgf()

  for (ty in c("boolean", "categorical", "number", "string")) {
    sub <- dgf[dgf$stable_data_type == ty, ]
    skip_if(nrow(sub) == 0)
    out <- suppressMessages(suppressWarnings(
      capture.output(create_all_sections(sub))
    ))
    # each section should emit a parent grid and a page break
    expect_true(any(grepl("parent", out)),
                info = paste("no parent div for type", ty))
    expect_true(any(grepl("pagebreak", out)),
                info = paste("no pagebreak for type", ty))
    # every type shows the retained descriptor fields (SCOPE / LOCATION CODE
    # were dropped from the layouts in the v2 schema)
    expect_true(any(grepl("DATA TYPE", out)))
    expect_true(any(grepl("LENGTH", out)))
    expect_true(any(grepl("DESCRIPTION", out)))
  }
})

test_that("factor sections render a LEVELS table and numeric sections STATS + quantiles", {
  dgf <- build_demo_dgf()

  fac <- suppressMessages(suppressWarnings(
    capture.output(create_all_sections(dgf[dgf$stable_data_type == "categorical", ]))))
  expect_true(any(grepl("LEVELS", fac)))

  num <- suppressMessages(suppressWarnings(
    capture.output(create_all_sections(dgf[dgf$stable_data_type == "number", ]))))
  # STATS carries the quantile columns with short labels (MIN/Q05/Q50/.../MAX)
  # plus SKEW/KURTOSIS (moved out of the PROPERTIES table)
  expect_true(any(grepl("STATS", num)))
  expect_true(any(grepl("Q50", num)))
  expect_true(any(grepl("SKEW", num)))
})
