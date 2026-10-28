# The research guide has two styles: "rail" (the default) and "vintage" (the
# original three-column grid). Each has its own template and stylesheet.

scaffold <- function(style = NULL) {
  d <- tempfile("rg-style"); dir.create(d)
  args <- list(dgf = build_demo_dgf(), dir = d, file = "rg.qmd",
               render = FALSE, overwrite = TRUE)
  if (!is.null(style)) args$style <- style
  suppressMessages(suppressWarnings(utils::capture.output(do.call(create_rg, args))))
  d
}

test_that("create_rg scaffolds the rail template by default", {
  d <- scaffold()
  txt <- readLines(file.path(d, "rg.qmd"), warn = FALSE)
  expect_true(any(grepl("rail_sections(", txt, fixed = TRUE)))
  css <- file.path(d, "datagoodr.css")
  expect_true(file.exists(css))
  expect_true(any(grepl(".dg-unit", readLines(css), fixed = TRUE)))
})

test_that("style = 'vintage' scaffolds the original grid", {
  d <- scaffold("vintage")
  txt <- readLines(file.path(d, "rg.qmd"), warn = FALSE)
  expect_true(any(grepl("create_all_sections(", txt, fixed = TRUE)))
  expect_true(any(grepl('datagoodr_css("vintage")', txt, fixed = TRUE)))
  expect_true(file.exists(file.path(d, "datagoodr-vintage.css")))
})

test_that("datagoodr_css picks the right sheet, and old projects keep theirs", {
  rail    <- datagoodr_css("rail")
  vintage <- datagoodr_css("vintage")
  expect_true(grepl(".dg-unit", rail, fixed = TRUE))
  expect_true(grepl(".parent", vintage, fixed = TRUE))
  expect_false(grepl(".dg-unit", vintage, fixed = TRUE))

  # an older project: a local datagoodr.css that is the vintage sheet
  d <- tempfile("old-proj"); dir.create(d)
  writeLines(c("/* my old styles */", ".parent { color: red; }"),
             file.path(d, "datagoodr.css"))
  owd <- setwd(d); on.exit(setwd(owd))
  expect_match(datagoodr_css(), "my old styles", fixed = TRUE)            # legacy call
  expect_match(datagoodr_css("vintage"), "my old styles", fixed = TRUE)   # still theirs
  expect_false(grepl("my old styles", datagoodr_css("rail"), fixed = TRUE)) # not for rail
})

test_that("rail_groups splits by render type in display order", {
  g <- rail_groups(build_demo_dgf())
  expect_named(g, c("Boolean", "Categorical", "Numeric", "Text",
                    "Identifier", "Temporal"))
  expect_true(all(vapply(g, is.data.frame, logical(1))))
})

test_that("rail sections render a unit per variable with rail and body", {
  dgf <- build_demo_dgf()
  g <- rail_groups(dgf)
  out <- suppressMessages(suppressWarnings(capture.output({
    rail_contents(g)
    for (k in names(g)) rail_sections(g[[k]], k)
  })))
  expect_equal(sum(startsWith(out, "::::: {.dg-unit")), nrow(dgf))
  expect_true(any(grepl("dg-rail", out, fixed = TRUE)))
  expect_true(any(grepl("dg-body", out, fixed = TRUE)))
  expect_true(any(grepl('class="toc"', out, fixed = TRUE)))
})
