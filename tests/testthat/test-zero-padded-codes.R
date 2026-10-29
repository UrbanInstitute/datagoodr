# B10: a zero-padded code must never be typed `number`.
#
# .align_profile_types() accepted a formex stabilizer's conversion whenever every value
# converted without an NA. "0155" -> 155 and "00" -> 0 convert cleanly, so a group exemption
# number, a 00/11 code and a zero-padded key were typed `number` and lost their leading zeros,
# although .safe_numeric() (the rule used everywhere else) refuses all three.

test_that(".lossy_as_number is TRUE only for plain numbers that .safe_numeric refuses", {
  lossy <- datagoodr:::.lossy_as_number
  expect_true(lossy(c("0155", "0925", "1156")))                 # zero-padded code
  expect_true(lossy(c("00", "11")))                             # 00/11 code
  expect_true(lossy(c("000123", "", NA, "004567")))             # blanks are ignored
  expect_true(lossy("12345678901234567"))                       # past the 2^53 exact range

  expect_false(lossy(c("155", "925", "1156")))                  # ordinary integers
  expect_false(lossy(c("1.5", "-2", "3e4", "0.5")))             # "0.5" is not a leading-zero integer
  expect_false(lossy(c("$1,234", "$5,000")))                    # needs a stabilizer, not a plain number
  expect_false(lossy(c("0155", "n/a")))                         # not all plain numbers: unchanged behaviour
  expect_false(lossy(character(0))); expect_false(lossy(c(NA, "", " ")))
})

# a zero-padded key, a 00/11 level, a currency column and a plain count, in one frame
b10_df <- function(n = 600) {
  set.seed(7)
  d <- data.frame(
    id    = sprintf("%06d", sample(1:99999, n)),
    lvl   = sample(c("00", "11"), n, TRUE),
    gen   = ifelse(runif(n) < .85, "", sprintf("%04d", sample(c(155:300, 925:1156), n, TRUE))),
    money = paste0("$", format(sample(1000:90000, n, TRUE), big.mark = ",")),
    qty   = as.character(sample(1:500, n, TRUE)),
    stringsAsFactors = FALSE)
  d$money <- trimws(d$money)
  d
}

test_that("zero-padded codes are not typed number, from a data frame or a csv path", {
  d <- b10_df()
  p <- tempfile(fileext = ".csv"); utils::write.csv(d, p, row.names = FALSE)

  for (src in list(d, p)) {
    out <- quiet_dgf(src, preflight = "off")
    ty  <- stats::setNames(out$desired_data_type, out$var_name)

    expect_false(ty[["id"]]   == "number")     # zero-padded key
    expect_false(ty[["lvl"]] == "number")     # 00/11 code
    expect_false(ty[["gen"]]  == "number")     # mostly-blank 4-digit code with leading zeros
    expect_identical(ty[["lvl"]], "categorical")   # two states that are not a flag
  }
})

test_that("the guard leaves real numbers alone, including ones a stabilizer cleans", {
  d <- b10_df()
  out <- quiet_dgf(d, preflight = "off")
  ty  <- stats::setNames(out$desired_data_type, out$var_name)
  expect_identical(ty[["qty"]],   "number")
  expect_identical(ty[["money"]], "number")  # "$1,234": only the stabilizer can read it
})

test_that("a two-state code that is not a flag is categorical on both routes", {
  set.seed(3)
  d <- data.frame(sex  = sample(c("M", "F"), 300, TRUE),
                  lvl = ifelse(runif(300) < .2, "", sample(c("00", "11"), 300, TRUE)),
                  stringsAsFactors = FALSE)
  p <- tempfile(fileext = ".csv"); utils::write.csv(d, p, row.names = FALSE)
  for (src in list(d, p)) {
    out <- quiet_dgf(src, preflight = "off")
    expect_identical(out$desired_data_type, c("categorical", "categorical"))
  }
})
