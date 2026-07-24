# stabilize_data() applies a DGF's rules to a raw extract; write_stable_csv(dgf=)
# embeds the portable DGF + provenance; the pair round-trips and chains lineage.

demo_raw <- function() {
  data.frame(
    ein   = c(1234567, 42, 999999999),   # numeric EINs -> leading zeros lost
    state = c("MD", "va", "DC"),
    score = c(10.5, 22.0, 7.25),
    stringsAsFactors = FALSE
  )
}

demo_dgf <- function(raw = demo_raw()) {
  suppressMessages(suppressWarnings(utils::capture.output(
    dgf <- create_dgf(raw, file = tempfile("dgf"), open = FALSE)
  )))
  dgf$desired_data_import_rule[dgf$var_name == "ein"] <- "as_EIN"
  dgf
}


# ---- stabilize_data --------------------------------------------------------

test_that("stabilize_data applies an import rule element-wise", {
  raw <- demo_raw(); dgf <- demo_dgf(raw)
  stable <- stabilize_data(raw, dgf)
  expect_equal(stable$ein, c("001234567", "000000042", "999999999"))
})

test_that("a blank rule passes the column through unchanged", {
  raw <- demo_raw(); dgf <- demo_dgf(raw)
  stable <- stabilize_data(raw, dgf)
  expect_equal(as.character(stable$score), as.character(raw$score))
})

test_that("stabilize_data returns the DGF's variables in DGF order", {
  raw <- demo_raw(); dgf <- demo_dgf(raw)
  expect_equal(names(stabilize_data(raw, dgf)), dgf$var_name)
})

test_that("a raw_to_stable_transform runs after the import rule", {
  raw <- demo_raw(); dgf <- demo_dgf(raw)
  # standardize state to upper-case via a user function in scope
  to_upper <- function(x) toupper(x)
  dgf$raw_to_stable_transform[dgf$var_name == "state"] <- "to_upper"
  stable <- stabilize_data(raw, dgf)
  expect_equal(stable$state, c("MD", "VA", "DC"))
})

test_that("a missing rule function warns and leaves the column unchanged", {
  raw <- demo_raw(); dgf <- demo_dgf(raw)
  dgf$raw_to_stable_transform[dgf$var_name == "score"] <- "no_such_fn_123"
  expect_warning(stable <- stabilize_data(raw, dgf), "not found")
  expect_equal(as.character(stable$score), as.character(raw$score))
})

test_that("a DGF variable absent from the raw data is skipped with a warning", {
  raw <- demo_raw(); dgf <- demo_dgf(raw)
  dgf$var_name[dgf$var_name == "score"] <- "not_in_raw"
  expect_warning(stable <- stabilize_data(raw, dgf), "not in raw data")
  expect_false("not_in_raw" %in% names(stable))
})


# ---- write / read round trip with an embedded DGF --------------------------

test_that("the portable DGF round-trips and rg_ is never embedded", {
  raw <- demo_raw(); dgf <- demo_dgf(raw)
  stable <- stabilize_data(raw, dgf)
  p <- tempfile(fileext = ".csv")
  write_stable_csv(stable, p, dgf = dgf)

  back <- read_stable_csv(p)
  expect_equal(nrow(back$data), 3)
  expect_length(back$missing, 0)
  expect_setequal(names(back$meta), c("dgf", "provenance"))

  rec <- dgf_from_stable(back)
  expect_false(any(grepl("^rg_", names(rec))))                 # the whitelist
  expect_equal(rec$var_name, dgf$var_name)
  expect_equal(rec$desired_data_import_rule[rec$var_name == "ein"], "as_EIN")
})

test_that("dgf_from_stable accepts a path and returns NULL without a DGF payload", {
  raw <- demo_raw(); dgf <- demo_dgf(raw)
  p <- tempfile(fileext = ".csv")
  write_stable_csv(stabilize_data(raw, dgf), p, dgf = dgf)
  expect_s3_class(dgf_from_stable(p), "data.frame")   # path form

  # a stable CSV written with only a plain payload carries no dgf
  p2 <- tempfile(fileext = ".csv")
  write_stable_csv(demo_raw(), p2, payloads = list(note = list(x = 1)))
  expect_null(dgf_from_stable(read_stable_csv(p2)))
})


# ---- provenance chain ------------------------------------------------------

test_that("lineage chains: gen2 start_hash equals gen1 current_hash", {
  raw <- demo_raw(); dgf <- demo_dgf(raw)
  stable <- stabilize_data(raw, dgf)

  p1 <- tempfile(fileext = ".csv")
  write_stable_csv(stable, p1, dgf = dgf)
  gen1 <- read_stable_csv(p1)$meta$provenance$current_hash

  p2 <- tempfile(fileext = ".csv")
  write_stable_csv(stable, p2, dgf = dgf, start_hash = gen1)
  gen2 <- read_stable_csv(p2)$meta$provenance

  expect_equal(gen2$start_hash, gen1)
})

test_that("current_hash tracks content: it changes when the data changes", {
  raw <- demo_raw(); dgf <- demo_dgf(raw)
  h1 <- {
    p <- tempfile(fileext = ".csv")
    write_stable_csv(stabilize_data(raw, dgf), p, dgf = dgf)
    read_stable_csv(p)$meta$provenance$current_hash$score
  }
  raw2 <- raw; raw2$score <- raw$score + 1
  h2 <- {
    p <- tempfile(fileext = ".csv")
    write_stable_csv(stabilize_data(raw2, dgf), p, dgf = dgf)
    read_stable_csv(p)$meta$provenance$current_hash$score
  }
  expect_false(identical(h1, h2))
})


# ---- write_stable_csv still requires something to embed --------------------

test_that("write_stable_csv errors when there is nothing to embed", {
  expect_error(write_stable_csv(demo_raw(), tempfile(fileext = ".csv")),
               "Nothing to embed")
})
