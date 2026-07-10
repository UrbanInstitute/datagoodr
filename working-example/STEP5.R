######################
### Step 05: Customize
######################

# Step 5 scaffolds a self-contained documentation project from the package
# templates so you can customize a report without editing the package. A
# project directory holds:
#   - DGF.xlsx            the rules file (Steps 1-2)
#   - DG.R                custom formatting/graphic functions & layout overrides
#   - research-guide.qmd  (or data-dictionary.qmd)

library( datagoodr )


## Scaffold a research guide (full data profile) in a new project folder,
## pointed at your DGF. Also drops a starter DG.R you can edit.
create_rg( "working-example/DGF-V2.xlsx", dir = "working-example/my-guide" )

## ...or a data dictionary (descriptors only, no data profiles):
create_dd( "working-example/DGF-V2.xlsx", dir = "working-example/my-dictionary" )


## Customize:
##   1. Edit DG.R to override formatting/graphic functions or a layout object.
##      e.g. define layout.character to drop the word cloud, or redefine
##      dollarize() to change how monetary values print.
##   2. Edit the <style> block in the .qmd to change the page grid, fonts,
##      or colors.
##   3. Add long-form narrative and headings around the automatic sections.

## Then render (or pass render = TRUE above to scaffold and render in one step):
# quarto::quarto_render( "working-example/my-guide/research-guide.qmd" )


## ---------------------------------------------------------------------------
## Granular, inline documentation
## ---------------------------------------------------------------------------
## Beyond auto-rendering every variable, you can weave a single variable - or
## one element of its profile - into long-form narrative (call these inside a
## `results = "asis"` chunk in a Quarto document):

dgf <- readxl::read_xlsx( "working-example/DGF-V2.xlsx" )

dg_section( dgf, "NTMAJ12" )                 # one variable's full profile
dg_stats( dgf, "F9_08_REV_TOT_TOT" )         # just the summary stats
dg_quantiles( dgf, "F9_08_REV_TOT_TOT" )     # just the quantiles
dg_levels( dgf, "NTMAJ12" )                  # just the factor levels
dg_graphic( dgf, "F9_08_REV_TOT_TOT" )       # just the graphic (set fig dims)
dg_field( dgf, "EIN", "vdesc", "Description" ) # any DGF text field

