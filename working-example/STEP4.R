######################
### Step 04: Refresh the DGF when the data changes
######################

# When the dataset is updated, update_dgf() compares the new data to the
# existing DGF using each variable's rg_hash. Unchanged variables keep their
# curated DGF row; changed or newly added variables have their data summaries
# recomputed. Curated fields (descriptions, aliases, scope, location,
# conversion/format rules, and factor level labels) are preserved.

library( datagoodr )


## The DGF you built and curated in Steps 1-2.
dgf <- readxl::read_xlsx( "working-example/DGF-V2.xlsx" )

## The refreshed dataset (here we just reuse the demo data; in practice this
## would be a newer extract of the same dataset).
df.new <- readr::read_csv( "data-dev/DEMO-DATA-SMALL.csv" )


## Refresh. A report prints which variables were unchanged / changed / added /
## removed, and the updated DGF is written to working-example/DGF-V3.*
dgf.v3 <- update_dgf( dgf, df.new, file = "working-example/DGF-V3" )

attr( dgf.v3, "status" )    # per-variable: unchanged / changed / added
attr( dgf.v3, "removed" )   # variables no longer in the data

## Re-validate before rendering (Step 2), then render (Step 3) as usual.
