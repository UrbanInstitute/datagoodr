test_that("datagoodr_css returns the report stylesheet", {
  css <- datagoodr_css()
  expect_type(css, "character")
  expect_gt(nchar(css), 200)
  expect_match(css, "\\.parent")
  expect_match(css, "--dg-ink")
})

test_that("get_design style controls which sections appear", {
  rg <- get_design("rg")
  dd <- get_design("dd")

  # research guide has the full set of render functions
  expect_true(all(c("paste_properties", "paste_stats_num", "paste_histogram")
                  %in% trimws(rg$FUNCTION)))
  # data dictionary keeps only the descriptor functions
  expect_setequal(unique(trimws(dd$FUNCTION)), c("v_to_txt", "paste_levels"))
  expect_lt(nrow(dd), nrow(rg))
})

test_that("get_design honors an explicit layouts override", {
  custom <- list(
    numeric   = c("div2 ;; vlabel ;; LABEL ;; v_to_txt"),
    character = c("div2 ;; vlabel ;; LABEL ;; v_to_txt"),
    factor    = c("div2 ;; vlabel ;; LABEL ;; v_to_txt"),
    logical   = c("div2 ;; vlabel ;; LABEL ;; v_to_txt"))
  d <- get_design("rg", layouts = custom)
  expect_equal(nrow(d), 4)
})

test_that("get_design picks up a layout override from the global environment", {
  default.n <- sum(get_design("rg")$TYPE == "numeric")
  assign("layout.numeric",
         c("div2 ;; vlabel ;; LABEL ;; v_to_txt",
           "div3 ;; vtype_class ;; DATA TYPE ;; v_to_txt"),
         envir = globalenv())
  on.exit(rm("layout.numeric", envir = globalenv()), add = TRUE)
  expect_equal(sum(get_design("rg")$TYPE == "numeric"), 2)
  # unrelated types still use the package default
  expect_true(sum(get_design("rg")$TYPE == "factor") > 2)
})

test_that("create_all_sections with style='dd' omits data profiles", {
  dgf <- build_demo_dgf()
  out <- suppressMessages(suppressWarnings(
    capture.output(create_all_sections(dgf[dgf$vtype_class == "factor", ],
                                       style = "dd"))))
  expect_true(any(grepl("LEVELS", out)))
  expect_false(any(grepl("PROPERTIES", out)))
})

test_that("use_datagoodr_template copies the template and DG.R", {
  d <- file.path(tempdir(), paste0("dgt-", as.integer(runif(1, 1, 1e6))))
  p <- use_datagoodr_template(dir = d, flavor = "rg")
  expect_true(file.exists(p))
  expect_equal(basename(p), "research-guide.qmd")
  expect_true(file.exists(file.path(d, "DG.R")))
})

test_that("create_rg / create_dd scaffold a report pointed at the DGF", {
  d <- file.path(tempdir(), paste0("dgp-", as.integer(runif(1, 1, 1e6))))
  dir.create(d)

  rg <- suppressMessages(create_rg("myfile.xlsx", dir = d))
  expect_equal(basename(rg), "research-guide.qmd")
  expect_true(any(grepl('dgf_file:\\s*"myfile.xlsx"', readLines(rg))))

  dd <- suppressMessages(create_dd("myfile.xlsx", dir = d))
  expect_equal(basename(dd), "data-dictionary.qmd")
  # the DD template renders with style = "dd"
  expect_true(any(grepl('style\\s*=\\s*"dd"', readLines(dd))))
})
