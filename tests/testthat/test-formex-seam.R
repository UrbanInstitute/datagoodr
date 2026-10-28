# The formex seam: guess_dgf_types() reads BOTH of formex's answers.
#
# These are regression fixtures for measured behaviour, not aspirations. Every
# case below was run against formex 0.0.0.9000 (2026-08-22) and records which
# modality has to win for the DGF to come out right. If formex's router
# improves, the storage-safety cases must STILL pass -- they are the guard, not
# a workaround.

test_that("a zero-padded key is never re-typed as a number", {
  # MEASURED: county FIPS routes to number/quantity/count at depth 3, conf 0.87.
  # Acting on that turns 06037 into 6037. The gate must refuse it.
  fips <- sprintf("%05d", c(1001, 6037, 36061, 48201, 17031, 4013))
  got  <- guess_dgf_types(data.frame(county_fips = fips, stringsAsFactors = FALSE),
                          base_type = "text")
  expect_false(got$desired_data_type == "number")
  expect_equal(got$desired_data_type, "identifier")   # near-unique geography
  expect_equal(got$desired_data_class, "id.geographic")
})

test_that("the storage-safety gate keys off the same rule as read-as-text", {
  # .safe_numeric() is the single predicate: if a column may not be promoted to
  # numeric, no number/* route may re-type it either.
  zero_padded <- sprintf("%05d", c(2138, 10001, 90210, 60601))
  plain_nums  <- c("12", "47", "3", "981")

  expect_false(datagoodr:::.safe_numeric(zero_padded))
  expect_true(datagoodr:::.safe_numeric(plain_nums))

  num_route <- list(data_type = "number", depth = 3L, confidence = 0.9,
                    semantic_family = "quantity", semantic_type = "count",
                    variant_id = NA_character_)
  expect_false(datagoodr:::.route_is_storage_safe(num_route, zero_padded))
  expect_true(datagoodr:::.route_is_storage_safe(num_route, plain_nums))

  # a non-number route is never gated -- the gate is about numeric coercion only
  txt_route <- num_route; txt_route$data_type <- "temporal"
  expect_true(datagoodr:::.route_is_storage_safe(txt_route, zero_padded))
})

test_that("a confident route that resolved a semantic type (depth >= 3) counts", {
  leaf     <- list(depth = 4L, confidence = 1.0, semantic_family = "date",
                   semantic_type = "calendar")
  resolved <- list(depth = 3L, confidence = 0.97, semantic_family = "quantity",
                   semantic_type = "count")
  family   <- list(depth = 2L, confidence = 0.97, semantic_family = "quantity",
                   semantic_type = NA_character_)
  unsure   <- list(depth = 4L, confidence = 0.40, semantic_family = "date",
                   semantic_type = "calendar")

  expect_true(datagoodr:::.route_is_leaf(leaf))
  expect_true(datagoodr:::.route_is_leaf(resolved))   # semantic type, no format leaf
  expect_false(datagoodr:::.route_is_leaf(family))    # stopped at the family
  expect_false(datagoodr:::.route_is_leaf(unsure))    # below the confidence bar
  expect_false(datagoodr:::.route_is_leaf(NULL))
})

test_that("the route wins where it resolves a leaf the detectors miss", {
  # MEASURED: a bare four-digit year routes to temporal/period/year at depth 4,
  # confidence 1.0, while the legacy detectors return NA for it. This is the
  # case that justifies reading the route at all.
  yrs <- as.character(c(1994, 2001, 2008, 2015, 2019, 1987, 2003, 2011))
  got <- guess_dgf_types(data.frame(year_founded = yrs, stringsAsFactors = FALSE),
                         base_type = "text")
  expect_equal(got$desired_data_type, "temporal")
  expect_equal(got$desired_data_class, "period.year")
  expect_equal(got$guess_depth, 4L)
})

test_that("a depth-4 confidence-1.0 route cannot overturn a storage type", {
  # MEASURED, and the sharpest case in this file: a column of rnorm() doubles
  # routes to text/web/domain at depth 4 with confidence 1.0 and a variant_id,
  # because "-0.6264538" parses as a domain name. Depth and confidence are NOT
  # sufficient. The route may refine a coarse base type or add a strong semantic
  # signal; it may not overturn what create_dgf() read from storage.
  set.seed(1)
  nums <- as.character(stats::rnorm(60))
  got  <- guess_dgf_types(data.frame(num = nums, stringsAsFactors = FALSE),
                          base_type = "number")
  expect_equal(got$desired_data_type, "number")
  expect_equal(got$desired_data_class, "")     # nothing stamped from a bad route
  expect_equal(got$guess_depth, 4L)            # but the disagreement is recorded
})

test_that("a route that agrees with the base type still stamps its class", {
  # The conservatism must not throw away a GOOD route. When the route's type
  # matches the base type, its coordinate is still the best available answer.
  d   <- c("03/15/2019", "12/31/2020", "01/01/2021", "07/04/1999")
  got <- guess_dgf_types(data.frame(founded = d, stringsAsFactors = FALSE),
                         base_type = "temporal")
  expect_equal(got$desired_data_type, "temporal")
  expect_equal(got$desired_data_class, "date.calendar")
})

test_that("the legacy guess wins where the route truncates", {
  # MEASURED: emails route to number/text at depth 1 (conf 0.32-0.41) but the
  # email detector fires at 1.0.
  em  <- c("jane@example.org", "bob@x.com", "a@b.io", "z@q.net", "m@n.org")
  got <- guess_dgf_types(data.frame(contact = em, stringsAsFactors = FALSE),
                         base_type = "text")
  expect_equal(got$desired_data_type, "text")
  expect_equal(got$desired_data_class, "contact.email")
})

test_that("dates resolve through the route with a variant_id", {
  d   <- c("03/15/2019", "12/31/2020", "01/01/2021", "07/04/1999")
  got <- guess_dgf_types(data.frame(founded = d, stringsAsFactors = FALSE),
                         base_type = "text")
  expect_equal(got$desired_data_type, "temporal")
  expect_equal(got$desired_data_class, "date.calendar")
  expect_true(nzchar(got$guess_variant_id))   # the recipe key for fx_stabilize()
})

test_that("depth is recorded even when neither modality gives a type", {
  # A truncated path is a valid answer, not a failure: the reviewer's job is to
  # deepen it. Recording depth is what makes that visible.
  x   <- c("wibble", "wobble", "flim", "flam", "zork")
  got <- guess_dgf_types(data.frame(mystery = x, stringsAsFactors = FALSE),
                         base_type = "text")
  expect_true(is.na(got$guess_depth) || got$guess_depth <= 4L)
  expect_equal(nrow(got), 1L)
})

test_that("the v4 dotted vocabulary is a subset of the v6 path vocabulary", {
  # This is why the route needs no translation table: desired_data_class already
  # speaks v6. If formex renames a family or semantic_type, this test is where
  # it surfaces.
  skip_if_not_installed("formex")
  o  <- formex::fx_ontology()
  v6 <- unique(paste0(o$semantic_family, ".", o$semantic_type))
  emitted <- c("date.calendar", "period.year", "contact.email", "id.geographic",
               "id.administrative", "mutually_exclusive.geographic",
               "web.url", "name.person", "phase.day_of_week", "currency.usd")
  expect_true(all(emitted %in% v6),
              info = paste("not valid v6 coordinates:",
                           paste(setdiff(emitted, v6), collapse = ", ")))
})
