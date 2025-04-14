get_flevels <- function( VNAME, LABEL=NULL, dgf=NULL ) {

  # vname <- "LEVEL3"

  if( ! is.null(dgf) )
  { xx <- L[[ VNAME ]] }

  x <- xx[[ "dd_f_levels" ]]

  f <- jsonlite::fromJSON( x )

  y <- xx[[ "dd_f_order" ]]
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


f_to_tbl <- function( VNAME, LABEL="FACTOR LEVELS" ) {
  ftble <- get_flevels( VNAME )
  k <- knitr::kable( ftble )
  k <- c( paste0("**", LABEL, "**:"), "\n", k )
  return(k)
}

# get_flevels( VNAME="NTMAJ12", dgf=dgf )



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

# create_dgf( df )

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


