
#' Check if elements are missing or empty (internal)
#'
#' Returns a logical vector indicating which elements are `NA` or empty strings.
#'
#' @param x A vector to check.
#'
#' @return A logical vector where `TRUE` indicates an element is `NA` or `""`.
#'
#' @keywords internal
#' @noRd
is_empty <- function(x) {
  is.empty <- is.na(x) | x == ""
  return( is.empty )
}

#
# x <- "rule1 ;; rule2(x)"
# x <-
#   x %>%
#   strsplit( ";;" ) %>%
#   unlist() %>%
#   trimws()

# x <- gsub( "\\(x\\)", "", x )
# x <- gsub( "\\(\\)", "", x )
# x

#' Clean and normalize function names (internal)
#'
#' Removes trailing parentheses from function names and replaces empty entries
#' with `"norule"`.
#'
#' @param x A character vector of function names.
#'
#' @return A character vector with cleaned function names and empty entries
#'   replaced by `"norule"`.
#'
#' @keywords internal
#' @noRd
get_fx <- function( x ) {

   x <- gsub( "\\(x\\)", "", x )
   x <- gsub( "\\(\\)", "", x )
   x <- ifelse( is_empty(x), "norule", x )
   return(x)
}

# get_fx( dgf$dgf_raw_convert )

#' Assign conversion rules to variables (internal)
#'
#' Splits a character string of rules, cleans function names, and associates
#' them with a variable.
#'
#' @param x A character string containing one or more rules separated by `";;"`.
#' @param y The variable name to which the rules apply.
#'
#' @return A data frame with columns `var` (variable name) and `rule` (cleaned
#'   function names). Returns `NULL` if `x` is empty.
#'
#' @keywords internal
#' @noRd
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

# x <- "rule1 ;; rule2(x)"
# y <- "vname1"
#
# assign_rules( x, y )

#
# x <- dgf$dgf_raw_convert
# y <- dgf$dgf_vname
# rx <- purrr::map2_dfr(.x=x, .y=y, .f=assign_rules )

#' Apply a single conversion rule to a variable (internal)
#'
#' Applies a specified function to a column of a data frame.
#'
#' @param df A `data.frame` containing the variable to transform.
#' @param x A character string specifying the column name in `df`.
#' @param f A character string specifying the name of a function to apply.
#'
#' @return The `data.frame` with the specified function applied to the column `x`.
#'
#' @keywords internal
#' @noRd
apply_rule <- function( df, x, f ) {

  v <- df[[x]]
  v <- get( f )( v )
  df[[x]] <- v
  return( df )
}

# get( "as_mm"  )( "8" )
# dff <- df[ 1:100, ]
# apply_rule( dff, "EIN", "format_ein" )

#' Apply multiple conversion rules to a data frame (internal)
#'
#' Iterates over a set of variable-rule pairs and applies each rule to the
#' corresponding column in a data frame.
#'
#' @param df A `data.frame` containing the variables to transform.
#' @param rx A data frame with columns `var` (variable names) and `rule`
#'   (function names as strings) specifying the rules to apply.
#'
#' @return The `data.frame` with all specified rules applied.
#'
#' @keywords internal
#' @noRd
apply_all_rules <- function( df, rx ) {

  for( i in 1:nrow(rx) )
  {
    print( rx[i] )
    df <- apply_rule( df, rx$var[i], rx$rule[i] )
  }

  return( df )
}



# df <- apply_all_rules( df, rx )







#' Apply a function to a variable based on DGF rules (internal)
#'
#' Intended to retrieve a rule from the data guide file (DGF) and apply a
#' conversion function to a specified variable. Currently partially implemented.
#'
#' @param df A `data.frame` containing the variable to transform.
#' @param vname A character string specifying the column name in `df`.
#' @param fx A character string specifying the name of the function to apply.
#'
#' @return Currently `NULL` if the rule is empty; otherwise not fully implemented.
#'
#' @keywords internal
#' @noRd
apply_fx <- function( df, vname, fx ) {

  rule <- dgf[[ type ]]

  if( is_empty(rule) )
  { return(NULL) }

  vname <- dgf[[ "dgf_vname" ]]
}
