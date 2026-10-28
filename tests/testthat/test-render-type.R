test_that("dg_render_type prefers a renderable legacy desired_data_type", {
  dgf <- data.frame(desired_data_type     = c("number", "string", "boolean"),
                    desired_semantic_type = c("calendar", "usd", "label"),
                    stringsAsFactors = FALSE)
  expect_equal(dg_render_type(dgf), c("number", "text", "boolean"))
})

test_that("dg_render_type routes v7 semantic types through the ontology", {
  skip_if_not_installed("formex")
  dgf <- data.frame(desired_semantic_type = c("calendar", "usd", "unordered",
                                              "indicator", "ein_typo", "list",
                                              "", "number"),
                    stringsAsFactors = FALSE)
  expect_equal(dg_render_type(dgf),
               c("temporal", "number", "categorical", "boolean",
                 "text",      # not in the ontology -> fallback
                 "text",      # structured -> fallback
                 "text",      # blank -> fallback
                 "number"))   # a data type typed directly
})

test_that("dg_render_type works on a one-variable list missing columns", {
  expect_equal(dg_render_type(list(var_name = "x")), "text")
})

test_that("create_dgf collapses list columns instead of deparsing them", {
  df <- data.frame(id = 1:3)
  df$tags <- list(c("a", "b"), "c", character(0))
  out <- datagoodr:::.collapse_list_cols(df)
  expect_equal(out$tags, c("a|b", "c", NA_character_))
  expect_equal(out$id, 1:3)
})
