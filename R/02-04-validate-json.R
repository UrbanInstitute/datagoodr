#' Check whether each element of a vector is valid JSON
#'
#' Vectorised wrapper around [jsonlite::validate()] used to verify that the
#' JSON-encoded cells of a DGF are well formed.
#'
#' @param v A character vector of JSON strings.
#'
#' @return A logical vector, one element per input, `TRUE` where the string is
#'   valid JSON.
#' @seealso [get_json_error()], [show_invalid()], \code{\link[jsonlite]{validate}}
#' @rdname validate_json
#' @export
#' @importFrom jsonlite validate
validate_json <- function(v)
{
  is.valid <- sapply( v, jsonlite::validate, USE.NAMES=F )
  return( is.valid )
}





#' Return the parse error for an invalid JSON string
#'
#' Validates a single JSON string and returns the error message produced by
#' [jsonlite::validate()], or `NULL` when the string is valid.
#'
#' @param x A single JSON string.
#'
#' @return A character string describing the JSON parse error, or `NULL` if
#'   `x` is valid JSON.
#' @seealso [validate_json()], \code{\link[jsonlite]{validate}}
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







#' Print the invalid JSON cells in a vector
#'
#' Identifies the elements of `v` that are not valid JSON and prints, for each,
#' its parse error message followed by the offending string. Useful for
#' debugging a DGF after manual edits.
#'
#' @param v A character vector of JSON strings.
#'
#' @return Invisibly returns `NULL`; called for its printed side effects.
#' @seealso [validate_json()], [get_json_error()]
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
