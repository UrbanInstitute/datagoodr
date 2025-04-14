setwd( "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/datagood/data" )

nm <- 
c("NAME", "CONTACT", "ADDRESS", "CITY", "EIN", "SUBSECCD", "ACTIV1", 
"NTMAJ12", "NTEE1", "NTEEFINAL", "NTEESRC", "DEDUCTCD", "OUTREAS", 
"Q78A", "OUTNCCS", "FIPS", "CENSUSTRACT", "TAXPER", "TAXPERP", 
"STYEAR", "ACCPER", "TOTREV2", "ASS_BOY", "ASS_EOY", "NETA_BOY", 
"EXPS", "EXPSP")


d <- read.csv( "CORE-2019-NONPROFIT-SCOPE-501CE-PZ.csv" )

setdiff( nm, names(d) )

d2 <- d[ nm ]

write.csv( d2, "DEMO-DATA-FULL.csv", row.names=F, na="" )

d3 <- dplyr::sample_n( d2, 25000 )

write.csv( d3, "DEMO-DATA-SMALL.csv", row.names=F, na="" )






