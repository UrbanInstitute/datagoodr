# The shipped demo only READ Python-written fixtures; the R writer was never
# executed (see the design README). These drive write_stable_csv() ->
# read_stable_csv() in R and were what first surfaced the digest_list() bug.

demo_df <- function() {
  data.frame(
    id    = sprintf("%05d", 1:15),          # leading zeros: a classic loss case
    state = rep(c("MD", "VA", "DC"), 5),
    score = round(seq(40, 68, length.out = 15), 2),
    stringsAsFactors = FALSE
  )
}

demo_payloads <- function() {
  list(
    provenance = list(dgf_version = "0.1.0", created = "2026-07-16",
                      current_hash = list(id = "abc123", state = "def456")),
    renv = list(R = "4.5.1"),
    factor_levels = list(state = c("MD", "VA", "DC"))
  )
}

test_that("write_stable_csv runs (the path digest_list broke)", {
  p <- tempfile(fileext = ".csv")
  expect_error(write_stable_csv(demo_df(), p, demo_payloads()), NA)
  expect_true(file.exists(p))
})

test_that("a round trip preserves data and every payload", {
  p <- tempfile(fileext = ".csv")
  df <- demo_df()
  write_stable_csv(df, p, demo_payloads())
  back <- read_stable_csv(p)

  expect_equal(nrow(back$data), 15)
  expect_equal(names(back$data), names(df))
  expect_length(back$missing, 0)
  expect_length(back$mismatch, 0)
  expect_setequal(names(back$meta), c("provenance", "renv", "factor_levels"))
  expect_true(isTRUE(back$stamp_consistent))
  expect_false(is.null(back$stamp$payload_manifest))
})

test_that("leading zeros and factor levels survive verbatim", {
  p <- tempfile(fileext = ".csv")
  df <- demo_df()
  write_stable_csv(df, p, demo_payloads())
  back <- read_stable_csv(p)

  expect_equal(back$data$id, df$id)                       # "00001", not 1
  expect_equal(back$data$state, df$state)
  expect_equal(back$meta$provenance$dgf_version, "0.1.0")
  expect_equal(as.character(back$meta$factor_levels$state), c("MD", "VA", "DC"))
})

test_that("no overflow column appears when payloads fit in the data rows", {
  p <- tempfile(fileext = ".csv")
  write_stable_csv(demo_df(), p, demo_payloads())
  hdr <- names(utils::read.csv(p, nrows = 1, check.names = FALSE))
  expect_true(".dgf_stamp" %in% hdr)
  expect_true(".dgf_meta" %in% hdr)
  expect_false(".dgf_is_data" %in% hdr)
})

test_that("overflow spill still recovers everything (writer side)", {
  # Overflow is driven by chunk-items vs. available rows. A 15-row frame has
  # room to pack multi-per-cell, so force it with a tiny frame + tiny chunk
  # limit: many small chunks, few rows -> appended overflow rows.
  df3 <- data.frame(id = sprintf("%05d", 1:3), x = letters[1:3],
                    stringsAsFactors = FALSE)
  p <- tempfile(fileext = ".csv")
  write_stable_csv(df3, p, demo_payloads(), chunk_limit = 10L)
  hdr <- names(utils::read.csv(p, nrows = 1, check.names = FALSE))
  expect_true(".dgf_is_data" %in% hdr)                    # overflow triggered

  back <- read_stable_csv(p)
  expect_equal(nrow(back$data), 3)                        # data still separable
  expect_length(back$missing, 0)
  expect_setequal(names(back$meta), c("provenance", "renv", "factor_levels"))
})

test_that("R writer output is read-compatible with the fixture reader path", {
  # write in R, then confirm the manifest-based total-loss detection the Python
  # fixtures exercise also fires on an R-written file: drop the metadata cells
  # and the manifest should still report what's gone.
  p <- tempfile(fileext = ".csv")
  write_stable_csv(demo_df(), p, demo_payloads())

  # blank the .dgf_meta column entirely -> every tier-2 payload lost, but the
  # tier-1 stamp (hence manifest) survives on the data rows
  tbl <- utils::read.csv(p, colClasses = "character", check.names = FALSE, na.strings = "")
  tbl[[".dgf_meta"]] <- NA
  utils::write.csv(tbl, p, row.names = FALSE, na = "")

  back <- read_stable_csv(p)
  expect_setequal(back$missing, c("provenance", "renv", "factor_levels"))
})

test_that("replication factor is honoured", {
  p <- tempfile(fileext = ".csv")
  write_stable_csv(demo_df(), p, demo_payloads(),
                   replication = list(provenance = 3))
  back <- read_stable_csv(p)
  expect_equal(back$stamp$payload_manifest$provenance$copies, 3)
  expect_length(back$missing, 0)
})
