test_that("get_design compiles layouts for all four variable types", {
  d <- get_design()
  expect_s3_class(d, "data.frame")
  expect_setequal(unique(d$TYPE),
                  c("numeric", "character", "factor", "logical"))
  expect_true(nrow(d) > 0)
})

test_that("create_all_sections renders markdown for each variable type", {
  dgf <- build_demo_dgf()

  for (ty in c("logical", "factor", "numeric", "character")) {
    sub <- dgf[dgf$vtype_class == ty, ]
    skip_if(nrow(sub) == 0)
    out <- suppressMessages(suppressWarnings(
      capture.output(create_all_sections(sub))
    ))
    # each section should emit a parent grid and a page break
    expect_true(any(grepl("parent", out)),
                info = paste("no parent div for type", ty))
    expect_true(any(grepl("pagebreak", out)),
                info = paste("no pagebreak for type", ty))
  }
})
