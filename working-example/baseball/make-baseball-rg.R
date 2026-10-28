###############################################################################
### Research Guide for the baseball test dataset
###############################################################################
# Builds a DGF for data-dev/bb.csv (4,620 players x 19 columns), fills the
# data dictionary fields from data-dev/bb-data-dictionary.csv, adds readable
# labels for the R/L/B codes, and renders the Research Guide. Run from the
# package root:  Rscript working-example/baseball/make-baseball-rg.R

library(datagoodr)

out <- "working-example/baseball"

## read everything as text, so "$851,950" and "Dec 27, 1981" arrive intact
bb <- read.csv( "data-dev/bb.csv", colClasses = "character", check.names = FALSE )
dd <- read.csv( "data-dev/bb-data-dictionary.csv", stringsAsFactors = FALSE )

m <- match( names(bb), dd$variable )
if( anyNA(m) ) stop( "Undocumented variables: ", paste( names(bb)[is.na(m)], collapse = ", " ) )

dgf <- create_dgf( bb,
                   dd_vlabel = dd$label[m],
                   dd_vdesc  = dd$description[m],
                   dir = out, file = "DGF-tmp", open = FALSE )
file.remove( file.path( out, c("DGF-tmp.csv", "DGF-tmp.xlsx") ) )

## readable labels for the coded factor levels (dd_f_levels is a level/label table)
level_labels <- list(
  bats   = c( R = "right", L = "left", B = "both" ),
  throws = c( R = "right", L = "left" ) )
for( v in names(level_labels) ) {
  i <- match( v, dgf$var_name )
  if( is.na(i) || ! nzchar( dgf$dd_f_levels[i] ) ) next
  tab <- jsonlite::fromJSON( dgf$dd_f_levels[i] )
  lab <- level_labels[[v]][ tab$level ]
  tab$label <- ifelse( is.na(lab), tab$level, paste0( tab$level, " (", lab, ")" ) )
  dgf$dd_f_levels[i] <- datagoodr:::jsonify_df( tab )
}

## write the DGF next to the report and render it
create_rg( dgf, dir = out, render = TRUE, overwrite = TRUE )
