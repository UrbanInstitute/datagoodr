######################
### Step 02: Validate the DGF
######################

# After Step 1 creates the DGF and you have edited fields by hand (adding
# descriptions, aliases, conversion/format rules, etc.), Step 2 checks that the
# file is still well formed so that Step 3 can render it without error.
#
# inspect_dgf() checks that:
#   - all required DGF columns are present
#   - every vtype_class is renderable (numeric/character/factor/logical)
#   - the JSON columns still contain valid JSON
#   - every function named in vconvert/vformat is defined
#   - every variable has an rg_hash

library( datagoodr )


## Read the DGF you want to validate (the curated Step 1 output).
dgf <- readxl::read_xlsx( "working-example/DGF-V2.xlsx" )


## Inspect it. A report prints to the console; the return value records any
## problems found so you can act on them programmatically.
report <- inspect_dgf( dgf )

report$valid       # TRUE when the DGF is ready to render
report$problems    # a named list describing any issues (empty when valid)

## If report$valid is TRUE, continue to STEP3.R to render the Research Guide.
## If not, fix the flagged cells in the Excel file and re-run this step. For a
## closer look at any invalid JSON cells, use show_invalid( dgf$rg_stats ) etc.
