# SIMPLIFY WITH DATA.TABLE PACKAGE

# nm1 <- c("X1", "X2", "X3")
# nm2 <- c("Y1", "Y2", "Y3")
# d <- data.table::setnames( d, old=nm1, new=nm2, skip_absent = TRUE )


#
# write.csv( d2, "DEMO-DATA-FULL.csv", row.names=F, na="" )
# write.csv( d3, "DEMO-DATA-SMALL.csv", row.names=F, na="" )

#' Parse and clean a delimited string into unique elements (internal)
#'
#' Splits a string by `";;"`, trims whitespace, and returns unique elements.
#'
#' @param x A character string containing elements separated by `";;"`.
#'
#' @return A character vector of unique, trimmed elements.
#'
#' @keywords internal
#' @noRd
parse_nm <- function(x) {

  x <-
    x |>
    strsplit( ";;" ) |>
    unlist() |>
    trimws() |>
    unique()

  return(x)
}

# parse_nm( x= "name1 ;; name2 " )



#' Replace variable names based on aliases (internal)
#'
#' Replaces elements in a character vector that match any alias with a
#' standardized name, and prints messages about the replacement.
#'
#' @param nm A character vector of variable names to update.
#' @param x A character string or vector of aliases to match.
#' @param y The new name to replace matching elements with.
#'
#' @return The updated character vector with matched names replaced by `y`.
#'
#' @keywords internal
#' @noRd
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
    warning( messaage )
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

# nm <- c( "var1", "var2", "var3" )  # df names
# x  <- c( "var4,", "var5", "var2" ) # aliases
# y  <- c( "VARx" )                  # replacement name
#
# replace_name( nm, x, y )






# old is a variable name or a
# multiple names in a single string
# separated by ;;
#
# new is the replacement variable name

#' Rename multiple columns in a data frame based on alias mappings (internal)
#'
#' Iterates over old and new name pairs and replaces matching column names in
#' a data frame using `replace_name()`.
#'
#' @param df A `data.frame` whose columns will be renamed.
#' @param old A character vector of old column names or aliases.
#' @param new A character vector of new names corresponding to `old`.
#'
#' @return The data frame with renamed columns.
#'
#' @keywords internal
#' @noRd
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








