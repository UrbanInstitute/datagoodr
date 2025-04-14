# SIMPLIFY WITH DATA.TABLE PACKAGE

# nm1 <- c("X1", "X2", "X3")
# nm2 <- c("Y1", "Y2", "Y3")
# d <- data.table::setnames( d, old=nm1, new=nm2, skip_absent = TRUE )


#
# write.csv( d2, "DEMO-DATA-FULL.csv", row.names=F, na="" )
# write.csv( d3, "DEMO-DATA-SMALL.csv", row.names=F, na="" )

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

# parse_nm( x= "name1 ;; name2 " )



#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param nm PARAM_DESCRIPTION
#' @param x PARAM_DESCRIPTION
#' @param y PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
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

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @param old PARAM_DESCRIPTION
#' @param new PARAM_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
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








