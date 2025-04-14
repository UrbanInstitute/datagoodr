#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param x PARAM_DESCRIPTION
#' @param almost PARAM_DESCRIPTION, Default: T
#' @param threshold PARAM_DESCRIPTION, Default: 0.99
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname is_date
#' @export 
is_date <- function( x, almost=T, threshold=0.99 )
{
  format1 <- "[[:digit:]]{2}/[[:digit:]]{2}/[[:digit:]]{2}" # dd/mm/yy OR mm/dd/yy
  format2 <- "[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{2}" # dd-mm-yy OR mm-dd-yy
  format3 <- "[[:digit:]]{2}/[[:digit:]]{2}/[[:digit:]]{4}" # dd/mm/yyyy OR mm/dd/yyyy
  format4 <- "[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{4}" # dd-mm-yyyy OR mm-dd-yyyy
  
  type1 <- grepl( format1, x )
  type2 <- grepl( format2, x )
  type3 <- grepl( format3, x )
  type4 <- grepl( format4, x )
  
  dtfmt <- get_date_format_z( x )
  
  type5 <- ! is.null(dtfmt)
  
  if( almost )
  { is.date <- 
      almost_true( type1, threshold ) | 
      almost_true( type2, threshold ) | 
      almost_true( type3, threshold ) | 
      almost_true( type4, threshold ) |
      type5
  }
  
  if( ! almost )
  { is.date <- 
      all( type1, na.rm=T ) | 
      all( type2, na.rm=T ) | 
      all( type3, na.rm=T ) | 
      all( type4, na.rm=T ) |
      type5
  }
  
  return( is.date )
}




#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param x PARAM_DESCRIPTION
#' @param threshold PARAM_DESCRIPTION, Default: 0.99
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname almost_true
#' @export 
almost_true <- function( x, threshold=0.99 )
{
  n <- length(x)
  p <- sum(x,na.rm=T)/n
  almost <- p >= threshold
  return(almost)
}





  
#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param x PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname get_date_format_x
#' @export 
get_date_format_x <- function(x)
{
  x <- gsub( "[[:alpha:]]", "X", x )
  x <- gsub( "[[:digit:]]", "N", x )
  x <- trimws(x)
  return( paste( unique(x), collapse=" ;; " ) )
}





#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param x PARAM_DESCRIPTION
#' @param orders PARAM_DESCRIPTION, Default: c("mdy", "dmy")
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[lubridate]{guess_formats}}
#' @rdname get_date_format_z
#' @export 
#' @importFrom lubridate guess_formats
get_date_format_z <- function( x, orders=c("mdy","dmy") )
{
  ## m also matches b and B; y also matches Y
  formats <- lubridate::guess_formats( x, orders )
  f <- formats[ grepl( "^[^O]+$", names(formats) ) ]
  all <- paste( unique(f), collapse=" ;; " )
  
  if( length(all) == 1 & all[1] == "" )
  { return(NULL) }
  
  # ADD:
  # 6/6/2000 returns dd-mm-yy and mm-dd-yy 
  # check to see which is more common in vector
  # to determine the correct month position
  
  return(all)
}






#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param x PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname cast_as_date
#' @export 
cast_as_date <- function(x)
{
  fmt <- get_date_format_z(x)
  if( length(fmt) != 1 )
  { 
    cat( "No format match\n" )
    cat( "See: get_date_format_z()\n" )
    return(x)
  }
  cat( paste0( "Using date format: ", fmt, "\n" ) )
  x <- as.Date( x, format=fmt )
  return(x)
}






#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname find_dates
#' @export 
find_dates <- function( df )
{
  dt <- lapply( df, is_date ) %>% unlist()
  names(dt) <- names(df)
  return(dt)
}





#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname recast_dates
#' @export 
recast_dates <- function( df )
{
  dt <- find_dates( df )
  v.class <- lapply( df, class ) %>% unlist()
  already.date <- v.class == "Date"
  dt <- dt & ! already.date 

  if( sum(dt) > 0 )
  { 
    invisible( capture.output( 
      df[ names(dt)[dt] ] <- 
       lapply( df[names(dt)[dt]], cast_as_date )
    ))
  }

  return(df)
}




#   invisible( capture.output( 
#      ff <- lapply( df, is_factor ) %>% unlist() ))
#   names(ff) <- names(df)
#   return(ff)


# check if data is lost in conversion:
# - get date format 
# - convert to Date
# - convert to original format
# compare v1 and v2
#
# check_date_conversion_loss <- function(x)
