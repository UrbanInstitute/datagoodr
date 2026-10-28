# Excel caps a cell at 32,767 characters. save_to_excel() moves larger cells to
# a DGF_overflow sheet in parts; load_dgf() joins them back.

big_json <- function(n_rows) {
  tab <- data.frame(Value = sprintf("1990-01-%05d", seq_len(n_rows)), Count = seq_len(n_rows))
  as.character(jsonlite::toJSON(tab))
}

make_dgf <- function() {
  data.frame(var_name    = c("small", "huge", "also_huge"),
             rg_graphics = c("[]", big_json(4000), big_json(2500)),
             dd_vdesc    = c("a", "b", "c"),
             stringsAsFactors = FALSE)
}

test_that("oversized cells survive a save / load round trip", {
  dgf <- make_dgf()
  expect_true(all(nchar(dgf$rg_graphics[2:3]) > 32767))
  f <- tempfile(fileext = ".xlsx")
  save_to_excel(dgf, filename = f, open = FALSE)

  # the main sheet holds only short pointers; the parts are on their own sheet
  main <- openxlsx::read.xlsx(f, sheet = "DGF")
  expect_true(all(nchar(main$rg_graphics) <= 32767))
  expect_true("DGF_overflow" %in% openxlsx::getSheetNames(f))

  for (reader in c("openxlsx", "readxl")) {
    back <- load_dgf(f, reader = reader)
    expect_identical(back$rg_graphics, dgf$rg_graphics, info = reader)
    expect_true(jsonlite::validate(back$rg_graphics[2]), info = reader)
  }
})

test_that("a DGF with no oversized cells gets no overflow sheet", {
  f <- tempfile(fileext = ".xlsx")
  save_to_excel(data.frame(var_name = "x", rg_graphics = "[]"), filename = f, open = FALSE)
  expect_false("DGF_overflow" %in% openxlsx::getSheetNames(f))
  expect_equal(load_dgf(f)$rg_graphics, "[]")
})

test_that("a missing overflow sheet blanks the cell with a warning", {
  f <- tempfile(fileext = ".xlsx")
  save_to_excel(make_dgf(), filename = f, open = FALSE)
  wb <- openxlsx::loadWorkbook(f)
  openxlsx::removeWorksheet(wb, "DGF_overflow")
  openxlsx::saveWorkbook(wb, f, overwrite = TRUE)
  expect_warning(back <- load_dgf(f), "overflow parts missing")
  expect_equal(back$rg_graphics[2:3], c("", ""))
  expect_equal(back$rg_graphics[1], "[]")
})
