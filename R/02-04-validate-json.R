#
# validate_json <- function(v)
# {
#   is.valid <- sapply( v, jsonlite::validate, USE.NAMES=F )
#   return( is.valid )
# }





# get_json_error <- function(x)
# {
#   r <- jsonlite::validate(x)
#   error.message <- attr( r, "err" )
#   return( error.message )
# }
#

# vals <- dgf$dgf_values
# validate_json( vals )


#
#
# show_invalid <- function(v)
# {
#   not.valid <- ! validate_json(v)
#   nv <- v[ not.valid ]
#   show_problem <- function(x)
#   { print(get_json_error(x)); cat(paste0(x,"\n\n")) }
#   sapply( nv, show_problem, USE.NAMES=F )
#   return(invisible(NULL))
# }

# show_invalid( vals )
