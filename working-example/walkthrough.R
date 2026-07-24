###############################################################################
### datagoodr walkthrough - the rule-based data governance workflow
###############################################################################
#
# One script, end to end: take a raw CSV, build a Data Governance File (DGF),
# correct what the machine could not guess, produce a governed CSV, and render a
# Research Guide. Run it from the package root:
#
#     Rscript working-example/walkthrough.R
#
# The demo data (data-dev/DEMO-DATA-SMALL.csv) is a real, slightly messy extract
# of IRS nonprofit records - exactly the kind of file that has no schema, where
# "201912" might be a date and an 11-digit number might be an ID. That is the
# problem the DGF solves.
#
# See also: working-example/STEP-temporal-demo.R for a compact showcase built
# around the temporal detectors, and the "Rule-Based Data Governance" vignette
# for the concepts behind each step.

library( datagoodr )

raw_path <- "data-dev/DEMO-DATA-SMALL.csv"


## ---------------------------------------------------------------------------
## 1. Create the DGF - the rough first pass
## ---------------------------------------------------------------------------
# create_dgf() profiles every column and runs the detector library over it
# (guess_data_type, using the variable name as a hint). It writes DGF.csv and
# DGF.xlsx and returns the DGF: one row per variable, storage + a first guess at
# the semantic type/subtype/class, factor levels, near-unique key flags, and the
# rg_ profile (stats + graphic) the guide renders from.

dgf <- create_dgf( raw_path,
                   dir  = "working-example",
                   file = "DGF",
                   open = FALSE )


## ---------------------------------------------------------------------------
## 2. Correct what the data alone cannot tell you  (retype_dgf)
## ---------------------------------------------------------------------------
# The guesser is good but conservative - some meaning simply is not recoverable
# from the bytes. Two classic cases in this dataset:
#
#   * F9_00_TAX_PERIOD_END_DATE holds values like "201912" (YYYYMM). Stored as a
#     number, it reads as a category; it is really a monthly DATE.
#   * CEO_CENSUSTRACT holds 11-digit codes like "36081001900". Stored as a big
#     number, but it is an IDENTIFIER (a geography key), not a quantity.
#
# retype_dgf() applies your corrections AND re-profiles just those variables, so
# the stored graphic matches the new type. Pass units for temporals - the guide
# picks the graphic (calendar / month bars / ...) from stable_data_unit.

dgf <- retype_dgf( dgf, raw_path,
  types = c( F9_00_TAX_PERIOD_END_DATE    = "temporal",
             F9_00_TAX_PERIOD_END_DATE_PY = "temporal",
             CEO_CENSUSTRACT              = "identifier" ),
  units = c( F9_00_TAX_PERIOD_END_DATE    = "month",
             F9_00_TAX_PERIOD_END_DATE_PY = "month" ) )

# The guesser already nailed the others: EIN and COUNTY_FIPS are identifiers,
# the F9_* dollar columns are numbers, N/Y and IN/OUT flags are booleans.


## ---------------------------------------------------------------------------
## 3. Add semantic context  (edit the desired_* fields)
## ---------------------------------------------------------------------------
# The desired_* fields say what a column should BE, independent of storage - the
# meaning a CSV cannot carry. Edit them in Excel (DGF.xlsx) or in R. A few IRS
# codes are nominal categories; COUNTY_FIPS is a geographic key when it joins.

set_desired <- function( dgf, var, subtype = "", class = "" ) {
  i <- match( var, dgf$var_name )
  if( subtype != "" ) dgf$desired_data_subtype[i] <- subtype
  if( class   != "" ) dgf$desired_data_class[i]   <- class
  dgf
}
dgf <- set_desired( dgf, "SUBSECCD", "nominal", "administrative_code" )
dgf <- set_desired( dgf, "NTEE1",    "nominal", "classification_code" )


## ---------------------------------------------------------------------------
## 4. Reformat rules - move raw -> a clean, governed CSV  (raw_to_stable_transform)
## ---------------------------------------------------------------------------
# A reformat rule is the NAME of an as_* function dropped in a cell. It is
# lossless - it just rewrites values in a canonical form every tool reads. Each
# as_* has an is_* guard that refuses to run on data it does not fit, so a
# mistyped rule errors instead of silently corrupting the column.
#
# (This dataset is already tidy; the line below shows the mechanism. Uncomment to
#  pin COUNTY_FIPS as a stable string identifier - as_id trims and coerces to
#  character, preserving any leading zeros a numeric read would drop.)
#
# i <- match( "COUNTY_FIPS", dgf$var_name )
# dgf$raw_to_stable_transform[i] <- "as_id"

# Apply the reformat rules to the raw extract -> a canonical governed data frame,
# then write it with an embedded, portable copy of the DGF (self-describing CSV).
stable <- stabilize_data( raw_path, dgf )
write_stable_csv( stable, "working-example/DGF-governed.csv", dgf = dgf )


## ---------------------------------------------------------------------------
## 5. Validate, then render the Research Guide
## ---------------------------------------------------------------------------
# inspect_dgf() checks the DGF is well formed before rendering: required columns
# present, every desired_data_type renderable, the JSON profile columns valid.
report <- inspect_dgf( dgf )
stopifnot( report$valid )

# create_rg() scaffolds a Quarto project pointed at the DGF and (render = TRUE)
# builds it. It drops a DG.R you can edit to customize formatting / layouts.
create_rg( dgf  = "working-example/DGF.xlsx",
           dir  = "working-example",
           file = "research-guide.qmd",
           render    = TRUE,
           overwrite = TRUE )


## ---------------------------------------------------------------------------
## 6. Refresh when the data changes  (update_dgf)
## ---------------------------------------------------------------------------
# When a newer extract arrives, update_dgf() compares it to the DGF by each
# variable's content hash: unchanged variables keep their curated row (your
# types, units, rules, labels); changed or added variables are re-profiled. It
# also re-runs the rule guards against the new data and flags any that no longer
# fit (because the file was cleaned). Here we reuse the demo data as the "new"
# extract.
#
# df_new <- readr::read_csv( raw_path )
# dgf    <- update_dgf( dgf, df_new, file = "working-example/DGF" )
# attr( dgf, "stale_rules" )   # rules whose is_* guard no longer matches
