# Build a synthetic test dataset that exercises every data type datagoodr can
# render, with special attention to the temporal units. Written to
# working-example/temporal-demo-data.csv and used by STEP-temporal-demo.R.
#
# The temporal columns deliberately span the formats a real messy extract throws
# at you - abbreviations, m-d-Y vs d-m-y, yyyy-mm, am/pm clock times, a full
# timestamp, bare years, and an age (duration). They are what a user would then
# type in the DGF (stable_data_type = "temporal", stable_data_unit = ...).

set.seed(42)
n <- 300

# an underlying date per row, so the several date/time columns are consistent
base_date <- sample(seq(as.Date("2015-01-01"), as.Date("2018-12-31"), by = "day"),
                    n, replace = TRUE)
rule_year <- sample(1955:2015, n, replace = TRUE)
clock     <- sprintf("%d:%02d%s",
                     ifelse((h <- sample(1:12, n, replace = TRUE)) == 0, 12, h),
                     sample(0:59, n, replace = TRUE),
                     sample(c("am", "pm"), n, replace = TRUE))

demo <- data.frame(
  # --- standard types (so the guide shows the full range) ------------------
  ein          = sprintf("%09d", sample(1e8:9e8, n)),            # identifier
  org_name     = paste("Organization", sample(LETTERS, n, TRUE),
                       sample(1:999, n)),                        # string (free text)
  ntee_program = sample(c("Arts", "Education", "Health", "Human Services",
                          "Environment"), n, replace = TRUE),    # categorical
  num_programs = pmax(1, round(rnorm(n, 6, 3))),                 # number
  is_501c3     = sample(c(TRUE, FALSE), n, replace = TRUE, prob = c(0.8, 0.2)),

  # --- temporal variants ---------------------------------------------------
  day_of_week  = toupper(format(base_date, "%a")),              # MON, TUE, ...  (dow)
  date_mdy     = format(base_date, "%m-%d-%Y"),                 # 01-02-2024     (date)
  date_dmy     = format(base_date, "%d-%m-%y"),                 # 02-01-24       (date)
  month_abbr   = toupper(format(base_date, "%b")),              # JAN, FEB, ...  (month)
  month_ym     = format(base_date, "%Y-%m"),                    # 2024-02        (month)
  hour_ampm    = clock,                                         # 8:13am         (hour)
  event_ts     = paste(format(base_date, "%Y-%m-%d"),
                       sprintf("%02d:%02d:%02d", sample(0:23, n, TRUE),
                               sample(0:59, n, TRUE), sample(0:59, n, TRUE)),
                       "MST"),                                  # full timestamp (date)
  rule_year    = rule_year,                                     # 1994           (year)
  age_years    = 2026 - rule_year,                             # duration       (year)

  stringsAsFactors = FALSE
)

out <- "working-example/temporal-demo-data.csv"
utils::write.csv(demo, out, row.names = FALSE)
cat("wrote", out, "-", nrow(demo), "rows x", ncol(demo), "cols\n")
str(demo)
