# library( dplyr )
# 
# x <- c("A","B","C")
# y <- c("X","Y","Z")
# label <- c("label A", "label B", "label C" )
# cw <- data.frame( clean=x, old=y, label=label )
# 
# d <- data.frame( X=1:5, Y=1:5, Z=1:5 )
# 
# lookup <- paste0( x, " = ", y )
# rename( d, any_of(lookup) )
# 
# lookup <- c(pl = "Petal.Length", sl = "Sepal.Length")
# rename(iris, any_of(lookup))
# 
# 
# df <- 
#   crosswalkr::renamefrom( 
#     d, 
#     cw_file=cw, 
#     raw=old, 
#     clean=clean )







ingest_raw <- function( df, path=NULL ) {

  if( is.null(path) ){ path <- "." }
  try( source( paste0( path, "/", "dgf.R" ) )
  
  # dgf <- load excel 
  
  df <- apply_name_aliases( df, dgf )
  
  # apply_convert_fx( df, dgf )
  # standardize
 
  # update skimr
  # update factor levels
 
  # save new version 
}


apply_name_aliases <- function( df, dgf ) {

  cw <- 
    dgf %>%
    select( dgf_vname, dgf_vname_alias, dgf_vlabel ) 
   
  no.alias <- is.na( cw$dgf_vname_alias )
  cw$dgf_vname_alias[ no.alias ] <- cw$dgf_vname[ no.alias ]
  
  df <- 
    crosswalkr::renamefrom( 
      df, 
      cw_file=cw, 
      raw=dgf_vname_alias, 
      clean=dgf_vname, 
      label=dgf_vlabel )

  return( df )
  
}



parse_functions <- function( dgf_raw_convert ){

  fx.list <- unique( dgf_raw_convert )
  f.exists <- vapply( fx.list, exists )
  if( any( f.exists ) )
  { 
    f.missing <- fx.list[ ! f.exists ]
    stop( 
      paste0( 
        "dgf_raw_convert functions are not defined: ",
        paste( f.exists, collapse="; " ) 
     ) )
  }
  
  return( fx.list )
}




apply_convert_fx <- function( df, dgf ) {

  fx.list <- parse_functions( dgf$dgf_raw_convert )
  
  for( i in fx.list )
  {
    cols <- df$dgf_vname[ df$dgf_raw_convert == i ]
    df <- 
      df %>%
      dplyr::mutate_at( cols, i )  
  }
  
  return( df )
}




