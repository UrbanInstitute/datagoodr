# Scaffolding a report writes the template straight to the requested filename.
# Regression: it used to copy to the flavor's default name and rename, which
# clobbered (then deleted) an unrelated report of that default name -- e.g.
# building research-guide-temporal-demo.qmd destroyed research-guide.qmd.

test_that("a custom-named report leaves a default-named one untouched", {
  d   <- file.path(tempfile("proj"))
  dir.create(d)
  dgf <- build_demo_dgf()

  # the default-named guide, then a user edit we can detect a clobber by
  suppressMessages(suppressWarnings(
    utils::capture.output(create_rg(dgf, dir = d, render = FALSE))))
  guide <- file.path(d, "research-guide.qmd")
  expect_true(file.exists(guide))
  writeLines(c(readLines(guide), "<!-- USER EDIT -->"), guide)

  # scaffold a DIFFERENTLY named guide in the same directory
  suppressMessages(suppressWarnings(
    utils::capture.output(
      create_rg(dgf, dir = d, file = "research-guide-temporal-demo.qmd",
                render = FALSE))))

  # the new one exists AND the original survives untouched (not renamed away)
  expect_true(file.exists(file.path(d, "research-guide-temporal-demo.qmd")))
  expect_true(file.exists(guide))
  expect_true(any(grepl("USER EDIT", readLines(guide))))
})

test_that("the overwrite guard applies to the requested file, not the default", {
  d   <- file.path(tempfile("proj"))
  dir.create(d)
  dgf <- build_demo_dgf()

  suppressMessages(suppressWarnings(
    utils::capture.output(create_rg(dgf, dir = d, render = FALSE))))  # research-guide.qmd

  # a different name is fine even though the default already exists
  expect_error(
    suppressMessages(suppressWarnings(
      utils::capture.output(create_rg(dgf, dir = d, file = "other.qmd",
                                      render = FALSE)))),
    NA)

  # re-scaffolding the SAME name without overwrite is refused
  expect_error(
    suppressMessages(suppressWarnings(
      utils::capture.output(create_rg(dgf, dir = d, render = FALSE)))),
    "already exists")
})
