# render_record() answers "what produced this HTML?" without leaking who or
# where. Two things carry the weight: the privacy default, and a hash that is
# about the DGF's content rather than its bytes or its reader.

grab <- function(expr) {
  out <- utils::capture.output(expr)
  paste(out, collapse = "\n")
}


# ---- the privacy contract -------------------------------------------------

test_that("the default record leaks neither username nor absolute paths", {
  dgf <- build_demo_dgf()
  abs <- file.path(tempdir(), "some-project", "DGF.xlsx")   # absolute on purpose

  rec <- render_record(dgf, dgf_file = abs, visible = FALSE)

  # no identity fields at all
  expect_false(any(c("user", "host", "dgf_path", "data_path") %in% names(rec)))

  # the absolute path is reduced to its file name
  expect_equal(rec$dgf_file, "DGF.xlsx")

  # and nothing in the serialized record contains the username or a drive path
  flat <- paste(unlist(rec), collapse = " ")
  expect_false(grepl(Sys.info()[["user"]], flat, fixed = TRUE))
  expect_false(grepl("^[A-Za-z]:", flat))
  expect_false(grepl(tempdir(), flat, fixed = TRUE))
})

test_that("a relative path is kept - it is scoped to the project and useful", {
  dgf <- build_demo_dgf()
  rec <- render_record(dgf, dgf_file = "data/DGF-V2.xlsx")
  expect_equal(rec$dgf_file, "data/DGF-V2.xlsx")
})

test_that("identify = TRUE opts into user, host and absolute paths", {
  dgf <- build_demo_dgf()
  rec <- render_record(dgf, dgf_file = "DGF.xlsx", identify = TRUE)
  expect_true(all(c("user", "host", "dgf_path") %in% names(rec)))
  expect_equal(rec$user, unname(Sys.info()[["user"]]))
})


# ---- the hash is about content, not bytes and not the reader --------------

test_that("hash is stable across two saves of identical DGF content", {
  # .xlsx embeds timestamps, so the FILE hash changes on every re-save. The
  # record must not inherit that or it answers nothing.
  dgf <- build_demo_dgf()
  f1 <- tempfile(fileext = ".xlsx"); f2 <- tempfile(fileext = ".xlsx")
  suppressMessages(save_to_excel(dgf, f1, open = FALSE))
  Sys.sleep(1.1)
  suppressMessages(save_to_excel(dgf, f2, open = FALSE))

  expect_false(identical(tools::md5sum(f1)[[1]], tools::md5sum(f2)[[1]]))  # the trap

  h1 <- render_record(load_dgf(f1))$dgf_hash
  h2 <- render_record(load_dgf(f2))$dgf_hash
  expect_equal(h1, h2)
})

test_that("hash changes when the DGF's content changes", {
  dgf <- build_demo_dgf()
  other <- dgf
  other$dd_vdesc[1] <- "an edited description"
  expect_false(identical(render_record(dgf)$dgf_hash,
                         render_record(other)$dgf_hash))
})

test_that("the tibble/data.frame distinction does not enter the hash", {
  # same data, two containers: the hash should not notice. (rlang::hash does
  # notice, which is why hash_dgf() coerces first.)
  dgf <- build_demo_dgf()
  f <- tempfile(fileext = ".xlsx")
  suppressMessages(save_to_excel(dgf, f, open = FALSE))

  tb <- readxl::read_excel(f)          # a real tibble
  df <- as.data.frame(tb)              # same columns, plain data.frame
  expect_false(identical(class(tb), class(df)))
  expect_equal(names(tb), names(df))

  expect_equal(render_record(tb)$dgf_hash, render_record(df)$dgf_hash)
})

test_that("the hash describes the DGF as loaded, not the file", {
  # readxl and openxlsx genuinely disagree about a DGF's empty columns: readxl
  # infers an all-empty column as logical NA, openxlsx reads it as character.
  # So the same .xlsx read two ways is different data and hashes differently.
  # This is pinned deliberately - the record documents what the report rendered
  # from, and the templates always load the same way. It is not a file checksum.
  dgf <- build_demo_dgf()
  f <- tempfile(fileext = ".xlsx")
  suppressMessages(save_to_excel(dgf, f, open = FALSE))

  via_openxlsx <- load_dgf(f)
  via_readxl   <- readxl::read_excel(f)

  # the readers really do produce different data
  empty.cols <- names(via_openxlsx)[vapply(via_openxlsx,
                  function(x) all(is.na(x) | !nzchar(as.character(x))), logical(1))]
  skip_if(length(empty.cols) == 0, "no all-empty column in the demo DGF")
  expect_false(identical(class(via_openxlsx[[empty.cols[1]]]),
                         class(via_readxl[[empty.cols[1]]])))

  # ... and the hash follows the data, as documented
  expect_false(identical(render_record(via_openxlsx)$dgf_hash,
                         render_record(via_readxl)$dgf_hash))
})


# ---- shape of the emitted record ------------------------------------------

test_that("the record is emitted as an HTML comment, not visible content", {
  dgf <- build_demo_dgf()
  out <- grab(render_record(dgf, "DGF.xlsx"))
  expect_match(out, "<!-- datagoodr-render-record")
  expect_match(out, " -->")
  expect_false(grepl("RENDER RECORD", out))
})

test_that("visible = TRUE also prints a table", {
  dgf <- build_demo_dgf()
  out <- grab(render_record(dgf, "DGF.xlsx", visible = TRUE))
  expect_match(out, "<!-- datagoodr-render-record")   # comment still emitted
  expect_match(out, "RENDER RECORD")
  expect_match(out, "dgf_hash")
})

test_that("the record carries the fields provenance needs", {
  dgf <- build_demo_dgf()
  rec <- render_record(dgf, "DGF.xlsx")
  expect_true(all(c("datagoodr", "rendered_utc", "r", "dgf_hash",
                    "dgf_file", "dgf_variables") %in% names(rec)))
  expect_equal(rec$datagoodr, as.character(utils::packageVersion("datagoodr")))
  expect_equal(rec$dgf_variables, nrow(dgf))
  expect_match(rec$rendered_utc, "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$")
})

test_that("data_file is omitted when none was supplied", {
  dgf <- build_demo_dgf()
  expect_false("data_file" %in% names(render_record(dgf, "DGF.xlsx")))
  expect_equal(render_record(dgf, "DGF.xlsx", data_file = "raw.csv")$data_file,
               "raw.csv")
})

test_that("a filename containing --> cannot close the comment early", {
  dgf <- build_demo_dgf()
  out <- grab(render_record(dgf, dgf_file = "weird-->name.xlsx"))
  # exactly one comment close, at the end - the value did not spill into the page
  expect_equal(length(gregexpr(" -->", out, fixed = TRUE)[[1]]), 1L)
  expect_false(grepl("-->name", out, fixed = TRUE))
})


# ---- round trip through a real render -------------------------------------

test_that("the record survives a render and can be read back out of the HTML", {
  skip_on_cran()
  skip_if(!nzchar(Sys.which("quarto")), "quarto CLI not available")

  d <- tempfile("rec-proj"); dir.create(d)
  dgf <- build_demo_dgf()
  suppressMessages(suppressWarnings(utils::capture.output(
    create_rg(dgf = dgf, dir = d, file = "rg.qmd", render = TRUE, overwrite = TRUE)
  )))

  html <- file.path(d, "rg.html")
  expect_true(file.exists(html))

  rec <- read_render_record(html)
  expect_type(rec, "list")
  expect_equal(rec$dgf_file, "DGF.xlsx")
  expect_equal(rec$dgf_variables, nrow(dgf))

  # reproduce the hash the same way the template does (readxl), since the hash
  # describes the DGF as loaded - see "the hash describes the DGF as loaded"
  expect_equal(rec$dgf_hash,
               render_record(readxl::read_excel(file.path(d, "DGF.xlsx")))$dgf_hash)

  # the privacy contract holds in the actual shipped artifact
  flat <- paste(unlist(rec), collapse = " ")
  expect_false(grepl(Sys.info()[["user"]], flat, fixed = TRUE))
  expect_false(any(c("user", "dgf_path") %in% names(rec)))

  # and the record is invisible: it never reaches the rendered body text
  expect_false(grepl("RENDER RECORD", paste(readLines(html, warn = FALSE),
                                            collapse = "\n")))
})

test_that("read_render_record returns NULL for a file without a record", {
  f <- tempfile(fileext = ".html")
  writeLines("<html><body>no record here</body></html>", f)
  expect_null(read_render_record(f))
  expect_error(read_render_record(tempfile("nope")), "No such file")
})
