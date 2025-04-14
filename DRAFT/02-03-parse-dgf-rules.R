

is_empty <- function(x) {
  is.empty <- is.na(x) | x == ""
  return( is.empty )
}


x <- "rule1 ;; rule2(x)"
x <- 
  x %>% 
  strsplit( ";;" ) %>% 
  unlist() %>%
  trimws()

x <- gsub( "\\(x\\)", "", x )
x <- gsub( "\\(\\)", "", x )
x


get_fx <- function( x ) {
  
   x <- gsub( "\\(x\\)", "", x )
   x <- gsub( "\\(\\)", "", x )
   x <- ifelse( is_empty(x), "norule", x )
   return(x)
}

get_fx( dgf$dgf_raw_convert )


assign_rules <- function( x, y ) {

  if( is_empty(x) )
  { return(NULL) }

  x <- 
    x %>% 
    strsplit( ";;" ) %>% 
    unlist() %>%
    trimws()

  x <- gsub( "\\(x\\)", "", x )
  x <- gsub( "\\(\\)", "", x )

  df <- data.frame( var=y, rule=x )

  return( df )
}

x <- "rule1 ;; rule2(x)"  
y <- "vname1"

assign_rules( x, y )


x <- dgf$dgf_raw_convert
y <- dgf$dgf_vname
rx <- purrr::map2_dfr(.x=x, .y=y, .f=assign_rules )


apply_rule <- function( df, x, f ) {
 
  v <- df[[x]] 
  v <- get( f )( v )
  df[[x]] <- v
  return( df )
}

# get( "as_mm"  )( "8" )
# dff <- df[ 1:100, ]
# apply_rule( dff, "EIN", "format_ein" )


apply_all_rules <- function( df, rx ) {

  for( i in 1:nrow(rx) )
  {
    print( rx[i] )
    df <- apply_rule( df, rx$var[i], rx$rule[i] )
  }

  return( df )
}



df <- apply_all_rules( df, rx )




 



apply_fx <- function( df, vname, fx ) {

  rule <- dgf[[ type ]]

  if( is_empty(rule) )
  { return(NULL) }

  vname <- dgf[[ "dgf_vname" ]]