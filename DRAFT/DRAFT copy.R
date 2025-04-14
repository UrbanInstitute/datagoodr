wb <- openxlsx::read.xlsx( "../DGF-CORE-CO-2019.xlsx" )




library( dplyr )

path <- "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/datagood/R"
setwd( path )

# source( "00-data.R" )
source( "00-save-to-excel.R" ) 
source( "00-utils-pipe.R" ) 
source( "00-utils.R" )
source( "R/01-create-dgf.R" )
source( "01-dates.R" )   
source( "01-factors.R" )
source( "R/01-get-skimr-values.R" )
source( "02-ingest-raw.R" )   
source( "02-parse-rules.R" ) 
source( "02-validate-json.R" )
source( "build-dd.R" )    
source( "dgf.R" )

df <- readr::read_csv( "CORE-2019-NONPROFIT-SCOPE-501CE-PZ.csv" )




get_flevels <- function( vname, dgf ) {

  # vname <- "LEVEL3"

  x <- dgf$dgf_f_levels[ dgf$dgf_vname == vname ]
  f <- jsonlite::fromJSON( x )

  y <- dgf$dgf_f_order[ dgf$dgf_vname == vname ]
  y <- parse_semicolons( y )

  same.levels <- setequal( f$f_level, y )
  if( ! same.levels )
  { 
    # warning 
    return(f)
  }

  # reorder factor levels
  # eg MON TUE WED
  f <- f[ match( y, f$f_level ), ]
  
  return(f) 
}

get_flevels( vname="LEVEL3", dgf=wb )



parse_semicolons <- function(x) {

  x <- 
    x %>% 
    strsplit( ";;" ) %>% 
    unlist() %>%
    trimws()

  if( last(x) == "" )
  { x <- x[ - length(x) ] }

  return(x)
}

create_dgf( df )

format_ein <- function( x, to="id" ) {
  
  if( to == "id" )
  {
    x <- stringr::str_pad( x, 9, side="left", pad="0" )
    sub1 <- substr( x, 1, 3 )
    sub2 <- substr( x, 4, 6 )
    sub3 <- substr( x, 7, 9 )
    ein  <- paste0( "EIN-", sub1, "-", sub2, "-", sub3 ) 
    return(ein)
  }
  
  if( to == "n" )
  {
    x <- gsub( "[^0-9]", "", x )
    return( x )
  }
  
}

