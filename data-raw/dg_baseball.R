# Generates data/dg_baseball.rda and data/dg_baseball_dictionary.rda - a compact
# baseball test dataset for the examples and the example research guide.
#
# Source: data-dev/bb.csv (4,620 players x 19 columns) and its dictionary
# data-dev/bb-data-dictionary.csv. Kept: the 678 players whose first major
# league appearance (debut) fell in 2010-2014. Every column stays text, exactly
# as it arrived ("$851,950", "Dec 27, 1981", "R"/"L"/"B"), so the typing and
# stabilizing steps have real work to do.
#
# Re-run from the package root with:  Rscript data-raw/dg_baseball.R

bb <- utils::read.csv( "data-dev/bb.csv", colClasses = "character",
                       check.names = FALSE )

debut.year  <- as.integer( substr( bb$debut, 1, 4 ) )
dg_baseball <- bb[ debut.year %in% 2010:2014, ]
rownames(dg_baseball) <- NULL

dd <- utils::read.csv( "data-dev/bb-data-dictionary.csv", stringsAsFactors = FALSE )
dg_baseball_dictionary <- dd[ match( names(dg_baseball), dd$variable ),
                              c( "variable", "label", "description" ) ]
rownames(dg_baseball_dictionary) <- NULL

stopifnot( nrow(dg_baseball) == 678,
           identical( dg_baseball_dictionary$variable, names(dg_baseball) ) )

save( dg_baseball, file = "data/dg_baseball.rda", compress = "xz" )
save( dg_baseball_dictionary, file = "data/dg_baseball_dictionary.rda", compress = "xz" )
