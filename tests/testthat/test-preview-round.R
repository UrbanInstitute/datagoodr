test_that("round_preview shortens long decimals only", {
  x <- c("0.3333333333", "0.25", "12", "-1.0000004", "0.1250000001",
         "$851,950", "1e-05", "abc", "3.14159")
  expect_equal(round_preview(x, 3),
               c("0.333", "0.25", "12", "-1", "0.125",
                 "$851,950", "1e-05", "abc", "3.142"))
})

test_that("numeric previews round long decimals; text previews do not", {
  set_xx(c(rg_preview = "0.3333333333 ;; 0.25 ;; 0.33333333334 ;; 7"))
  num <- capture.output(paste_preview_num("rg_preview", LABEL = ""))
  expect_true(any(grepl("0.333 · 0.25 · 7", num, fixed = TRUE)))  # duplicate merged
  expect_false(any(grepl("3333333", num)))

  chr <- capture.output(paste_preview_chr("rg_preview", LABEL = ""))
  expect_true(any(grepl("0.3333333333", chr, fixed = TRUE)))
})
