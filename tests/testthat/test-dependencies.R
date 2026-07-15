# The report templates used to library() four packages that were in Suggests
# and used by no code at all (pointblank, gt, plotly, wordcloud2), so a correct
# minimal install could not render a report. These tests lock that shut.

desc_field <- function(f) {
  d <- read.dcf(system.file("DESCRIPTION", package = "datagoodr"))
  if (!f %in% colnames(d)) return(character())
  trimws(gsub("\\(.*?\\)", "", strsplit(d[1, f], ",")[[1]]))
}

test_that("templates attach datagoodr and nothing else", {
  for (t in c("RG.qmd", "DD.qmd")) {
    p <- system.file("templates", t, package = "datagoodr")
    skip_if(!nzchar(p))
    libs <- grep("library\\(", readLines(p, warn = FALSE), value = TRUE)
    attached <- gsub(".*library\\(\\s*([A-Za-z0-9._]+)\\s*\\).*", "\\1", libs)
    expect_equal(attached, "datagoodr",
                 info = paste(t, "should attach only datagoodr; got:",
                              paste(attached, collapse = ", ")))
  }
})

test_that("templates never attach a Suggested package", {
  sug <- desc_field("Suggests")
  for (t in c("RG.qmd", "DD.qmd")) {
    p <- system.file("templates", t, package = "datagoodr")
    skip_if(!nzchar(p))
    txt <- readLines(p, warn = FALSE)
    for (s in sug) {
      expect_false(any(grepl(paste0("library\\(\\s*", s, "\\s*\\)"), txt)),
                   info = paste(t, "attaches Suggested package", s,
                                "- breaks a minimal install"))
    }
  }
})

test_that("no NAMESPACE import of a Suggested package", {
  # An import() / importFrom() of a Suggests package forces it to load with
  # datagoodr, which defeats the point and fails R CMD check.
  ns <- readLines(system.file("NAMESPACE", package = "datagoodr"), warn = FALSE)
  imported <- gsub("^import\\(([^,)]+).*\\)$", "\\1",
                   grep("^import(From)?\\(", ns, value = TRUE))
  imported <- gsub('"', "", imported)
  expect_length(intersect(imported, desc_field("Suggests")), 0)
})

test_that("need_pkg() names the package and how to install it", {
  e <- tryCatch(datagoodr:::need_pkg("nosuchpkg", fn = "demo"),
                error = function(e) conditionMessage(e))
  expect_match(e, "nosuchpkg")
  expect_match(e, "demo", fixed = TRUE)
  expect_match(e, 'install.packages("nosuchpkg")', fixed = TRUE)

  # several missing packages are reported together, not one per failure
  e2 <- tryCatch(datagoodr:::need_pkg("nosuchpkg", "alsomissing", fn = "demo"),
                 error = function(e) conditionMessage(e))
  expect_match(e2, "nosuchpkg")
  expect_match(e2, "alsomissing")
  expect_match(e2, 'install.packages(c("nosuchpkg", "alsomissing"))', fixed = TRUE)

  # present packages pass silently
  expect_true(datagoodr:::need_pkg("stats", "utils"))
})

test_that("declared R version covers the syntax the package actually uses", {
  # the code uses |> (R >= 4.1); Depends must not promise less
  d <- read.dcf(system.file("DESCRIPTION", package = "datagoodr"))
  skip_if(!"Depends" %in% colnames(d))
  v <- numeric_version(gsub(".*?([0-9]+\\.[0-9]+(\\.[0-9]+)?).*", "\\1", d[1, "Depends"]))
  # expect_gte() does arithmetic, which numeric_version does not support
  expect_true(v >= numeric_version("4.1"),
              info = paste("Depends declares R", v, "but the code uses |> (R >= 4.1)"))
})
