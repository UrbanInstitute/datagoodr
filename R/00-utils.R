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


#' Load DGF from DGF Excel Sheet
#'
#' This function reads DGF from an Excel file and returns the contents of the "DGF" sheet as a data frame.
#'
#' @param filename A character string specifying the name of the Excel file to read. Defaults to `"DGF.xlsx"`.
#'
#' @return A data frame containing the data from the "DGF" sheet of the specified Excel file.
#'
#' @import openxlsx
#' @keywords internal
#' @noRd
load_dgf <- function( filename="DGF.xlsx" ) {
  dgf <- openxlsx::read.xlsx( xlsxFile=filename, sheet="DGF" )
  return(dgf)
}





#' Create a summary of variable types and examples (internal)
#'
#' Generates a data frame summarizing the class and a sample value for each
#' column in a data frame.
#'
#' @param df A `data.frame` to summarize.
#'
#' @return A data frame with columns:
#'   - `VAR`: variable names,
#'   - `TYPE`: the class of each variable,
#'   - `EXAMPLE`: the first non-missing value from each variable.
#'
#' @keywords internal
#' @noRd
get_class_df <- function(df)
{
  v <- sapply( df, class )
  f <- sapply( df, function(x){(na.omit(as.character(x)))[1]} )
  d <- data.frame( VAR=names(v), TYPE=v, EXAMPLE=f  )
  row.names(d) <- NULL
  return(d)
}




#' Format Numeric Values as Dollar Amounts
#'
#' This function formats numeric values as dollar amounts by rounding them to the nearest whole number,
#' adding commas as thousand separators, and prefixing them with a dollar sign.
#'
#' @param x A numeric vector to be formatted.
#'
#' @return A character vector with the formatted dollar amounts.
#'
#' @examples
#' dollarize(1234567.89) # Returns "$1,234,568"
#' dollarize(c(1000, 2500.75, 999999.99)) # Returns c("$1,000", "$2,501", "$1,000,000")
#'
#' @keywords internal
#' @noRd
dollarize <- function(x)
{
  x <- round(x,0)
  x <- format( x, big.mark="," )
  x <- paste0( "$", trimws(x) )
  return(x)
}




#' Extract and Format the First N Unique Values from a Vector
#'
#' This function extracts the first N unique, non-missing values from a vector, formats them appropriately,
#' and returns them as a truncated character string.
#'
#' @param x A vector of any type (numeric, character, factor, or Date).
#' @param n An integer specifying the number of unique values to return. Defaults to 5.
#'
#' @return A formatted character string containing up to the first N unique values from `x`,
#' separated by " ;; \n". If `x` is numeric, values are rounded to three decimal places.
#' If `x` contains factors or dates, they are converted to character strings.
#'
#' @examples
#' first_n(c("apple", "banana", "cherry", "date", "elderberry", "fig"), 3)
#' first_n(c(1.234567, 2.345678, 3.456789), 2)
#' first_n(as.Date(c("2021-01-01", "2021-02-01", "2021-03-01")), 2)
#'
#' @seealso
#'  \code{\link[stringr]{str_trunc}}
#' @rdname first_n
#' @keywords internal
#' @noRd
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




#' Convert a factor to a formatted JSON string (internal)
#'
#' Converts a factor variable into a JSON-formatted string showing factor levels
#' and labels. Removes quotes and truncates to the first 50 levels if necessary.
#'
#' @param f A factor or a vector that can be coerced to a factor.
#'
#' @return A JSON-formatted character string representing the factor levels and
#'   labels.
#'
#' @keywords internal
#' @noRd
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





#' Get factor levels as a formatted string (internal)
#'
#' Converts a factor to a character string of its levels separated by
#' `";; \n"`. Truncates to the first 50 levels if the factor has more than 50.
#'
#' @param f A factor or a vector that can be coerced to a factor.
#'
#' @return A single character string listing the factor levels.
#'
#' @keywords internal
#' @noRd
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






#' Identify and Print Duplicate Variables in a Data Frame
#'
#' This function checks for duplicate variables in a data frame based on a provided hash vector.
#' It prints out the names of duplicate variables and returns a logical vector indicating which
#' rows are duplicates.
#'
#' @param df A data frame containing the variables to be checked for duplicates.
#' @param vhash A vector of hash values corresponding to each variable in the data frame.
#'        This is typically computed using a hashing function like `rlang::hash()`.
#'
#' @return A logical vector indicating which variables are duplicates.
#'
#' @examples
#' \dontrun{
#' vhash <- sapply(df, rlang::hash)  # Generate hash values for variables
#' get_dupes(df, vhash)  # Identify and print duplicate variables
#' }
#'
#' @keywords internal
#' @noRd
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
