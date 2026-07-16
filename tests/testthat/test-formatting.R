test_that("wrap_preview packs values into lines no wider than size", {
  x <- c("apple", "banana", "cherry", "date", "elderberry")
  lines <- wrap_preview(x, size = 20)
  expect_true(all(nchar(lines) <= 20))
  # every value is still present somewhere
  expect_true(all(vapply(x, function(v) any(grepl(v, lines, fixed = TRUE)),
                         logical(1))))
})

test_that("wrap_preview truncates an over-long value to size-3 + '...' on its own line", {
  x <- c("short", paste(rep("x", 50), collapse = ""), "tiny")
  lines <- wrap_preview(x, size = 20)
  long <- lines[grepl("\\.\\.\\.$", lines)]
  expect_length(long, 1)
  expect_equal(nchar(long), 20)                 # 17 chars + "..."
  expect_true(endsWith(long, "..."))
  # the long value occupies its own line (not packed with neighbours)
  expect_false(grepl(";;", long))
})

test_that("wrap_preview accepts a single ';;'-delimited string", {
  # a general wrapping utility: it splits but does not de-duplicate
  expect_equal(wrap_preview("a ;; b ;; c", size = 80), "a ;; b ;; c")
  expect_equal(wrap_preview("a ;; b ;; a", size = 80), "a ;; b ;; a")
})

test_that("an empty field label prints the value with no prefix", {
  dgf <- build_demo_dgf()
  out <- suppressMessages(suppressWarnings(
    utils::capture.output(dg_field(dgf, "num", "dd_vlabel", label = ""))))
  txt <- paste(out, collapse = "")
  expect_false(grepl("\\*\\*", txt))       # no bold "**LABEL**:" prefix
  expect_false(grepl("dg-field", txt))     # empty label: bare value, no field cell
  # a non-empty label emits the label/value cell markup (styled by datagoodr.css)
  out2 <- suppressMessages(suppressWarnings(
    utils::capture.output(dg_field(dgf, "num", "dd_vlabel", label = "LABEL"))))
  txt2 <- paste(out2, collapse = "")
  expect_true(grepl("class=\"dg-k\">LABEL</span>", txt2))
  expect_true(grepl("class=\"dg-v\">", txt2))
})

test_that("paste_preview renders a de-duplicated text block, not a table", {
  dgf <- build_demo_dgf()
  out <- suppressMessages(suppressWarnings(
    utils::capture.output(dg_preview(dgf, "notes"))))
  txt <- paste(out, collapse = "\n")
  expect_true(grepl("dg-preview", txt))         # the <pre> block
  expect_false(grepl("border: 1px solid black", txt))  # no bordered kable
})
