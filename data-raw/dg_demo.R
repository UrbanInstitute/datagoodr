# Generates data/dg_demo.rda — the shared demo dataset used across the vignettes.
# One column per data type, so each vignette can show a real DGF row and a real
# rendered profile for every reporting style. Re-run with:
#   Rscript data-raw/dg_demo.R
set.seed(42)
n <- 60

dg_demo <- data.frame(
  # temporal: calendar dates in M/D/YYYY across a year (drives the calendar heat-map)
  event_date  = format(
    sample(seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day"), n),
    "%m/%d/%Y"),
  # categorical: a handful of repeated levels (drives the treemap)
  region      = sample(c("Midwest", "South", "Northeast", "West"), n,
                       replace = TRUE, prob = c(.33, .30, .22, .15)),
  # boolean: yes/no, recoded to logical by create_dgf (drives the boolean bar)
  is_active   = sample(c("yes", "no"), n, replace = TRUE, prob = c(.65, .35)),
  # number: a right-skewed amount (drives the histogram + quantile table)
  revenue     = round(rlnorm(n, meanlog = 6, sdlog = 0.7), 2),
  # identifier: zero-padded county FIPS (stays text — the storage-safety gate)
  county_fips = sample(c("06037", "36061", "17031", "48201", "04013"), n,
                       replace = TRUE),
  # text: free-text notes -- a shared vocabulary recombined into mostly unique
  # sentences, so the column types as TEXT (high cardinality) while words repeat
  # enough to drive a word cloud.
  notes       = vapply(seq_len(n), function(i) {
    pool <- c("annual", "community", "health", "housing", "survey", "outreach",
              "program", "report", "regional", "quarterly", "funding", "access",
              "data", "review", "equity", "services")
    paste(sample(pool, sample(4:6, 1)), collapse = " ")
  }, character(1)),
  stringsAsFactors = FALSE
)

save(dg_demo, file = "data/dg_demo.rda", version = 2)
cat("wrote data/dg_demo.rda:", nrow(dg_demo), "rows x", ncol(dg_demo), "cols\n")
