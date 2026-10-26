# v7 stabilizer planning: the DGF carries formex's two-axis leaf (guess_*) and a
# read :: [convert] :: write stabilizer resolved by formex's transform-path
# search. The transformable cases need the installed formex to carry the v7 API
# and its ontology-derived registry, so those are skipped on an older formex; the
# pure datagoodr-side logic (axes, label, schema) is checked unconditionally.

test_that(".route_axes reads v7 axes and derives them from v6", {
  # v7: axes present on the route
  ax <- datagoodr:::.route_axes(list(semantic_type = "year",
                                     format_style = "FYyyyy", unit_type = "fiscal"))
  expect_equal(ax$format_style, "FYyyyy")
  expect_equal(ax$unit_type, "fiscal")

  # v6: format_label == semantic_type carries no style
  ax <- datagoodr:::.route_axes(list(semantic_type = "calendar",
                                     format_label = "calendar", dd_unit = NA))
  expect_true(is.na(ax$format_style))

  # v6: a format_label finer than semantic_type IS the style
  ax <- datagoodr:::.route_axes(list(semantic_type = "min_max",
                                     format_label = "comma_pair", dd_unit = NA))
  expect_equal(ax$format_style, "comma_pair")
})

test_that(".guess_label picks the deepest named rung with implied coordinates", {
  lab <- datagoodr:::.guess_label(
    list(data_type = "temporal", semantic_family = "date", semantic_type = "calendar"),
    list(format_style = NA_character_, unit_type = NA_character_))
  expect_equal(lab, "calendar {{ date :: temporal }}")

  # family-only (semantic_type unresolved) -> report the family
  lab <- datagoodr:::.guess_label(
    list(data_type = "temporal", semantic_family = "date",
         semantic_type = NA_character_),
    list(format_style = NA_character_, unit_type = NA_character_))
  expect_equal(lab, "date {{ temporal }}")

  # nothing resolved -> blank
  expect_equal(datagoodr:::.guess_label(NULL), "")
})

test_that("the v7 schema carries the guess_* axes and the stabilizer columns", {
  cols <- datagoodr:::dgf_schema_cols()
  expect_true(all(c("guess_label", "guess_semantic_type", "guess_format_style",
                    "guess_unit_type", "guess_match_kind", "guess_variant_id",
                    "guess_depth", "guess_confidence",
                    "desired_semantic_type", "desired_format_style",
                    "desired_unit_type", "stabilizer_needed", "stabilizer",
                    "stabilizer_status", "stable_first5",
                    "load_rule_needed", "load_rule") %in% cols))
  # the render-engine contract columns are retained
  expect_true(all(c("desired_data_type", "desired_data_class",
                    "raw_to_stable_transform") %in% cols))
})

test_that("create_dgf emits the schema columns in schema order", {
  dgf <- build_demo_dgf()
  expect_true(all(datagoodr:::dgf_schema_cols() %in% names(dgf)))
  # guess_* axes populated for the categorical column (cat -> A/B/C)
  expect_true("guess_label" %in% names(dgf))
})

# ---- transformable cases: require formex v7 + its registry -------------------

test_that("plan_stabilizer resolves a calendar reformat", {
  skip_if_not(datagoodr:::.formex_has_v7(), "installed formex lacks the v7 API")
  p <- datagoodr:::plan_stabilizer(
    list(semantic_type = "calendar", format_style = "mdy_slash", unit_type = NA),
    list(semantic_type = "calendar", format_style = "ymd_dash",  unit_type = NA),
    raw_first5 = c("03/15/2019", "12/31/2020"))
  expect_equal(p$stabilizer_needed, "yes")
  expect_equal(p$stabilizer_status, "ready")
  expect_match(p$stabilizer, "read_mdy_slash :: write_ymd_dash")
  expect_match(p$stable_first5, "2019-03-15")
})

test_that("plan_stabilizer converts units with a registered converter", {
  skip_if_not(datagoodr:::.formex_has_v7(), "installed formex lacks the v7 API")
  p <- datagoodr:::plan_stabilizer(
    list(semantic_type = "temperature", format_style = "celsius",    unit_type = "C"),
    list(semantic_type = "temperature", format_style = "fahrenheit", unit_type = "F"),
    raw_first5 = c("20 C", "0 C"))
  expect_equal(p$stabilizer_status, "ready")
  expect_match(p$stabilizer, "convert_C_F")
  expect_match(p$stable_first5, "68")   # 20 C -> 68 F
})

test_that("plan_stabilizer reports an unreachable transform honestly", {
  skip_if_not(datagoodr:::.formex_has_v7(), "installed formex lacks the v7 API")
  p <- datagoodr:::plan_stabilizer(
    list(semantic_type = "year", format_style = "FYyyyy", unit_type = "fiscal"),
    list(semantic_type = "year", format_style = "bare",   unit_type = "calendar"))
  expect_match(p$stabilizer_status, "not-transformable")
  expect_equal(p$stabilizer, "")
})

# ---- stabilize_data executes the v7 plan when opted in ----------------------

# A minimal v7 DGF: one variable, no legacy rule, the two-axis guess/desired set.
v7_dgf <- function(var, g_st, g_style, d_style, g_unit = "", d_unit = "") {
  data.frame(
    var_name                 = var,
    desired_data_import_rule = "",
    raw_to_stable_transform  = "",
    guess_semantic_type      = g_st,  guess_format_style   = g_style, guess_unit_type   = g_unit,
    desired_semantic_type    = g_st,  desired_format_style = d_style, desired_unit_type = d_unit,
    stringsAsFactors = FALSE)
}

test_that("stabilize_data runs the v7 plan only when use_v7 = TRUE", {
  skip_if_not(datagoodr:::.formex_has_v7(), "installed formex lacks the v7 API")
  raw <- data.frame(d = c("03/15/2019", "12/31/2020"), stringsAsFactors = FALSE)
  dgf <- v7_dgf("d", "calendar", "mdy_slash", "ymd_dash")

  # default (use_v7 = FALSE): blank legacy rule -> pass through unchanged
  expect_equal(stabilize_data(raw, dgf)$d, raw$d)

  # opted in: the read_mdy_slash :: write_ymd_dash plan runs
  expect_equal(stabilize_data(raw, dgf, use_v7 = TRUE)$d,
               c("2019-03-15", "2020-12-31"))
})

test_that("use_v7 converts units through a registered converter", {
  skip_if_not(datagoodr:::.formex_has_v7(), "installed formex lacks the v7 API")
  raw <- data.frame(temp = c("20 C", "0 C"), stringsAsFactors = FALSE)
  dgf <- v7_dgf("temp", "temperature", "celsius", "fahrenheit", g_unit = "C", d_unit = "F")
  out <- stabilize_data(raw, dgf, use_v7 = TRUE)$temp
  expect_match(out[1], "68")   # 20 C -> 68 F
  expect_match(out[2], "32")   # 0 C  -> 32 F
})

test_that("a legacy rule still wins over the v7 plan under use_v7 = TRUE", {
  skip_if_not(datagoodr:::.formex_has_v7(), "installed formex lacks the v7 API")
  raw <- data.frame(d = c("03/15/2019", "12/31/2020"), stringsAsFactors = FALSE)
  dgf <- v7_dgf("d", "calendar", "mdy_slash", "ymd_dash")
  tag <- function(x) paste0("L:", x)                 # a distinctive legacy rule
  dgf$raw_to_stable_transform <- "tag"
  out <- stabilize_data(raw, dgf, use_v7 = TRUE, env = environment())$d
  expect_true(all(grepl("^L:", out)))                # legacy ran, not the v7 plan
})
