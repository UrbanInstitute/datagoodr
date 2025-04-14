#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL




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
#' @rdname get_class_df
#' @export 
get_class_df <- function(df)
{
  v <- sapply( df, class ) 
  f <- sapply( df, function(x){(na.omit(as.character(x)))[1]} )
  d <- data.frame( VAR=names(v), TYPE=v, EXAMPLE=f  )
  row.names(d) <- NULL
  return(d)
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
#' @rdname dollarize
#' @export 
dollarize <- function(x)
{
  x <- round(x,0)
  x <- format( x, big.mark="," )
  x <- paste0( "$", trimws(x) )
  return(x)
}




#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param x PARAM_DESCRIPTION
#' @param n PARAM_DESCRIPTION, Default: 5
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[stringr]{str_trunc}}
#' @rdname first_n
#' @export 
#' @importFrom stringr str_trunc
first_n <- function( x, n=5 )
{
  if( any( class(x) %in% c("factor","Date") ) )
  { x <- as.character(x) }
  x <- na.omit( unique(x) )
  if( length(x) < n ){ n <- length(x) }
  if( n == 0 ){ return("") }
  x <- x[1:n]
  if( "numeric" %in% class(x) ){ x <- round(x,3) }
  x <- stringr::str_trunc( x, 20 )
  x <- paste( x, collapse=" ;; \n" )
  return(x)
}




#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param f PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[jsonlite]{toJSON, fromJSON}}
#' @rdname jsonify_f
#' @export 
#' @importFrom jsonlite toJSON
jsonify_f <- function(f)
{
  f <- as.factor(f)
  f_level <- levels(f)
  f_level <- gsub( "'", "", f_level ) # remove quotes
  f_level <- gsub( '"', '', f_level ) # remove apostrophes
  label <- f_level
  d <- data.frame(f_level,label)
  if( nrow(d) > 50 ){ 
      d <- d[ 1:50, ]
      cat( "Factor truncated to first 50 levels.\n\n" ) }
  jd <- jsonlite::toJSON( d )
  jd <- gsub( "\\{", "  \\{  ", jd )
  jd <- gsub( ":", " :  ", jd )
  jd <- gsub( '",', '"  ,  ', jd )
  jd <- gsub( '","', '",  "', jd )
  jd <- gsub( "\\},", "  \\}, \n", jd )
  jd <- gsub( "\\[", "\\[ \n", jd )
  jd <- gsub( "\\]", "\n\\]", jd )
  jd <- gsub( "\\}\n", "  \\}\n", jd )
  return(jd)
}





#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param f PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname get_levels
#' @export 
get_levels <- function(f)
{
  f <- factor(f)
  flevels <- levels(f)
  if( nlevels(f) > 50 )
  { 
    warning("More than 50 factor levels, using first 50.", call. = TRUE ) 
    flevels <- flevels[1:50] 
  }
  x <- paste0( paste( flevels, collapse=" ;; \n" ), " ;; \n" )
  return(x)
}






# identify  duplicated variables
# (variables with identical values)

get_dupes <- function( df, vhash ) {

  hh <- vhash  # sapply( df, rlang::hash )
  dupes <- duplicated( hh ) | duplicated( hh, fromLast=T ) 
  hh.dupes <- sort(hh[dupes])
  
  cat( "\nThe following variables" )
  cat( "\nare duplicates:\n\n" )
  for( i in unique(hh.dupes) )
  {
    nmz <- (names( hh.dupes ))[ hh.dupes == i ]
    cat( paste0( nmz, collapse=" ;; " ) )
    cat( "\n" ) 
  }

  return(dupes)

}