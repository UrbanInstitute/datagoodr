###############################################################################
### Build the example research guides shown on the documentation site
###############################################################################
# Renders the example research guides and copies them to
# pkgdown/assets/examples/, which pkgdown publishes at <site>/examples/:
#
#   baseball.html          dg_baseball (shipped with datagoodr) + its dictionary
#   baseball-compact.html  the same DGF in the compact style, for comparison
#   starwars.html          dplyr::starwars
#   mtcars.html            datasets::mtcars, with the names split into make/model
#
# vignettes/example-guides.Rmd shows the same code and links to the pages.
# Needs quarto and the suggested graphics packages (treemap, wordcloud, ...).
# Re-run from the package root after changing the report:
#
#   Rscript data-raw/example-guides.R                   # all of them
#   Rscript data-raw/example-guides.R baseball-compact  # just this one
#
# Each page is a few megabytes and is committed, so rebuild only what changed.

library( datagoodr )

out <- "pkgdown/assets/examples"
dir.create( out, recursive = TRUE, showWarnings = FALSE )

only <- commandArgs( trailingOnly = TRUE )

# Build in a temp folder (quarto writes scratch files next to the document),
# then keep just the self-contained .html.
build_guide <- function( dgf, name, style = "rail" ) {
  if( length(only) && ! name %in% only )
  { message( "Skipping ", name ); return( invisible(NULL) ) }
  work <- file.path( tempdir(), paste0( "rg-", name ) )
  unlink( work, recursive = TRUE ); dir.create( work )
  suppressMessages( create_rg( dgf, dir = work, file = paste0( name, ".qmd" ),
                               style = style, render = TRUE, overwrite = TRUE ) )
  file.copy( file.path( work, paste0( name, ".html" ) ), out, overwrite = TRUE )
  message( "Built ", file.path( out, paste0( name, ".html" ) ) )
}

# readable labels for coded factor levels (a level/label table per variable)
label_levels <- function( dgf, labels ) {
  for( v in names(labels) ) {
    i   <- match( v, dgf$var_name )
    lab <- labels[[v]]
    dgf$dd_f_levels[i] <- datagoodr:::jsonify_df(
      data.frame( level = names(lab), label = paste0( names(lab), " (", lab, ")" ) ) )
  }
  dgf
}


## baseball -------------------------------------------------------------------
dd  <- dg_baseball_dictionary
dgf <- create_dgf( dg_baseball, dd_vlabel = dd$label, dd_vdesc = dd$description,
                   dir = tempdir(), file = "DGF-baseball", open = FALSE )
dgf <- label_levels( dgf, list(
  bats   = c( R = "right", L = "left", B = "both" ),
  throws = c( R = "right", L = "left" ) ) )
build_guide( dgf, "baseball" )

# the same DGF, drawn in the compact style: same blocks, documentation density
build_guide( dgf, "baseball-compact", style = "compact" )


## starwars -------------------------------------------------------------------
dgf <- create_dgf( dplyr::starwars, dir = tempdir(), file = "DGF-starwars",
                   open = FALSE )
build_guide( dgf, "starwars" )


## mtcars ---------------------------------------------------------------------
cars <- data.frame( make  = sub( " .*", "", rownames(mtcars) ),
                    model = sub( "^\\S+ ?", "", rownames(mtcars) ),
                    lapply( mtcars, as.character ) )

labels <- c( make = "manufacturer", model = "model", mpg = "miles per gallon",
             cyl = "cylinders", disp = "displacement (cu. in.)",
             hp = "gross horsepower", drat = "rear axle ratio",
             wt = "weight (1,000 lbs)", qsec = "quarter-mile time (sec)",
             vs = "engine shape", am = "transmission", gear = "forward gears",
             carb = "carburetors" )
descs <- c( make = "Car manufacturer, split from the mtcars row names",
            model = "Car model, split from the mtcars row names",
            mpg = "Fuel economy in miles per (US) gallon",
            cyl = "Number of engine cylinders",
            disp = "Engine displacement in cubic inches",
            hp = "Gross horsepower", drat = "Rear axle ratio",
            wt = "Vehicle weight in thousands of pounds",
            qsec = "Fastest quarter-mile time from a standing start, in seconds",
            vs = "Engine shape: 0 = V-shaped, 1 = straight (inline)",
            am = "Transmission: 0 = automatic, 1 = manual",
            gear = "Number of forward gears", carb = "Number of carburetors" )

dgf <- create_dgf( cars, dd_vlabel = unname( labels[ names(cars) ] ),
                   dd_vdesc = unname( descs[ names(cars) ] ),
                   dir = tempdir(), file = "DGF-mtcars", open = FALSE )
# vs and am are 0/1 codes the type guess reads as counts: make them boolean
dgf <- retype_dgf( dgf, cars, types = c( vs = "boolean", am = "boolean" ) )
dgf <- label_levels( dgf, list( vs = c( "0" = "V-shaped", "1" = "straight" ),
                                am = c( "0" = "automatic", "1" = "manual" ) ) )
dgf$desired_semantic_type[ dgf$var_name == "make" ] <- "categorical"
build_guide( dgf, "mtcars" )

# mtcars is the only example dataset with boolean variables (vs, am), so the
# compact style's boolean graphic -- one divided bar, boolebar() -- can only be
# seen on this one. Built compact for that reason.
build_guide( dgf, "mtcars-compact", style = "compact" )
