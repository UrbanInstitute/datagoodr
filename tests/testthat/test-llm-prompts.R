# LLM prompt scaffolding. These build copy-paste prompts (no API calls), so the
# tests assert the prompt is well-formed and self-contained: contract present,
# payload present, file written. quiet = TRUE keeps the console clean and avoids
# printing multibyte payloads during tests.

test_that("draft_detector_prompt assembles contract + positives + negatives", {
  f <- draft_detector_prompt(
    examples = c("USD","EUR","JPY","GBP","CAD","AUD","CHF","NZD","MXN","BRL"),
    type_name = "iso_currency",
    file = tempfile(fileext = ".md"), quiet = TRUE)
  expect_true(file.exists(f))
  p <- paste(readLines(f, warn = FALSE), collapse = "\n")
  expect_match(p, "Contract: build a data-type detector")  # contract inlined
  expect_match(p, "is_iso_currency")                        # asks for the fn
  expect_match(p, "USD")                                    # positives present
  expect_match(p, "Hard negatives")                         # negatives section
})

test_that("draft_detector_prompt rejects too-few examples", {
  expect_error(draft_detector_prompt(c("USD"), "iso_currency", quiet = TRUE),
               "at least a few")
})

test_that("evaluate_detector reports recall and precision", {
  # a correct detector: exactly the ISO set
  good <- is_currency_code
  res <- evaluate_detector(good, c("USD","EUR","JPY","GBP","CAD"),
                           "iso_currency")
  expect_true(all(res$f_predict[res$type == "valid"]))      # recall = 1
  # a naive detector accepts anything 3 chars -> leaks negatives
  naive <- function(x) nchar(as.character(x)) == 3
  res2 <- suppressWarnings(evaluate_detector(naive, c("USD","EUR","JPY"), "x"))
  expect_gt(mean(res2$f_predict[res2$type == "S3"]), 0)     # some leakage
})

test_that("draft_factor_labels_prompt collects coded factor levels from a DGF", {
  dgf <- data.frame(
    var_name    = c("region", "amount", "subsector"),
    dd_vlabel   = c("Census region", "", "NTEE subsector"),
    dd_vdesc    = c("US Census region", "", ""),
    dd_f_levels = c('[{"level":"1","label":"1"},{"level":"2","label":"2"}]',
                    "", '[{"level":"A","label":"A"}]'),
    stringsAsFactors = FALSE)
  f <- draft_factor_labels_prompt(dgf, file = tempfile(fileext = ".md"),
                                  quiet = TRUE)
  p <- paste(readLines(f, warn = FALSE), collapse = "\n")
  expect_match(p, "Contract: suggest human-readable factor labels")
  expect_match(p, "## region")                 # factor var included
  expect_match(p, "Census region")             # label carried through
  expect_match(p, "## subsector")              # second factor var
  expect_false(grepl("## amount", p))          # non-factor var excluded
})

test_that("draft_factor_labels_prompt errors when no factors have levels", {
  dgf <- data.frame(var_name = "x", dd_f_levels = "", stringsAsFactors = FALSE)
  expect_error(draft_factor_labels_prompt(dgf, quiet = TRUE),
               "No factor variables")
})
