# The identifier type: rough auto-detection, a MOST COMMON VALUES table, and no
# graphic. Detection is heuristic by design (users correct it in the DGF), so
# the tests pin the intent, not perfection.

id <- function(...) datagoodr:::detect_identifier(...)

test_that("detect_identifier catches id-shaped columns", {
  expect_true(id(sprintf("%05d", 1:30), "record"))       # unique structured code
  expect_true(id(rep(c("A","B","C"), 10), "county_id"))  # duplicated, id-named
  expect_true(id(c("06001","06013","36061"), "fips"))    # name signal
})

test_that("detect_identifier rejects the classic false positives", {
  expect_false(id(paste("observation", 1:20), "notes"))  # free text (spaces)
  expect_false(id(rnorm(20), "weight"))                  # decimal measurement
  expect_false(id(sample(1:1e6, 30), "revenue"))         # unique integers, no id name
  expect_false(id(rep(c("A","B"), 10), "group"))         # low-cardinality category
})

test_that("create_dgf classifies identifiers and leaves others alone", {
  set.seed(1)
  raw <- data.frame(
    ein    = sprintf("%09d", sample(1e8:1.1e8, 30)),
    fips   = rep(c("06001","36061"), 15),
    amount = round(rnorm(30, 1000, 50), 2),
    stringsAsFactors = FALSE)
  dgf <- suppressMessages(suppressWarnings(
    { utils::capture.output(d <- create_dgf(raw, file = tempfile("dgf"), open = FALSE)); d }))
  ty <- setNames(dgf$stable_data_type, dgf$var_name)
  expect_equal(unname(ty["ein"]),  "identifier")
  expect_equal(unname(ty["fips"]), "identifier")
  expect_equal(unname(ty["amount"]), "number")
})

test_that("an identifier gets a MOST COMMON table in rg_stats and no graphic", {
  set.seed(1)
  raw <- data.frame(county_id = rep(c("06001","06013","36061","48201"), length.out = 40),
                    stringsAsFactors = FALSE)
  dgf <- suppressMessages(suppressWarnings(
    { utils::capture.output(d <- create_dgf(raw, file = tempfile("dgf"), open = FALSE)); d }))
  expect_equal(dgf$stable_data_type, "identifier")
  # rg_stats parses, with the common table at position 3 (what
  # paste_stats_chr_common reads)
  lst <- datagoodr:::json_to_list(dgf$rg_stats)
  expect_length(lst, 3)
  common <- do.call(rbind, lst[[3]])
  expect_true(nrow(common) >= 1)
  # no graphic
  expect_equal(dgf$rg_graphics, "")
})

test_that("identifier is a renderable class and has a layout", {
  expect_true("identifier" %in% datagoodr:::.dgf_valid_classes)
  expect_true("identifier" %in% get_design("rg")$TYPE)
})

test_that("an identifier renders through the granular API", {
  set.seed(1)
  raw <- data.frame(org_id = sprintf("ORG%04d", 1:25), stringsAsFactors = FALSE)
  dgf <- suppressMessages(suppressWarnings(
    { utils::capture.output(d <- create_dgf(raw, file = tempfile("dgf"), open = FALSE)); d }))
  out <- suppressMessages(suppressWarnings(
    capture.output(dg_stats(dgf, "org_id", label = "MOST COMMON VALUES"))))
  expect_true(any(grepl("MOST COMMON VALUES", out)))
  # dg_graphic is a no-op for identifiers (no error, no output)
  expect_silent(suppressMessages(dg_graphic(dgf, "org_id")))
})
