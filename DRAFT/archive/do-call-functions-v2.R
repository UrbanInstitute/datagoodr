|DIV  |VNAME   |LABEL         |FUNCTION |
|:----|:-------|:-------------|:--------|
|div4 |desc    |DESCRIPTION   |v_to_txt |
|div4 |flevels |FACTOR LEVELS |v_to_txt |

d4 <- 
structure(list(DIV = c("div4", "div4"), VNAME = c("desc", "flevels"
), LABEL = c("DESCRIPTION", "FACTOR LEVELS"), FUNCTION = c("v_to_txt", 
"v_to_txt")), row.names = c(NA, -2L), class = "data.frame")


desc <- "a longer description"
flevels <- "a table of factor levels"

ff <- function( d4, desc, flevels ) {



v_to_txt <- function( VNAME, LABEL )
{
  txt <- paste0( "**", LABEL, "**", ": ",  VNAME, "\n\n" )
  cat( txt )
}

################################################



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


################################################


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




