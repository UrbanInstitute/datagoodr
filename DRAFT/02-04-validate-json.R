#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param v PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[jsonlite]{validate}}
#' @rdname validate_json
#' @export 
#' @importFrom jsonlite validate
validate_json <- function(v)
{
  is.valid <- sapply( v, jsonlite::validate, USE.NAMES=F )
  return( is.valid )
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
#' @seealso 
#'  \code{\link[jsonlite]{validate}}
#' @rdname get_json_error
#' @export 
#' @importFrom jsonlite validate
get_json_error <- function(x)
{
  r <- jsonlite::validate(x)
  error.message <- attr( r, "err" )
  return( error.message )
}
  

# vals <- dgf$dgf_values
# validate_json( vals )







#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param v PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname show_invalid
#' @export 
show_invalid <- function(v)
{
  not.valid <- ! validate_json(v)
  nv <- v[ not.valid ]
  show_problem <- function(x)
  { print(get_json_error(x)); cat(paste0(x,"\n\n")) }
  sapply( nv, show_problem, USE.NAMES=F )
  return(invisible(NULL))
}

# show_invalid( vals )
