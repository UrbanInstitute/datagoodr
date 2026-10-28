###############################################################################
### Recompute only the histogram data (rg_graphics) for numeric variables
###############################################################################
# Picks up the heaped-data binning in get_graphics_num() without rebuilding the
# DGF, so hand edits to DGF.xlsx (labels, types, descriptions) are kept.
# Run from the package root:  Rscript working-example/baseball/refresh-histograms.R

library( datagoodr )

out <- "working-example/baseball"
dgf <- load_dgf( file.path( out, "DGF.xlsx" ), reader = "readxl" )
raw <- read.csv( "data-dev/bb.csv", colClasses = "character", check.names = FALSE )

num <- dgf$var_name[ dg_render_type( dgf ) == "number" ]
df  <- as.data.frame( lapply( raw[ num ], function( v )
         suppressWarnings( readr::parse_number( v ) ) ) )

for( v in num ) {
  i <- match( v, dgf$var_name )
  dgf$rg_graphics[i] <- as.character( datagoodr:::get_graphics_num( v, df ) )
}

save_to_excel( dgf, file.path( out, "DGF.xlsx" ), open = FALSE )
message( "Refreshed histograms for: ", paste( num, collapse = ", " ) )
