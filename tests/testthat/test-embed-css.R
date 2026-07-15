# create_rg(embed_css = TRUE) writes the stylesheet into the document instead
# of calling datagoodr_css() at render, so a power user can edit the rules in
# place. The trade is that an embedded copy stops tracking the packaged CSS.

scaffold_css <- function(embed) {
  d <- tempfile("css-proj"); dir.create(d)
  dgf <- build_demo_dgf()
  suppressMessages(suppressWarnings(utils::capture.output(
    create_rg(dgf = dgf, dir = d, file = "rg.qmd", embed_css = embed,
              render = FALSE, overwrite = TRUE)
  )))
  list(dir = d, qmd = file.path(d, "rg.qmd"))
}

test_that("default keeps the runtime datagoodr_css() call", {
  p <- scaffold_css(embed = FALSE)
  txt <- readLines(p$qmd, warn = FALSE)
  expect_true(any(grepl("datagoodr_css\\(", txt)))
  expect_false(any(grepl("^```\\{css[ }]", txt)))
})

test_that("embed_css writes the stylesheet in and drops the runtime chunk", {
  p <- scaffold_css(embed = TRUE)
  txt <- readLines(p$qmd, warn = FALSE)

  # The runtime R chunk is gone. Check the chunk, not the string: the CSS's own
  # header comment mentions datagoodr_css(), so a text grep would match the
  # embedded comment and pass for the wrong reason.
  expect_false(any(grepl("^```\\{r[ ,].*datagoodr-style", txt)))
  expect_false(any(grepl("^\\s*cat\\(.*datagoodr_css\\(", txt)))
  # ... replaced by a css chunk ...
  expect_true(any(grepl("^```\\{css[ }]", txt)))
  # ... carrying the actual rules
  expect_true(any(grepl("--dg-serif", txt)))
  expect_true(any(grepl("\\.parent", txt)))
})

test_that("the embedded copy matches the packaged stylesheet", {
  p <- scaffold_css(embed = TRUE)
  txt <- readLines(p$qmd, warn = FALSE)
  start <- grep("^```\\{css[ }]", txt)
  fences <- grep("^```\\s*$", txt)
  end <- fences[fences > start][1]

  embedded <- txt[(start + 1):(end - 1)]
  embedded <- embedded[!grepl("^/\\* Embedded copy|^   embedded, it no longer", embedded)]

  packaged <- strsplit(datagoodr_css(), "\n", fixed = TRUE)[[1]]
  # every packaged rule should be present verbatim
  expect_setequal(intersect(packaged, embedded), packaged)
})

test_that("embed_css errors rather than half-writing if the anchor is gone", {
  # same lesson as the yaml patch: never rewrite and hope
  p <- scaffold_css(embed = FALSE)
  txt <- readLines(p$qmd, warn = FALSE)
  writeLines(txt[!grepl("datagoodr-style", txt)], p$qmd)
  expect_error(datagoodr:::embed_css_block(p$qmd), "found 0")
})

test_that("an embedded report renders and is styled", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("quarto")), "quarto CLI not available")

  d <- tempfile("css-render"); dir.create(d)
  dgf <- build_demo_dgf()
  suppressMessages(suppressWarnings(utils::capture.output(
    create_rg(dgf = dgf, dir = d, file = "rg.qmd", embed_css = TRUE,
              render = TRUE, overwrite = TRUE)
  )))

  html <- file.path(d, "rg.html")
  expect_true(file.exists(html))
  # the CSS reached the page even though the package was never called at render
  expect_true(any(grepl("dg-serif", readLines(html, warn = FALSE))))
})
