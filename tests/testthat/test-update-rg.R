# update_rg() re-renders an existing report against a different DGF/dataset
# WITHOUT editing it. The division of labour with create_rg() is the whole
# point: only the scaffolder writes to the qmd, update_rg() only passes
# execute_params. These tests pin both halves.

# Scaffold a report + a DGF in a throwaway dir. render = FALSE keeps these
# fast; the render path is exercised once, at the end.
scaffold <- function() {
  d <- tempfile("rg-proj"); dir.create(d)
  dgf <- build_demo_dgf()
  suppressMessages(suppressWarnings(utils::capture.output(
    qmd <- create_rg(dgf = dgf, dir = d, file = "rg.qmd",
                     render = FALSE, overwrite = TRUE)
  )))
  list(dir = d, qmd = file.path(d, "rg.qmd"))
}


# ---- create_rg(): bakes the path in, verifiably ---------------------------

test_that("create_rg bakes dgf_file into the document so it renders standalone", {
  p <- scaffold()
  declared <- datagoodr:::read_qmd_params(p$qmd)
  expect_equal(declared$dgf_file, "DGF.xlsx")
  expect_null(declared$data_file)          # declared, but null until supplied
})

test_that("create_rg(data =) bakes data_file too", {
  d <- tempfile("rg-data"); dir.create(d)
  csv <- file.path(d, "raw.csv")
  utils::write.csv(make_demo_df(), csv, row.names = FALSE)
  dgf <- build_demo_dgf()
  suppressMessages(suppressWarnings(utils::capture.output(
    create_rg(dgf = dgf, data = csv, dir = d, file = "rg.qmd", overwrite = TRUE)
  )))
  expect_equal(datagoodr:::read_qmd_params(file.path(d, "rg.qmd"))$data_file, csv)
})

test_that("the patch is verified, not hoped for", {
  # This is the file_name_placeholder lesson: a sub() against a missing anchor
  # silently does nothing. set_qmd_param() must refuse instead.
  p <- scaffold()
  txt <- readLines(p$qmd, warn = FALSE)
  writeLines(txt[!grepl("^\\s*dgf_file:", txt)], p$qmd)   # remove the anchor

  expect_error(datagoodr:::set_qmd_param(p$qmd, "dgf_file", "X.xlsx"),
               "found 0")
})

test_that("a Windows-style path survives the YAML round-trip", {
  # single-quoted YAML keeps backslashes literal; set_qmd_param re-parses to
  # confirm, so a quoting bug fails loudly rather than writing a broken path
  p <- scaffold()
  win <- "C:\\data\\my project\\DGF-V2.xlsx"
  datagoodr:::set_qmd_param(p$qmd, "dgf_file", win)
  expect_equal(datagoodr:::read_qmd_params(p$qmd)$dgf_file, win)
})


# ---- update_rg(): sentinel resolution -------------------------------------

test_that("DGF = 'in_qmd' uses the document's own value and overrides nothing", {
  p <- scaffold()
  ep <- update_rg(p$qmd, DGF = "in_qmd", CSV = "none", render = FALSE)
  expect_length(ep, 0)      # nothing overridden -> YAML defaults stand
})

test_that("CSV = 'in_qmd' errors when the document declares data_file: null", {
  p <- scaffold()
  expect_error(update_rg(p$qmd, CSV = "in_qmd", render = FALSE),
               "declares no `data_file`")
})

test_that("DGF = 'in_qmd' errors when the document declares no dgf_file", {
  p <- scaffold()
  txt <- readLines(p$qmd, warn = FALSE)
  writeLines(sub("^(\\s*)dgf_file:.*", "\\1dgf_file: null", txt), p$qmd)
  expect_error(update_rg(p$qmd, DGF = "in_qmd", render = FALSE),
               "declares no `dgf_file`")
})

test_that("a path overrides, and only the params passed appear", {
  p <- scaffold()
  other <- file.path(p$dir, "DGF-V2.xlsx")
  file.copy(file.path(p$dir, "DGF.xlsx"), other)

  ep <- update_rg(p$qmd, DGF = other, render = FALSE)
  expect_named(ep, "dgf_file")
  expect_equal(ep$dgf_file, other)

  csv <- file.path(p$dir, "raw.csv")
  utils::write.csv(make_demo_df(), csv, row.names = FALSE)
  ep2 <- update_rg(p$qmd, DGF = other, CSV = csv, render = FALSE)
  expect_named(ep2, c("dgf_file", "data_file"))
})

test_that("CSV = 'none' passes nothing", {
  p <- scaffold()
  ep <- update_rg(p$qmd, CSV = "none", render = FALSE)
  expect_false("data_file" %in% names(ep))
})

test_that("a missing override file errors before rendering", {
  p <- scaffold()
  expect_error(update_rg(p$qmd, DGF = "no-such-dgf.xlsx", render = FALSE),
               "file not found")
})

test_that("a real file named like a sentinel is caught, not swallowed", {
  p <- scaffold()
  old <- setwd(p$dir); on.exit(setwd(old), add = TRUE)
  file.create("none")
  expect_error(update_rg(p$qmd, CSV = "none", render = FALSE), "ambiguous")
  file.create("in_qmd")
  expect_error(update_rg(p$qmd, DGF = "in_qmd", render = FALSE), "ambiguous")
})

test_that("update_rg rejects a non-string sentinel", {
  p <- scaffold()
  expect_error(update_rg(p$qmd, DGF = NULL, render = FALSE), "must be a single string")
  expect_error(update_rg(p$qmd, DGF = c("a", "b"), render = FALSE), "must be a single string")
})

test_that("update_rg errors on a missing document", {
  expect_error(update_rg(tempfile("nope"), render = FALSE), "No such report document")
})


# ---- the anti-clobber guarantee -------------------------------------------

test_that("update_rg never modifies the document, even when rendering", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("quarto")), "quarto CLI not available")

  p <- scaffold()

  # a user edit that must survive
  txt <- readLines(p$qmd, warn = FALSE)
  writeLines(c(txt, "", "## A heading the user added by hand"), p$qmd)
  before <- tools::md5sum(p$qmd)[[1]]

  other <- file.path(p$dir, "DGF-V2.xlsx")
  file.copy(file.path(p$dir, "DGF.xlsx"), other)

  suppressMessages(suppressWarnings(utils::capture.output(
    update_rg(p$qmd, DGF = other, render = TRUE)
  )))

  expect_equal(tools::md5sum(p$qmd)[[1]], before)
  expect_true(any(grepl("A heading the user added by hand",
                        readLines(p$qmd, warn = FALSE))))
  expect_true(file.exists(file.path(p$dir, "rg.html")))
})
