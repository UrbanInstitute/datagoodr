# SIMPLIFY WITH DATA.TABLE PACKAGE



#

#' Split a delimited alias string into unique names
#'
#' Splits a `";;"`-delimited string of variable-name aliases into a trimmed
#' vector of unique names.
#'
#' @param x A single character string containing one or more names separated
#'   by `";;"`.
#'
#' @return A character vector of unique, whitespace-trimmed names.
#' @rdname parse_nm
#' @export
parse_nm <- function(x) {

  x <-
    x |>
    strsplit( ";;" ) |>
    unlist() |>
    trimws() |>
    unique()

  return(x)
}




#' Replace variable names matching an alias
#'
#' Given a vector of current names, replaces any that match one of the aliases
#' in `x` with the single replacement name `y`. A message reports what was
#' replaced, and a warning is issued if more than one name matches.
#'
#' @param nm A character vector of current variable names.
#' @param x A `";;"`-delimited string (or vector) of aliases to match against
#'   `nm`.
#' @param y The single replacement name to substitute for matched aliases.
#'
#' @return The `nm` vector with matched names replaced by `y`.
#' @seealso [rename_all()], [parse_nm()]
#' @rdname replace_name
#' @export
replace_name <- function( nm, x, y ) {

  aliases <- parse_nm( x )
  replace.it <- nm %in% x

  this.one <- nm[ replace.it ]

  message <-
    paste0(
      "more than one variable",
      " name matches an alias" )

  if( length(this.one) > 1 )
  {
    warning( message )
  }

  this.one <- paste0( this.one, collapse=" ;; " )

  cat(
   paste0(
     "\nReplacing:    << ",
      this.one,
      " >>    \nWith:         << ",
      y, " >>\n\n" ) )

  nm[ replace.it ] <- y

  return(nm)

}

#






# old is a variable name or a
# multiple names in a single string
# separated by ;;
#
# new is the replacement variable name

#' Rename data frame columns using an alias mapping
#'
#' Renames the columns of `df` by applying [replace_name()] for each
#' `old`/`new` pair, where each `old` entry may be a `";;"`-delimited set of
#' aliases mapping to a single `new` name.
#'
#' @param df A data frame whose columns should be renamed.
#' @param old A character vector of aliases (each element optionally
#'   `";;"`-delimited) identifying columns to rename.
#' @param new A character vector of replacement names, parallel to `old`.
#'
#' @return The data frame with renamed columns.
#' @seealso [replace_name()]
#' @rdname rename_all
#' @export
rename_all <- function( df, old, new ) {

  nm <- names( df )

  for( i in 1:length(old) )
  {
    nm <-
      replace_name(
        nm,
        old[i],
        new[i] )
  }

  names(df) <- nm
  return(df)
}








