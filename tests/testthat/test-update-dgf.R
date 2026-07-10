quiet_update <- function(...) {
  suppressMessages(suppressWarnings(
    utils::capture.output(res <- update_dgf(...))))
  res
}

test_that("create_dgf produces identical hashes for identical data", {
  # This is the assumption update_dgf relies on: unchanged data -> same hash.
  df <- make_demo_df()
  a <- build_demo_dgf(df)
  b <- build_demo_dgf(df)
  expect_equal(a$rg_hash, b$rg_hash)
})

test_that("update_dgf marks every variable unchanged when data is identical", {
  df  <- make_demo_df()
  dgf <- build_demo_dgf(df)
  out <- quiet_update(dgf, df, file = tempfile(), verbose = FALSE)
  expect_true(all(attr(out, "status") == "unchanged"))
  expect_length(attr(out, "removed"), 0)
})

test_that("update_dgf isolates a changed variable", {
  df  <- make_demo_df()
  dgf <- build_demo_dgf(df)
  df2 <- df; df2$num <- df2$num * 10
  out <- quiet_update(dgf, df2, file = tempfile(), verbose = FALSE)
  st  <- attr(out, "status")
  expect_equal(unname(st["num"]), "changed")
  expect_true(all(st[c("cat", "flag", "notes")] == "unchanged"))
})

test_that("update_dgf reports added and removed variables", {
  df  <- make_demo_df()
  dgf <- build_demo_dgf(df)
  df3 <- df; df3$brand_new <- runif(nrow(df)); df3$notes <- NULL
  out <- quiet_update(dgf, df3, file = tempfile(), verbose = FALSE)
  expect_equal(unname(attr(out, "status")["brand_new"]), "added")
  expect_true("notes" %in% attr(out, "removed"))
})

test_that("update_dgf preserves curated fields for unchanged variables", {
  df  <- make_demo_df()
  dgf <- build_demo_dgf(df)
  dgf$vdesc[dgf$vname == "cat"] <- "hand written description"
  out <- quiet_update(dgf, df, file = tempfile(), verbose = FALSE)
  expect_equal(out$vdesc[out$vname == "cat"], "hand written description")
})

test_that("update_dgf carries curated factor labels across a data change", {
  df  <- make_demo_df()
  dgf <- build_demo_dgf(df)
  # hand-edit a level label on the factor, then change that column's data
  lv  <- jsonlite::fromJSON(dgf$dd_f_level[dgf$vname == "cat"])
  lv$label[lv$level == "A"] <- "Apple"
  dgf$dd_f_level[dgf$vname == "cat"] <-
    datagoodr:::jsonify_df(lv)

  df2 <- df; df2$cat <- rep(c("A", "B", "C", "A"), length.out = nrow(df))
  out <- quiet_update(dgf, df2, file = tempfile(), verbose = FALSE)
  expect_equal(unname(attr(out, "status")["cat"]), "changed")
  merged <- jsonlite::fromJSON(out$dd_f_level[out$vname == "cat"])
  expect_equal(merged$label[merged$level == "A"], "Apple")
})

test_that("update_dgf writes .csv and .xlsx outputs", {
  df  <- make_demo_df()
  dgf <- build_demo_dgf(df)
  f   <- tempfile("dgf-refresh")
  quiet_update(dgf, df, file = f, verbose = FALSE)
  expect_true(file.exists(paste0(f, ".csv")))
  expect_true(file.exists(paste0(f, ".xlsx")))
})
