# The datagoodr() wrapper copies its report template out of the installed
# package. It previously pointed at inst/qmd-templates/, which was removed in
# the reconciliation, so system.file() returned "" and the copy failed silently.
# The first test guards that path specifically; the second runs the whole
# workflow.

test_that("packaged templates resolve by name", {
  for (f in c("RG.qmd", "DD.qmd", "DG.R", "datagoodr.css")) {
    p <- system.file("templates", f, package = "datagoodr")
    expect_true(nzchar(p), info = paste("templates/", f, " did not resolve", sep = ""))
    expect_true(file.exists(p))
  }
})

test_that("datagoodr() runs the whole workflow and names output after rg.name", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("quarto")), "quarto CLI not available")

  root <- tempfile("dg-wrapper")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)

  csv <- file.path(root, "demo.csv")
  utils::write.csv(make_demo_df(), csv, row.names = FALSE)

  suppressMessages(suppressWarnings(utils::capture.output(
    datagoodr(
      wd = root,
      folder.name = "proj",
      path.raw.data = csv,
      create.dgf.params = list(use.df.types = FALSE, guess.factors = TRUE),
      rg.name = "my-guide"
    )
  )))

  proj <- file.path(root, "proj")

  # DGF written to the DGF/ subdirectory
  expect_true(file.exists(file.path(proj, "DGF", "DGF-V1.xlsx")))
  expect_true(file.exists(file.path(proj, "DGF", "DGF-V1.csv")))

  # rg.name reaches the rendered output (quarto names output after its input)
  html <- file.path(proj, "research-guide", "my-guide.html")
  expect_true(file.exists(html))

  # and the report is styled, i.e. datagoodr.css made it into the page
  expect_true(any(grepl("dg-serif", readLines(html, warn = FALSE))))
})
