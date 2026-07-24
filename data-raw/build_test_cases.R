## data-raw/build_test_cases.R
## -------------------------------------------------------------------------
## Workflow that applies the AutoType functions to every registered data type
## to produce:
##   (1) data/data_type_tests.rda  -- the frozen, seeded fixture bundled with
##       the package and documented in R/00-data.R.
##   (2) data-types/validator-reports/ -- human-readable per-type error
##       reports plus a master summary table (dev artifacts, not shipped).
##
## The type list is driven entirely by R/00-data-type-registry.R and the
## vectors in data-raw/datatypes/. Adding a family (its datatypes file,
## detectors, and registry lines) is all that is needed; this script needs no
## edits.
##
## Run from the package root:
##   Rscript data-raw/build_test_cases.R
## Re-run after editing any datatypes file or detector.
## -------------------------------------------------------------------------

SEED <- 514

## --- load the package (namespace incl. sysdata lookups + helpers) -----------
if (requireNamespace("pkgload", quietly = TRUE)) {
  suppressMessages(pkgload::load_all(".", quiet = TRUE))
} else {
  ## fallback: source detector code and load internal data by hand
  suppressWarnings({
    source("R/00-autotype-functions.R")
    source("R/00-dt-helpers.R")
    source("R/00-data-type-registry.R")
    for (f in list.files("R", pattern = "^dt-.*\\.R$", full.names = TRUE)) source(f)
  })
  load("R/sysdata.rda")
}

## --- load every positive-example vector from data-raw/datatypes/ -----------
datatype_env <- new.env()
for (f in list.files("data-raw/datatypes", pattern = "\\.R$", full.names = TRUE)) {
  sys.source(f, envir = datatype_env)
}

## resolve the registry against the sourced package objects
detectors <- data_type_detectors()
labels    <- data_type_labels()
types     <- names(.data_type_registry)

## sanity: every registered type must have a matching positive vector
missing_vecs <- setdiff(types, ls(datatype_env))
if (length(missing_vecs) > 0) {
  stop("No positive-example vector found in data-raw/datatypes/ for: ",
       paste(missing_vecs, collapse = ", "))
}

## --- (1) build the bundled, seeded fixture ---------------------------------
data_type_tests <- lapply(types, function(nm) {
  P <- get(nm, envir = datatype_env)
  generate_autotype_test_cases(P, data_type = nm, seed = SEED)
})
names(data_type_tests) <- types

if (!dir.exists("data")) dir.create("data")
save(data_type_tests, file = "data/data_type_tests.rda", version = 2,
     compress = "xz")
message("Wrote data/data_type_tests.rda (", length(data_type_tests), " types)")

## --- (2) build the human-readable reports ----------------------------------
report_dir <- "data-types/validator-reports"
if (!dir.exists(report_dir)) dir.create(report_dir, recursive = TRUE)

summary_rows <- list()
for (nm in types) {
  P   <- get(nm, envir = datatype_env)
  res <- build_autotype_results(detectors[[nm]], P, seed = SEED)

  report_txt <- capture.output(generate_autotype_report(res, labels[[nm]]))
  writeLines(report_txt, file.path(report_dir, paste0(nm, ".txt")))

  summary_rows[[nm]] <- autotype_summary_row(labels[[nm]], P, res)
}

summary_tbl <- do.call(rbind, summary_rows)
write.csv(summary_tbl, file.path(report_dir, "summary.csv"), row.names = FALSE)
saveRDS(summary_tbl, file.path(report_dir, "summary.rds"))

cat("\n=== SUMMARY TABLE ===\n")
print(summary_tbl, row.names = FALSE, digits = 3)
message("\nWrote reports to ", report_dir, "/")
