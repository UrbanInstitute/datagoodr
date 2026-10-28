###############################################################################
### Research Guide for mtcars
###############################################################################
# Builds a DGF for data-dev/mtcars.csv (R's mtcars, 32 cars x 13 columns, with
# the row names split into make and model), fills the labels and descriptions
# from ?mtcars, adds readable labels for the coded vs/am levels, and renders
# both the standard research guide and the experimental rail-style draft.
# Run from the package root:  Rscript working-example/mtcars/make-mtcars-rg.R

library( datagoodr )

out <- "working-example/mtcars"
dir.create( out, showWarnings = FALSE )

cars <- read.csv( "data-dev/mtcars.csv", colClasses = "character", check.names = FALSE )

## data dictionary (from ?mtcars, Motor Trend US magazine, 1974)
dd <- data.frame( stringsAsFactors = FALSE,
  variable = c( "make", "model", "mpg", "cyl", "disp", "hp", "drat", "wt",
                "qsec", "vs", "am", "gear", "carb" ),
  label = c( "manufacturer", "model", "miles per gallon", "cylinders",
             "displacement (cu. in.)", "gross horsepower", "rear axle ratio",
             "weight (1,000 lbs)", "quarter-mile time (sec)", "engine shape",
             "transmission", "forward gears", "carburetors" ),
  description = c(
    "Car manufacturer, split from the mtcars row names",
    "Car model, split from the mtcars row names",
    "Fuel economy in miles per (US) gallon",
    "Number of engine cylinders",
    "Engine displacement in cubic inches",
    "Gross horsepower",
    "Rear axle ratio",
    "Vehicle weight in thousands of pounds",
    "Fastest quarter-mile time from a standing start, in seconds",
    "Engine shape: 0 = V-shaped, 1 = straight (inline)",
    "Transmission: 0 = automatic, 1 = manual",
    "Number of forward gears",
    "Number of carburetors" ) )

m <- match( names(cars), dd$variable )
if( anyNA(m) ) stop( "Undocumented variables: ", paste( names(cars)[is.na(m)], collapse = ", " ) )

dgf <- create_dgf( cars,
                   dd_vlabel = dd$label[m],
                   dd_vdesc  = dd$description[m],
                   dir = out, file = "DGF-tmp", open = FALSE )
file.remove( file.path( out, c("DGF-tmp.csv", "DGF-tmp.xlsx") ) )

## vs and am are 0/1 codes, but the type guess reads them as counts: retype them
## as boolean (recomputes their profile) and give the codes readable labels
level_labels <- list(
  vs = c( "0" = "V-shaped", "1" = "straight" ),
  am = c( "0" = "automatic", "1" = "manual" ) )
dgf <- retype_dgf( dgf, cars, types = c( vs = "boolean", am = "boolean" ) )
for( v in names(level_labels) ) {
  i   <- match( v, dgf$var_name )
  lab <- level_labels[[v]]
  dgf$dd_f_levels[i] <- datagoodr:::jsonify_df(
    data.frame( level = names(lab), label = paste0( names(lab), " (", lab, ")" ) ) )
}

## make is a car manufacturer, not a place: drop the "geographic" guess
dgf$desired_semantic_type[ dgf$var_name == "make" ] <- "categorical"

## standard research guide (writes DGF.xlsx next to it)
create_rg( dgf, dir = out, render = TRUE, overwrite = TRUE )

## experimental rail-style draft (files shared with the baseball example)
src <- "working-example/baseball"
file.copy( file.path( src, c( "rg-rail.R", "rg-rail.css" ) ), out, overwrite = TRUE )
qmd <- readLines( file.path( src, "research-guide-rail.qmd" ) )
qmd <- sub( '^subtitle: .*', 'subtitle: "Motor Trend road tests, 32 cars (mtcars)"', qmd )
writeLines( qmd, file.path( out, "research-guide-rail.qmd" ) )
quarto::quarto_render( file.path( out, "research-guide-rail.qmd" ), quiet = TRUE )
