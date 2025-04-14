library( dplyr )

path <- "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/datagood/R"
setwd( path )

df <- readr::read_csv( "../data/CORE-2019-NONPROFIT-SCOPE-501CE-PZ.csv" )


PROGREVP

REASON

Q78A


is_missing <- function(x) {
  v1 <- is.na(x)
  v2 <- is.nan(x)
  v3 <- is.infinite(x)
  v4 <- grepl( "^[ ]{0,}$", x )
  v5 <- x == "NA"
  v6 <- x == "."
  missing <- v1 | v2 | v3 | v4 | v5 | v6
  return( sum( missing, na.rm=T ) )
}

most_common_val <- function(x) {
  # use data table for speed: 
  mc <- as.data.table(x)[, .N, by=x][, x[N == max(N)]]
  return( as.character(mc[1]))
}

most_common_p <- function(x,val){
  mc.n <- sum( x == val, na.rm=T )
  mc.p <- ( mc.n / length(x) ) |> round(2)
}

varname <- "PROGREVP"
x <- df[[varname]]
N <- length(x)
distinct.n <- unique(x) |> length()
distinct.p <- ( distinct.n / N  )|> round(2)
zero.n  <- sum( x == 0, na.rm=T )
zero.p  <- ( zero.n / N ) |> round(2)
empty.n <- sum( x == "", na.rm=T )
empty.p <- ( empty.n / N ) |> round(2)
na.n    <- sum( is.na(x) | is.nan(x) )
na.p    <- ( na.n / N ) |> round(2)
inf.n   <- sum( is.infinite(x) )
missing.p <- ( is_missing(x) / N ) |> round(2)
most.common.v <- most_common_val(x)
most.common.p <- most_common_p( x, most.common.v )

t1 <- 
  data.frame( 
    varname, N,
    distinct.n, distinct.p,
    zero.n, zero.p, empty.n, empty.p,
    na.n, na.p, inf.n, missing.p,
    most.common.v, most.common.p )
    
knitr::kable( t(t1), format = "pipe" )



pander::pander(t1)

tt <- table( df$NTEE1 )
str(tt)

library( data.table )
setDT(t1)


