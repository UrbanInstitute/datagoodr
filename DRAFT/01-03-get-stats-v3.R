# library( dplyr )
# path <- "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/datagood/R"
# setwd( path )
# df <- readr::read_csv( "../data/CORE-2019-NONPROFIT-SCOPE-501CE-PZ.csv" )


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

skew <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  s <- (sum((x - mean(x))^3)/n)/(sum((x - mean(x))^2)/n)^(3/2)
  return( round(s,2) ) 
}

kurtosis <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  k <- n * sum((x - mean(x))^4)/(sum((x - mean(x))^2)^2)
  return( round(k,2) )
}

get_top_vals <- function(x) {
  t <- table(x) |> sort(decreasing=T) |> head(5)
  tt <- as.vector(t)
  names(tt) <- paste0( "top.", names(t) )
  df <- tt |> as.list() |> data.frame()  
  return(df)
}

jsonify_stats <- function( df ) {
  jd <- jsonlite::toJSON( df )
  jd <- gsub( ",", ", \n    ", jd )
  jd <- gsub( "\\{", "  \\{ \n    ", jd )
  jd <- gsub( ":", "  :  ", jd )
  jd <- gsub( '","', '",  "', jd )
  jd <- gsub( "\\}", "\n  \\}", jd )
  jd <- gsub( "\\[", "\\[ \n", jd )
  jd <- gsub( "\\]", "\n\\]", jd )
  return(jd)
}



# if x is.character
# x <- nchar(x)

get_stats <- function( varname ){

  # varname <- "PROGREVP"
  x <- df[[varname]]

  class.x <- class(x)

  if( class(x) == "factor" )
  {  x <- as.character(x)  }

  if( class(x) == "character" )
  {  x <- nchar(x)  }

  N <- length(x)
  distinct.n <- unique(x) |> length()
  distinct.p <- ( distinct.n / N  )|> round(2)
  duplicated.p <- 1 - distinct.p
  zero.n  <- sum( x == 0, na.rm=T )
  zero.p  <- ( zero.n / N ) |> round(2)
  empty.n <- sum( x == "", na.rm=T )
  empty.p <- ( empty.n / N ) |> round(2)
  na.n    <- sum( is.na(x) | is.nan(x) )
  na.p    <- ( na.n / N ) |> round(2)
  inf.n   <- sum( is.infinite(x) )
  missing.n <- is_missing(x)
  missing.p <- ( is_missing(x) / N ) |> round(2)
  most.common.v <- most_common_val(x)
  most.common.p <- most_common_p( x, most.common.v )
  
  q05 <- quantile( x, probs=0.05, na.rm=T, names=F )
  q25 <- quantile( x, probs=0.25, na.rm=T, names=F )
  q50 <- quantile( x, probs=0.50, na.rm=T, names=F )
  q75 <- quantile( x, probs=0.75, na.rm=T, names=F )
  q95 <- quantile( x, probs=0.95, na.rm=T, names=F )

  min.x    <- min(  x, na.rm=T ) 
  max.x    <- max(  x, na.rm=T )
  mean.x   <- mean( x, na.rm=T )
  median.x <- q50

  skew.x <- skew(x)
  kurt.x <- kurtosis(x)

  df <- data.frame( 
    varname, N, class.x,
    distinct.n, distinct.p, duplicated.p,
    zero.n, zero.p, empty.n, empty.p,
    na.n, na.p, inf.n, 
    missing.p, missing.n,
    most.common.v, most.common.p,
    q05, q25, q50, q75, q95,
    min.x, median.x, mean.x, max.x, 
    skew.x, kurt.x )
    
  return( df )
}
  
# stats <- get_stats("PROGREVP")
# knitr::kable( t(stats), format = "pipe" )




get_properties <- function( stats ){

  f <- function(x){ format(x,big.mark=",") }
  stats <- sapply( stats, f )

  VAL <- 
    c( stats[["N"]],
       stats[["distinct.n"]], stats[["distinct.p"]],
       stats[["duplicated.p"]],
       stats[["most.common.v"]], stats[["most.common.p"]],
       stats[["zero.n"]], stats[["zero.p"]],
       stats[["missing.n"]],
       stats[["na.n"]], stats[["na.p"]],
       stats[["inf.n"]] )

  STAT <-
    c( "Rows (N)", 
       "Distinct (N)", "Distinct (%)", "Duplicates (%)", 
       "Most Common Value", "Most Common Val (%)",
       "Zero (N)", "Zero (%)",
       "All Empty (N)",
       "Missing/NA (N)", "Missing/NA (%)",
       "Infinite (N)")

  t <- data.frame( STAT, VAL )
  k <- knitr::kable( t, align=c("l","r") )
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}


# get_properties( stats )



##############################




get_stats <- function( varname ){

  # varname <- "PROGREVP"
  x <- df[[varname]]

  class.x <- class(x)

  if( class(x) == "factor" )
  {  x <- as.character(x)  }

  if( class(x) == "character" )
  {  x <- nchar(x)  }

  N <- length(x)
  distinct.n <- unique(x) |> length()
  distinct.p <- ( distinct.n / N  )|> round(2)
  duplicated.p <- 1 - distinct.p
  zero.n  <- sum( x == 0, na.rm=T )
  zero.p  <- ( zero.n / N ) |> round(2)
  empty.n <- sum( x == "", na.rm=T )
  empty.p <- ( empty.n / N ) |> round(2)
  na.n    <- sum( is.na(x) | is.nan(x) )
  na.p    <- ( na.n / N ) |> round(2)
  inf.n   <- sum( is.infinite(x) )
  missing.n <- is_missing(x)
  missing.p <- ( is_missing(x) / N ) |> round(2)
  most.common.v <- most_common_val(x)
  most.common.p <- most_common_p( x, most.common.v )
  
  q05 <- quantile( x, probs=0.05, na.rm=T, names=F )
  q25 <- quantile( x, probs=0.25, na.rm=T, names=F )
  q50 <- quantile( x, probs=0.50, na.rm=T, names=F )
  q75 <- quantile( x, probs=0.75, na.rm=T, names=F )
  q95 <- quantile( x, probs=0.95, na.rm=T, names=F )

  min.x    <- min(  x, na.rm=T ) 
  max.x    <- max(  x, na.rm=T )
  mean.x   <- mean( x, na.rm=T )
  median.x <- q50

  skew.x <- skew(x)
  kurt.x <- kurtosis(x)

  df <- data.frame( 
    varname, N, class.x,
    distinct.n, distinct.p, duplicated.p,
    zero.n, zero.p, empty.n, empty.p,
    na.n, na.p, inf.n, 
    missing.p, missing.n,
    most.common.v, most.common.p,
    q05, q25, q50, q75, q95,
    min.x, median.x, mean.x, max.x, 
    skew.x, kurt.x )
    
  return( df )
}
  
stats <- get_stats("PROGREVP")
knitr::kable( t(stats), format = "pipe" )

get_properties( stats )

get_properties <- function( stats ){

  f <- function(x){ format(x,big.mark=",") }
  stats <- sapply( stats, f )

  VAL <- 
    c( stats[["N"]],
       stats[["distinct.n"]], stats[["distinct.p"]],
       stats[["duplicated.p"]],
       stats[["most.common.v"]], stats[["most.common.p"]],
       stats[["zero.n"]], stats[["zero.p"]],
       stats[["missing.n"]],
       stats[["na.n"]], stats[["na.p"]],
       stats[["inf.n"]] )

  STAT <-
    c( "Rows (N)", 
       "Distinct (N)", "Distinct (%)", "Duplicates (%)", 
       "Most Common Value", "Most Common Val (%)",
       "Zero (N)", "Zero (%)",
       "All Empty (N)",
       "Missing/NA (N)", "Missing/NA (%)",
       "Infinite (N)")

  t <- data.frame( STAT, VAL )
  k <- knitr::kable( t, align=c("l","r") )
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}



hg <- function( x ) {
  t <- table( cut( x, 10 ) )
  par( mar=c(0,0,0,0) )
  barplot( 
    t, col="steelblue", 
    axisnames = FALSE )
}

hg(x)


