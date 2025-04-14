


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
#' @seealso 
#'  \code{\link[stringr]{str_pad}}
#' @rdname as_mm
#' @export 
#' @importFrom stringr str_pad
as_mm <- function(x) {
  x <- 
    x %>% 
    stringr::str_pad( 2, side="left", pad="0" )
  return(x)
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
#' @rdname as_yyyy
#' @export 
as_yyyy <- function(x) {
  x <- as.character(x)
  if( max(nchar(x)) > 4 )
  { warning( "YYYY elements have nchar > 4" ) }
  return(x)
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
#' @rdname as_yyyymm
#' @export 
as_yyyymm <- function(x) {
  x <- as.character(x) 
  yyyy <- substr( x, 1, 4 )
  mm <- substr( x, 5, 6 )
  yyyymm <- paste0( yyyy, "-", mm )
  return(yyyymm)
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
#' @rdname as.numeric
#' @export 
as.numeric <- function(x) {
  x %>% 
  as.character() %>%
  as.numeric()
}
