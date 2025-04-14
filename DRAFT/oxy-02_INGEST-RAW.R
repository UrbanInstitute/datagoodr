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





# path = project path (save location)



#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @param path PARAM_DESCRIPTION, Default: NULL
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname ingest_raw
#' @export 
ingest_raw <- function( df, path=NULL ) {

  if( is.null(path) ){ path <- "." }
  try( source( paste0( path, "/", "dgf.R" ) ) )
  
  # dgf <- load excel 
  
  df <- apply_name_aliases( df, dgf )
  
  # df <- apply_raw_convert_fx( df, dgf )
  # df <- apply_stdz_rules( df, dgf )
 
  # check for changes with vhash:
  #   update skimr
  #   update factor levels
 
  # save new version 
}




#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @param dgf PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[crosswalkr]{renamefrom}}
#' @rdname apply_name_aliases
#' @export 
#' @importFrom crosswalkr renamefrom
apply_name_aliases <- function( df, dgf ) {

  cw <- 
    dgf %>%
    select( vname, vname_alias, vlabel ) 
   
  no.alias <- is.na( cw$vname_alias )
  cw$vname_alias[ no.alias ] <- cw$vname[ no.alias ]
  
  df <- 
    crosswalkr::renamefrom( 
      df, 
      cw_file=cw, 
      raw=vname_alias, 
      clean=vname, 
      label=vlabel )

  return( df )
  
}




#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param raw_convert PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname parse_functions
#' @export 
parse_functions <- function( raw_convert ){

  fx.list <- unique( raw_convert )
  f.exists <- vapply( fx.list, exists )
  if( any( f.exists ) )
  { 
    f.missing <- fx.list[ ! f.exists ]
    stop( 
      paste0( 
        "raw_convert functions are not defined: ",
        paste( f.exists, collapse="; " ) 
     ) )
  }
  
  return( fx.list )
}





#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @param dgf PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[dplyr]{mutate_all}}
#' @rdname apply_raw_convert_fx
#' @export 
#' @importFrom dplyr mutate_at
apply_raw_convert_fx <- function( df, dgf ) {

  fx.list <- parse_functions( dgf$raw_convert )
  
  for( i in fx.list )
  {
    cols <- df$vname[ df$raw_convert == i ]
    df <- 
      df %>%
      dplyr::mutate_at( cols, i )  
  }
  
  return( df )
}




