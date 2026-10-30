# Degenerate columns: one-level, all-missing, over-long values, and friends.
#
# Each of these used to make create_dgf() abort partway through profiling, after minutes on a
# large file, with an error that did not name the column. The EXPECTED strings for normal inputs
# were generated from datagoodr 0.1.0 at f5cd312 *before* the fixes, so the "unchanged" tests
# prove the fixes did not alter any output for well-behaved columns.

# ---- reference outputs from the unmodified package (normal inputs) -------------------------
EXP_STATS_NORM <- "[ \n  {  \"Value\" :  \"x\"  ,  \"Frequency\" :  55  }, \n  {  \"Value\" :  \"y\"  ,  \"Frequency\" :  30  }, \n  {  \"Value\" :  \"z\"  ,  \"Frequency\" :  14  }, \n  {  \"Value\" :  \"w\"  ,  \"Frequency\" :  1  }\n]"
EXP_GFX_NORM   <- "[ \n  {  \"x\" :  \"x\"  ,  \"Freq\" :  55  }, \n  {  \"x\" :  \"y\"  ,  \"Freq\" :  30  }, \n  {  \"x\" :  \"z\"  ,  \"Freq\" :  14  }, \n  {  \"x\" :  \"other\"  ,  \"Freq\" :  1  }\n]"

fx_norm <- function() data.frame(a = factor(rep(c("x", "y", "z", "w"), times = c(55, 30, 14, 1))))
fx_rare <- function() data.frame(a = factor(c("p", "q", letters[1:15])))     # every level >= 2%

# ---- B1: one-level factors ------------------------------------------------------------------
test_that("one-level factor profiles instead of crashing", {
  one <- data.frame(a = factor(rep("2023", 50)))

  st <- datagoodr:::get_stats_fact("a", one)
  expect_true(validate_json(st))
  tab <- jsonlite::fromJSON(st)
  expect_equal(tab$Value, "2023"); expect_equal(tab$Frequency, 50)

  gf <- datagoodr:::get_graphics_fact("a", one)
  expect_true(validate_json(gf))
  tab <- jsonlite::fromJSON(gf)
  expect_equal(tab$x[1], "2023"); expect_equal(tab$Freq[1], 50)
})

test_that("fixing the one-level crash changes nothing for ordinary factors", {
  expect_identical(as.character(datagoodr:::get_stats_fact("a", fx_norm())),    EXP_STATS_NORM)
  expect_identical(as.character(datagoodr:::get_graphics_fact("a", fx_norm())), EXP_GFX_NORM)
})

test_that("get_graphics_fact does not append an empty 'other' when every level is >= 2%", {
  # A factor with no sub-2% tail has nothing to collect, so there must be no
  # "other" row. A spurious 0-frequency "other" used to be appended here, which
  # paste_treemap() then inflated into a bucket equal to the whole dataset (it
  # lumps every level sitting at exactly 2.0% into "other"), double-counting a
  # uniform factor such as the 50 US states.
  tab <- jsonlite::fromJSON(datagoodr:::get_graphics_fact("a", fx_rare()))
  expect_false("other" %in% tab$x)
  expect_equal(nrow(tab), 17L)
  expect_true(all(tab$Freq == 1))
})

test_that("word-cloud words survive a column with a single distinct word", {
  one <- datagoodr:::simplify_char(rep("alpha", 10))
  expect_s3_class(one, "data.frame")
  expect_equal(nrow(one), 1)
  expect_equal(as.character(one[[1]]), "alpha")
  expect_equal(one$Freq, 10)

  # ordinary input unchanged: levels in frequency order, then Freq
  many <- datagoodr:::simplify_char(rep(c("alpha beta", "alpha gamma", "delta"), c(5, 3, 2)))
  expect_equal(as.character(many$ww), c("alpha", "beta", "gamma", "delta"))
  expect_equal(many$Freq, c(8L, 5L, 3L, 2L))
})


# ---- B2: strptime() aborts on values >= 1000 bytes -------------------------------------------
test_that("detect_temporal does not abort on a value over 1000 bytes", {
  # 5 of 6 values parse (83%), above the detector's 80% bar: the over-long value just counts as
  # "not a date" -- it must not abort, and must not move the threshold
  expect_no_error(res <- datagoodr:::detect_temporal(c(strrep("x", 1500), rep("2020-01-15", 5))))
  expect_true(res)
  # mostly long free text: not temporal
  expect_false(datagoodr:::detect_temporal(c(rep(strrep("free text ", 200), 4), "2020-01-15")))
  expect_false(datagoodr:::detect_temporal(strrep("free text ", 200)))
})

test_that("detect_temporal is unchanged for ordinary columns", {
  expect_true(datagoodr:::detect_temporal(c("2015-01-01", "2016-06-15", "2017-12-31")))
  expect_false(datagoodr:::detect_temporal(c("apple", "banana", "cherry")))
  expect_false(datagoodr:::detect_temporal(c("10", "20", "30")))
  expect_true(datagoodr:::detect_temporal(as.Date("2020-01-01") + 0:9))
})


# ---- B9: get_examples on empty input ---------------------------------------------------------
test_that("get_examples returns an empty preview for an all-missing column, quietly", {
  expect_no_warning(out <- datagoodr:::get_examples("a", data.frame(a = rep(NA_character_, 5))))
  expect_identical(out, "")
  expect_identical(datagoodr:::get_examples("a", data.frame(a = rep(c("one", "two", "three"), c(5, 3, 2)))),
                   "one ;; two ;; three")
})


# ---- end to end -------------------------------------------------------------------------------
test_that("create_dgf profiles a frame full of degenerate columns", {
  df  <- degenerate_df()
  dgf <- quiet_dgf(df, preflight = "off")

  expect_equal(nrow(dgf), ncol(df))
  expect_setequal(dgf$var_name, names(df))
  for (col in c("rg_properties", "rg_stats")) {          # every profile cell is valid JSON
    cells <- dgf[[col]][nzchar(dgf[[col]])]
    expect_true(all(vapply(cells, validate_json, logical(1))), info = col)
  }
})


# ---- B5: temporal profile of a high-cardinality timestamp column ------------------------------
test_that("a timestamp column with too many distinct values is stored coarsened, not whole", {
  old_opt <- options(datagoodr.temporal.max_values = 50L); on.exit(options(old_opt), add = TRUE)
  ts <- format(as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + seq(0, by = 3600 * 2, length.out = 400),
               "%Y-%m-%dT%H:%M:%S")                      # 400 distinct timestamps over ~34 days
  df <- data.frame(ts = ts, stringsAsFactors = FALSE)

  tab <- jsonlite::fromJSON(datagoodr:::get_graphics_temporal("ts", df))
  expect_lte(nrow(tab), 50)                              # honours the cap
  expect_equal(sum(tab$Count), 400)                      # no observation lost
  expect_true(all(grepl("^\\d{4}-\\d{2}-\\d{2}", tab$Value)))   # still parseable by the renderer
  expect_gt(length(unique(substr(tab$Value, 1, 10))), 1)        # coarsened to a date, not collapsed
})

test_that("temporal profiles under the cap, or not ISO-like, are stored exactly as before", {
  old_opt <- options(datagoodr.temporal.max_values = 50L); on.exit(options(old_opt), add = TRUE)
  d <- data.frame(d = rep(c("2024-01-05", "2024-02-10", "2024-03-15"), c(4, 3, 2)))
  tab <- jsonlite::fromJSON(datagoodr:::get_graphics_temporal("d", d))
  expect_equal(tab$Value, c("2024-01-05", "2024-02-10", "2024-03-15"))
  expect_equal(tab$Count, c(4, 3, 2))

  # over the cap but not an ISO date prefix (clock times): left alone, no data invented
  clock <- data.frame(t = sprintf("%02d:%02d", rep(0:23, each = 5), rep(seq(0, 55, by = 12), 24)))
  expect_equal(nrow(jsonlite::fromJSON(datagoodr:::get_graphics_temporal("t", clock))),
               length(unique(clock$t)))
})


# ---- B4 / B7: retype_dgf ----------------------------------------------------------------------
retype_fixture <- function() {
  data.frame(code = rep(c("00", "11"), 30), mix = rep(c("0", "1", "true", "false"), 15),
             n = as.character(rep(1:3, 20)), grp = rep(c("a", "b", "c"), 20), stringsAsFactors = FALSE)
}

test_that("retype_dgf reading a .csv keeps zero-padded codes instead of inferring numbers", {
  df  <- retype_fixture()
  dgf <- quiet_dgf(df, preflight = "off")
  csv <- tempfile(fileext = ".csv"); utils::write.csv(df, csv, row.names = FALSE)

  out <- suppressMessages(retype_dgf(dgf, csv, types = c(code = "categorical")))
  lv  <- jsonlite::fromJSON(out$dd_f_levels[out$var_name == "code"])
  expect_setequal(lv$level, c("00", "11"))           # readr inference would have given "0" and "11"
})

test_that("retype_dgf refreshes dd_f_levels for the new type and keeps curated labels", {
  df  <- retype_fixture()
  df$mix <- ifelse(df$mix %in% c("1", "true"), "TRUE", "FALSE")      # the harmonised values
  dgf <- quiet_dgf(retype_fixture(), preflight = "off")

  # a variable made boolean gets the levels of the data it was re-profiled on, not the old spellings
  out <- retype_dgf(dgf, df, types = c(mix = "boolean"))
  expect_setequal(jsonlite::fromJSON(out$dd_f_levels[out$var_name == "mix"])$level, c("FALSE", "TRUE"))

  # a label someone already edited for a surviving level is kept
  tab <- jsonlite::fromJSON(out$dd_f_levels[out$var_name == "mix"])
  tab$label[tab$level == "TRUE"] <- "Yes"
  out$dd_f_levels[out$var_name == "mix"] <- datagoodr:::jsonify_df(tab)
  again <- retype_dgf(out, df, types = c(mix = "boolean"))
  expect_equal(jsonlite::fromJSON(again$dd_f_levels[again$var_name == "mix"])$label[2], "Yes")

  # a variable retyped to a type with no levels is left as it was
  untouched <- out$dd_f_levels[out$var_name == "n"]
  out2 <- retype_dgf(out, retype_fixture(), types = c(n = "text"))
  expect_identical(out2$dd_f_levels[out2$var_name == "n"], untouched)
})

test_that("create_dgf and retype_dgf write dd_f_levels in the same shape", {
  df  <- retype_fixture()
  dgf <- quiet_dgf(df, preflight = "off")
  expect_equal(dgf$desired_data_type[dgf$var_name == "grp"], "categorical")   # a column create_dgf types categorical
  made <- dgf$dd_f_levels[dgf$var_name == "grp"]
  expect_true(nzchar(made))
  out  <- retype_dgf(dgf, df, types = c(grp = "categorical"))
  expect_identical(out$dd_f_levels[out$var_name == "grp"], made)
})


# ---- B8: create_rg bakes a path the render can resolve -----------------------------------------
test_that("rel_to_dir gives a relative path to a DGF that lives in another folder", {
  root <- tempfile("rg-root"); dir.create(file.path(root, "dgf"), recursive = TRUE)
  dir.create(file.path(root, "guide")); dir.create(file.path(root, "a", "b"), recursive = TRUE)
  f <- file.path(root, "dgf", "DGF.xlsx"); file.create(f)

  expect_equal(datagoodr:::rel_to_dir(f, file.path(root, "guide")), "../dgf/DGF.xlsx")
  expect_equal(datagoodr:::rel_to_dir(f, file.path(root, "a", "b")), "../../dgf/DGF.xlsx")
  expect_equal(datagoodr:::rel_to_dir(f, file.path(root, "dgf")), "DGF.xlsx")   # same folder: unchanged
  expect_equal(datagoodr:::rel_to_dir("nowhere/DGF.xlsx", file.path(root, "guide")),
               "nowhere/DGF.xlsx")                                              # unresolvable: as given
  expect_null(datagoodr:::rel_to_dir(NULL, root))
})


# ---- B2 (formex half): over-long values never reach formex's date detector ------------------------
test_that(".cap_bytes trims only values over the limit, in bytes, and keeps NA", {
  x <- c("short", strrep("a", 1500), NA, strrep("é", 800), "")       # 800 x 2-byte chars = 1600 bytes
  y <- datagoodr:::.cap_bytes(x)
  expect_identical(y[c(1, 3, 5)], x[c(1, 3, 5)])
  expect_true(all(nchar(y[!is.na(y)], type = "bytes") <= 999))
  expect_true(nchar(y[2], type = "bytes") >= 990)                         # trimmed, not gutted
  expect_true(startsWith(y[4], "é"))
  expect_identical(datagoodr:::.cap_bytes(c("a", "b")), c("a", "b"))
})

test_that("type guessing survives over-long free text (formex's date detector aborts on it)", {
  vals <- c(strrep("free text ", 150), "another note", "a third note")
  expect_no_error(g <- datagoodr:::.formex_guess(rep(vals, 20), name = "notes"))
  expect_false(identical(g$route$data_type, "temporal"))
})


# ---- B2 on the parallel path (type guessing over a worker pool) -----------------------------------
test_that("the parallel guess path also survives over-long free text", {
  skip_on_cran()
  df <- data.frame(a     = rep(c("x", "y", "z"), 40),
                   notes = rep(c(strrep("free text ", 150), "another note", "a third note"), 40),
                   stringsAsFactors = FALSE)
  # .formex_guess_all() sends each column to a worker that calls formex::guess_data_type() directly,
  # not through .formex_guess(), so the length cap has to be applied before dispatch
  for (w in c(1L, 2L))
    expect_no_error(g <- datagoodr:::.formex_guess_all(df, workers = w, seed = 1L))
  expect_length(g, 2L)
})
