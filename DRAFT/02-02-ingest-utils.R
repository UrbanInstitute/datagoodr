library( dplyr )

path <- "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/datagood"
setwd( path )


as_mm <- function(x) {
  x <- x %>% 
    stringr::str_pad( 2, side="left", pad="0" )
  return(x)
}


drop_empty <- function(x) {
  x <- x[ ! is.na(x) ]
  x <- x[ x != "" ]
  return(x)
}


load_dgf <- function( filename="DGF.xlsx" )
{
  dgf <- 
    openxlsx::read.xlsx( 
      xlsxFile=filename,
      sheet="DGF" )
  return(dgf)
}

fn <- "DGF-CORE-CO-2019.xlsx"
dgf <- load_dgf( fn )

d2 <- load_dgf( )



get_convert_rules <- function( dgf ) {

  rules <- 
    dgf$dgf_raw_convert %>%
    na.omit() %>% 
    unique()

  rules <- 
    gsub( "\\(\\)", "", rules )

  return( rules )
}

rules <- get_convert_rules( wb )


is_function <- function( rules ) {

  fx <- 
    rules %>%
    sapply( find ) 

  missing <- 
    names(fx)[ as.character(fx) == "character(0)" ]

  if( length(missing) > 0 )
  {
    cat( "\nThe following functions \n" )
    cat( "are not defined: \n\n" )
    cat( paste0( " - ", missing, "()", collapse="\n" ) )
    cat( "\n\nAdd them to 'dgf.R'\n\n" )
    return( invisible( missing ) )
  }

  cat( "\nAll import rules are valid functions.\n\n" )

}

fake_fx <- function(x){ return(x) }

rules1 <- c("as.numeric","as.character","fake_fx","as_mm","as_yy")
rules2 <- c("as.numeric","as.character","fake_fx")

is_function( rules )
is_function( rules2 )



validate_json <- function(v)
{
  is.valid <- sapply( v, jsonlite::validate, USE.NAMES=F )
  return( is.valid )
}

check_json <- function( dgf ) {

  v <- dgf$dgf_f_levels
  v <- drop_empty( v )
  x <- validate_json( v )

  if( all(x) )
  { return(NULL) }
  
  return( v[!x] ) # invalid cases
}

x <- check_json( dgf )

if( ! is.null(x) )
{ lapply( x, get_json_error ) }


get_json_error <- function(x)
{
  r <- jsonlite::validate(x)
  error.message <- attr( r, "err" )
  return( error.message )
}
  
lapply( x, get_json_error )


show_invalid <- function(v)
{
  not.valid <- ! validate_json(v)
  nv <- v[ not.valid ]
  show_problem <- function(x)
  { print(get_json_error(x)); cat(paste0(x,"\n\n")) }
  sapply( nv, show_problem, USE.NAMES=F )
  return(invisible(NULL))
}

lapply( x, show_invalid )



sapply( rules, find )

c("as.character()", "as_mm()", "as.factor()", NA, "as.numeric()", 
"as_yyyy()", "as_yyyymm()")


as.factor()


dput( unique( d$dgf_raw_convert ) )
c("as.character()", "as_mm()", "as.factor()", NA, "as.numeric()", 
"as_yyyy()", "as_yyyymm()")
