test_that("most_common_val returns the most frequent value", {
  most_common_val <- datagoodr:::most_common_val
  expect_equal(most_common_val(c("a", "a", "b")), "a")
  expect_equal(most_common_val(c(1, 2, 2, 3)), "2")
})

test_that("most_common_val handles all-NA and empty input", {
  most_common_val <- datagoodr:::most_common_val
  expect_true(is.na(most_common_val(NA)))
  expect_identical(most_common_val(character(0)), NA_character_)
})

test_that("validate_json distinguishes valid from invalid JSON", {
  expect_equal(
    validate_json(c('{"a":1}', 'not json', '[1,2,3]')),
    c(TRUE, FALSE, TRUE)
  )
})

test_that("is_factor flags categorical but not continuous or free-text data", {
  quietly <- function(expr) suppressMessages(
    suppressWarnings(utils::capture.output(res <- expr)))
  quietly(cat_res  <- is_factor(rep(c("A", "B", "C"), 40)))
  quietly(num_res  <- is_factor(rnorm(200)))
  quietly(text_res <- is_factor(paste("id", seq_len(200))))

  expect_true(cat_res)
  expect_false(num_res)
  expect_false(text_res)
})

test_that("first_n returns up to n unique formatted values", {
  out <- first_n(c("a", "a", "b", "c", "d", "e"), n = 3)
  expect_type(out, "character")
  expect_length(out, 1)          # collapsed into a single string
  expect_match(out, "a")
})

test_that("parse_nm splits and de-duplicates a delimited alias string", {
  expect_equal(parse_nm("name1 ;; name2 ;; name1"), c("name1", "name2"))
})
