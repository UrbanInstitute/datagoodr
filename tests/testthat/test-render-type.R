test_that("dg_render_type reads desired_semantic_type before the legacy column", {
  skip_if_not_installed("formex")
  dgf <- data.frame(desired_data_type     = c("number", "string", "boolean", "number"),
                    desired_semantic_type = c("calendar", "usd", "", "not_a_type"),
                    stringsAsFactors = FALSE)
  # semantic wins; blank or unknown semantic types fall back to the legacy type
  expect_equal(dg_render_type(dgf), c("temporal", "number", "boolean", "number"))
})

test_that("dg_render_type routes a legacy-only DGF from desired_data_type", {
  dgf <- data.frame(desired_data_type = c("number", "string", "boolean"),
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

test_that("dg_render_type reads a formex path and its data type", {
  skip_if_not_installed("formex")
  dgf <- data.frame(desired_semantic_type = c("identifier:id:geographic",
                                              "categorical:mutually_exclusive:geographic",
                                              "temporal:period:year",
                                              "structured:collection:list",
                                              "number"),
                    stringsAsFactors = FALSE)
  # the path's first segment settles geographic; structured falls back to text
  expect_equal(dg_render_type(dgf),
               c("identifier", "categorical", "temporal", "text", "number"))
})

test_that("a conflicted semantic type routes to text unless something settles it", {
  skip_if_not_installed("formex")
  ont <- formex::fx_ontology()
  id_variant <- ont$variant_id[ont$semantic_type == "geographic" & ont$data_type == "identifier"][1]
  dgf <- data.frame(desired_semantic_type = c("geographic", "geographic", "identifier:id:geographic"),
                    guess_variant_id      = c("", id_variant, ""),
                    desired_data_type     = c("categorical", "categorical", "categorical"),
                    stringsAsFactors = FALSE)
  # bare -> text (not the legacy type); a matching variant or a path settles it
  expect_equal(dg_render_type(dgf), c("text", "identifier", "identifier"))
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
