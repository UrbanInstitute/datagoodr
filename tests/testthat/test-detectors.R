# Generic detector fixture tests. These iterate over the WHOLE registry, so a
# new dt-<family> automatically inherits coverage once it is registered and the
# fixture (data_type_tests) is rebuilt. Two universal invariants:
#   * recall = 1: every valid fixture case passes its own detector.
#   * strict types reject random (S3) negatives at a high rate.
# Inherently-loose types (short-alphabet lookups, numeric ranges) are excluded
# from the precision assertion by design -- their "false positives" are mostly
# genuinely valid values, which the guess_data_type() specificity ranking, not
# the detector, is responsible for disambiguating.

detectors <- datagoodr:::data_type_detectors()

test_that("every registered detector accepts all its positives (recall = 1)", {
  for (nm in names(detectors)) {
    df <- data_type_tests[[nm]]
    expect_false(is.null(df), info = paste("no fixture for", nm))
    valid <- df$case[df$label == "valid"]
    expect_true(all(detectors[[nm]](valid)),
                info = paste("valid cases rejected for", nm))
  }
})

test_that("structured detectors reject random (S3) negatives", {
  strict <- c("email", "url", "ipv4", "ipv6", "mac",
              "hex_color", "rgb_color", "hsl_color", "cmyk_color",
              "md5", "sha1", "sha256", "guid",
              "ensembl_id", "uniprot_id", "snp_id", "asin", "bibcode",
              "zip_code")
  for (nm in strict) {
    df <- data_type_tests[[nm]]
    s3 <- df$case[df$label == "S3"]
    if (length(s3) == 0) next
    expect_lt(mean(detectors[[nm]](s3), na.rm = TRUE), 0.1)
  }
})

test_that("every detector is NA-safe and length-preserving", {
  for (nm in names(detectors)) {
    out <- detectors[[nm]](c(NA, "", "definitely-not-a-valid-value-123!!"))
    expect_length(out, 3)
    expect_true(is.na(out[1]), info = paste(nm, "NA input"))
    expect_type(out, "logical")
  }
})

# --- a few cross-family spot checks (seed-independent) ----------------------

test_that("web detectors pin their contracts", {
  expect_true(is_email("a.b@example.com"));  expect_false(is_email("no@tld"))
  expect_true(is_url("https://x.io/p?q=1"));  expect_false(is_url("x.io"))
  expect_true(is_ipv4("192.168.1.1"));        expect_false(is_ipv4("256.1.1.1"))
  expect_true(is_mac("00:1B:44:11:3A:B7"));   expect_false(is_mac("00:1B:44"))
})

test_that("color and hash detectors pin their contracts", {
  expect_true(is_hex_color("#4d9cf8"));       expect_false(is_hex_color("4d9cf8"))
  expect_true(is_rgb_color("128,64,32"));     expect_false(is_rgb_color("300,0,0"))
  expect_true(is_md5(strrep("a", 32)));       expect_false(is_md5(strrep("a", 31)))
  expect_true(is_sha256(strrep("f", 64)));    expect_false(is_sha256(strrep("f", 40)))
})

test_that("lookup detectors use their code lists", {
  expect_true(is_us_state("wa"));             expect_false(is_us_state("ZZ"))
  expect_true(is_country_code("US"));         expect_false(is_country_code("ZZ"))
  expect_true(is_country_code("MT"))          # Malta (also a US state code)
  expect_true(is_roman("MMXXIV"));            expect_false(is_roman("IIII"))
})
