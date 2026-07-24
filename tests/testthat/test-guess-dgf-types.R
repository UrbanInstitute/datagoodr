# Detector-driven type enrichment: create_dgf() refines its coarse R-storage
# typing with guess_data_type(), fills desired_data_subtype/class, promotes
# near-unique geographic categoricals to identifiers, and flags dd_is_join_key.

test_that("guess_dgf_types refines coarse types and flags keys", {
  df <- data.frame(
    fips  = c("06037", "36061", "48201", "17031", "12086", "04013"),  # all distinct
    state = rep(c("CA", "NY", "TX"), 2),                              # grouping
    orcid = c("0000-0002-0488-8591", "0000-0002-6390-6569",
              "0000-0001-8666-7241", "0000-0001-6352-7991",
              "0000-0003-2738-1803", "0000-0003-1607-8999"),
    edate = c("2016-03-15", "2016-03-13", "2016-03-12",
              "2016-03-11", "2020-01-01", "1999-12-31"),
    amount = c(12.5, 3.2, 99.9, 0.1, 45.0, 7.7),
    stringsAsFactors = FALSE)
  base <- c("text", "text", "text", "text", "number")
  r <- datagoodr:::guess_dgf_types(df, base_type = base)

  # near-unique geographic categorical -> identifier key
  expect_equal(r$desired_data_type[1], "identifier")
  expect_equal(r$desired_data_class[1], "geographic_id")
  expect_equal(r$dd_is_join_key[1], "TRUE")

  # low-cardinality geography stays a grouping categorical, not a key
  expect_equal(r$desired_data_type[2], "categorical")
  expect_equal(r$desired_data_class[2], "geography")
  expect_equal(r$dd_is_join_key[2], "")

  expect_equal(r$desired_data_type[3], "identifier")   # ORCID
  expect_equal(r$desired_data_type[4], "temporal")     # date string
  expect_equal(r$stable_data_unit[4], "date")          # calendar_date -> date

  # a generic number with no confident match is left untouched
  expect_equal(r$desired_data_type[5], "number")
  expect_equal(r$desired_data_class[5], "")
  expect_equal(r$stable_data_unit[5], "")              # non-temporal: no unit
})

test_that("create_dgf populates ontology columns and dd_is_join_key", {
  raw <- data.frame(
    person_orcid = c("0000-0002-0488-8591", "0000-0002-6390-6569",
                     "0000-0001-8666-7241", "0000-0001-6352-7991"),
    home_state   = c("CA", "NY", "TX", "CA"),
    amount       = c(10.5, 22.1, 3.7, 88.0),
    stringsAsFactors = FALSE)
  dgf <- suppressMessages(suppressWarnings(
    { utils::capture.output(d <- create_dgf(raw, file = tempfile("dgf"), open = FALSE)); d }))

  ty  <- setNames(dgf$desired_data_type,  dgf$var_name)
  cls <- setNames(dgf$desired_data_class, dgf$var_name)
  jk  <- setNames(dgf$dd_is_join_key,    dgf$var_name)

  expect_equal(unname(ty["person_orcid"]),  "identifier")
  expect_equal(unname(cls["person_orcid"]), "administrative_id")
  expect_equal(unname(jk["person_orcid"]),  "TRUE")          # unique ORCID -> key
  expect_equal(unname(cls["home_state"]),   "geography")     # grouping, not a key
  expect_equal(unname(jk["home_state"]),    "")
  expect_equal(unname(ty["amount"]),        "number")        # untouched
})
