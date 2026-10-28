###############################################################################
### Research Guide for dplyr::starwars
###############################################################################
# Builds a DGF for dplyr::starwars (87 characters x 14 columns; list columns
# like films are collapsed to "a|b|c" by create_dgf), then renders both the
# standard research guide and the experimental rail-style draft.
# Run from the package root:  Rscript working-example/starwars/make-starwars-rg.R

library( datagoodr )

out <- "working-example/starwars"
dir.create( out, showWarnings = FALSE )

dgf <- create_dgf( dplyr::starwars, dir = out, file = "DGF", open = FALSE )

## standard research guide
create_rg( dgf, dir = out, render = TRUE, overwrite = TRUE )

## experimental rail-style draft (files shared with the baseball example)
src <- "working-example/baseball"
file.copy( file.path( src, c( "rg-rail.R", "rg-rail.css" ) ), out, overwrite = TRUE )
qmd <- readLines( file.path( src, "research-guide-rail.qmd" ) )
qmd <- sub( '^subtitle: .*', 'subtitle: "Star Wars characters, dplyr::starwars"', qmd )
writeLines( qmd, file.path( out, "research-guide-rail.qmd" ) )
quarto::quarto_render( file.path( out, "research-guide-rail.qmd" ), quiet = TRUE )
