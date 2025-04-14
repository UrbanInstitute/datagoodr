
design <- 
 c( "div2 ;; vlabel  ;; v_to_txt  ;; LABEL",
    "div3 ;; vtype   ;; v_to_txt  ;; DATA TYPE",
    "div3 ;; scope   ;; v_to_txt  ;; SCOPE" )


design <- 
 c( "div2 ;; vlabel  ;; v_to_txt  ;; LABEL",
    "div3 ;; vtype   ;; v_to_txt  ;; DATA TYPE",
    "div3 ;; scope   ;; v_to_txt  ;; SCOPE",
    "div4 ;; desc    ;; v_to_txt  ;; DESCRIPTION",
    "div4 ;; flevels ;; f_to_txt ;; LEVELS",
    "div4 ;; glevels ;; v_to_txt",
    "div4 ;; loc     ;; v_to_txt ;; LOCATION CODE",
    "div5 ;; v  ;; get_properties ;; LABEL  )

parse_design <- function( x ) {
  x <- gsub( ";;$", ";; ", x )
  L <- strsplit( x, ";;" ) 
  L <- lapply( L, trimws )
  L <- lapply( L, check_length )
  d <- dplyr::bind_rows( L )
  return( d) 
}

check_length <- function(x) {
  # add empty element if no label is provided
  if( length(x) == 3 )
  { x <- c( x, "" ) }
  # check for malformed design
  if( length(x) != 4 )
  { stop("malformed design argument") }
  names(x) <- c("DIV","VNAME","FUNCTION","LABEL")
  return(x) 
}

dd <- parse_design( design )



f1 <- function( a, b )
{
  args <- as.list( environment() )
  do.call( f2, args )
}

f2 <- function( a, b )
{
  2*a + 3*b
}

f1( a=2, b=1 )
f1( b=1, a=2 )
f1( 2, 1 )
f1( 1, 2 )


f1 <- function( f, ... )
{
  # args <- as.list( environment() )
  args <- list(...)
  do.call( f, args )
}

f1( f="f2", a=2, b=1 )

############

# v is a variable name - 
#  need to retrieve the value of v first
# v.lab is a label (string) 

v_to_txt <- function( v, v.lab )
{
  txt <- paste0( "**", v.lab, "**", ": ", get(v), "\n\n" )
  cat( txt )
}

# |DIV  |VNAME  |FUNCTION |LABEL     |
# |:----|:------|:--------|:---------|
# |div2 |vlabel |v_to_txt |LABEL     |
# |div3 |vtype  |v_to_txt |DATA TYPE |
# |div3 |scope  |v_to_txt |SCOPE     |


vvname     <- dd[[ "VNAME" ]] [ dd$DIV == "div2" ]
vvfunction <- dd[[ "FUNCTION" ]] [ dd$DIV == "div2" ]
vvlabel    <- dd[[ "LABEL" ]] [ dd$DIV == "div2" ]

get( vvname )



vlabel <- "some label text"
vtype  <- "character"
scope  <- "PC"

f1 <- function( f, ... )
{
  args <- list(...)
  do.call( f, args )
}

f1( f=vvfunction, v=vvname, v.lab=vvlabel )

### alternatively 

v_to_txt <- function( v, v.lab )
{
  txt <- paste0( "**", v.lab, "**", ": ", v, "\n\n" )
  cat( txt )
}

f1( f=vvfunction, v=get(vvname), v.lab=vvlabel )


##########

# need to map 

# |DIV  |VNAME  |FUNCTION |LABEL     |
# |:----|:------|:--------|:---------|
# |div2 |vlabel |v_to_txt |LABEL     |
# |div3 |vtype  |v_to_txt |DATA TYPE |
# |div3 |scope  |v_to_txt |SCOPE     |


map( dd )

##########


v_to_txt( v="scope", v.lab="SCOPE" )




check_length <- function(x) {
  # add empty element if no label is provided
  if( length(x) == 3 )
  { x <- c( x, "" ) }
  # check for malformed design
  if( length(x) != 4 )
  { stop("malformed design argument") }
  names(x) <- c("DIV","VNAME","FUNCTION","LABEL")
  return(x) 
}


to_txt_string <- function( x, x.lab=NULL )
{
  txt <- paste0( "**", x.lab, "**", ": ",  x, "\n\n" )
  cat( txt )
}

to_txt_factor <- function( x, x.lab=NULL )
{
  cat( paste0( "##### ", x.lab, "\n\n" ) )
  cat( paste0( x, " \n" ), sep="" )
  cat( "\n\n" )
}

v_to_txt <- function( v, v.lab )
{
  txt <- paste0( "**", x.lab, "**", ": ",  x, "\n\n" )
  cat( txt )
}



build_properties_numeric <- function( x, x.lab=NULL )
{
  dist <- length( unique( x ) )
  dist.p <- dist/length( x )
  miss <- sum( is.na( x ) )
  miss.p <- miss/length( x )
  prop.value <- c( dist, dist.p, miss, miss.p )
  prop.labels <- c( "Distinct (n)", "Distinct (%)", "Missing (n)", "Missing (%)" )
  properties <- data.frame( prop.labels, prop.value )
  cat( paste0( "##### ", x.lab, "\n\n" ) )
  cat( paste0( kable( properties ), " \n" ), sep="" )
  cat( "\n\n" )
}

build_quanttable_numeric <- function( x, x.lab=NULL )
{
  quant.value <- quantile( x, c( 0.05, 0.25, 0.50, 0.75, 0.95 ) )
  quant.labels <- c( "Q-05", "Q-25", "Q-50", "Q-75", "Q-95" )
  quant <- data.frame( quant.labels, quant.value )
  cat( paste0( "##### ", x.lab, "\n\n" ) )
  cat( paste0( remove_column( kable( quant ), 1 ), " \n" ), sep="" )
  cat( "\n\n" )
}

build_stattable_numeric <- function( x, x.lab=NULL )
{
  min <- min( x, na.rm=T )
  median <- median( x, na.rm=T )
  mean <- mean( x, na.rm=T )
  max <- max( x, na.rm=T )
  skew <- skew( x, na.rm=T )
  kurt <- kurtosi( x, na.rm=T )
  stat.value <- c( min, median, mean, max, skew, kurt)
  stat.labels <- c( "Min", "Median", "Mean", "Max", "Skew", "Kurt" )
  stat <- data.frame( stat.labels, stat.value )
  cat( paste0( "##### ", x.lab, "\n\n" ) )
  cat( paste0( kable( stat ), " \n" ), sep="" )
  cat( "\n\n" )
}



################################
################################
################################




design <- 
 c( "div2 ;; vlabel  ;; LABEL        ;; v_to_txt",
    "div3 ;; vtype   ;; DATA TYPE    ;; v_to_txt",
    "div3 ;; scope   ;; SCOPE        ;; v_to_txt",
    "div4 ;; desc    ;; DESCRIPTION  ;; v_to_txt",
    "div4 ;; flevels ;; LEVELS       ;; f_to_txt",
    "div4 ;; glevels ;; ''           ;; v_to_txt",
    "div4 ;; loc     ;; LOCATION CODE ;; v_to_txt",
    "div5 ;; v       ;; LABEL        ;; get_properties"  )

parse_design <- function( x ) {
  x <- gsub( ";;$", ";; ", x )
  L <- strsplit( x, ";;" ) 
  L <- lapply( L, trimws )
  L <- lapply( L, check_length )
  d <- dplyr::bind_rows( L )
  return( d ) 
}

check_length <- function(x) {
  # add empty element if no label is provided
  if( length(x) == 3 )
  { x <- c( x, "" ) }
  # check for malformed design
  if( length(x) != 4 )
  { stop("malformed design argument") }
  names(x) <- c("DIV","VNAME","LABEL","FUNCTION")
  return(x) 
}


design <- 
 c( "div2 ;; vlabel  ;; LABEL         ;; v_to_txt",
    "div3 ;; vtype   ;; DATA TYPE     ;; v_to_txt",
    "div3 ;; scope   ;; SCOPE         ;; v_to_txt",
    "div4 ;; desc    ;; DESCRIPTION   ;; v_to_txt",
    "div4 ;; flevels ;; FACTOR LEVELS ;; v_to_txt" )


dd <- parse_design( design )

dL <- dd %>% group_by(DIV) %>% group_split( .keep=T )

dL <- split( dd, ~ DIV )

d3 <- dL[[3]]

dL["div4"] %>% knitr::kable()

dgf_do <- function( df ) {
  fx <- df[["FUNCTION"]]
  args <- df[c("VNAME","LABEL")]
  do.call( fx, args )
}

dgf_do <- function( FUNCTION, VNAME, LABEL ) {
  fx <- FUNCTION
  args <- list(VNAME,LABEL)
  do.call( fx, args )
}


dgf_do( d4 )


pmap( dL["div4"], dgf_do )

d5 <- select( d3, VNAME, LABEL, FUNCTION )

pmap( d5, dgf_do )


v_to_txt <- function( VNAME, LABEL )
{
  txt <- paste0( "**", LABEL, "**", ": ",  VNAME, "\n\n" )
  cat( txt )
}

  


f1 <- function( a, b )
{
  args <- as.list( environment() )
  do.call( f2, args )
}

f2 <- function( a, b )
{
  2*a + 3*b
}

f1( a=2, b=1 )
f1( b=1, a=2 )
f1( 2, 1 )
f1( 1, 2 )

f1( list( a=2, b=1 ) )


f1 <- function( f, ... )
{
  # args <- as.list( environment() )
  args <- list(...)
  print( args )
  # do.call( f, args )
}

f1( f="f2", a=2, b=1 )

f1( f="f2", list( a=2, b=1 ) )

do.call( f2, list( a=2, b=1 ) )
do.call( f2, list( b=1, a=2 ) )


library( purrr )

a <- c(1,2,3)
b <- c(1,1,1)
# 5, 7, 9

a <- 

map2( a, b, f2 )
pmap( list(a,b), f2 )



x <- c( a="A", b="B", c="f9" )

f9 <- function( a, b )
{ paste0( a, b ) }

ff <- function( x ) {

  print(x)
  f <- x["c"]
  args <- x[ c("a","b") ] 
  map( args, f )

}

ff( x )



f9 <- function( ... )
{ 
  args <- list(...) 
  do.call( paste0, args ) 
}


x <- list( a="A", b="B" )
lapply( x, f9 )




