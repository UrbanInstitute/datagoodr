#############################
### Get_properties (for all data types)
##############################

#' Generate Table of Properties
#'
#' Generates needed properties for rg_properties column of the DGF. Used inside R/01-00-CREATE-DGF.R
#'
#' @param VNAME A character string specifying the name of the variable in the data frame. (From vname column of the DGF)
#' @param df A data frame containing the variable to be visualized.
#'
#' @return Data table as JSON text string needed to store in the DGF to later generate the properties table when rendering the RG.
#'
#' @details
#' properties include number of rows and distinct values, most common value,
#' number of zero, empty cells, missing/NA cells, and cell with infinite values
#'
#'
#' @export
get_properties <- function( VNAME, df ){

  # VNAME <- xx[VNAME]  # for testing VNAME <- all.vars[1]
  # stats <- get_stats(VNAME)
  #
  # x <- dat[[VNAME]] #this should be the input data set

  x <- unlist(df[[VNAME]])

  tab <- data.frame(
    STAT = c( "Rows",  "Distinct",  "Most Common Value",
              "Zero", "All Empty", "Missing/NA",
              "Infinite"),
    VAL =  c( length(x),
              length(unique(x)),
              most_common_val(x),
              sum( x == 0, na.rm=T ),
              sum( x == "", na.rm=T ),
              is_missing(x),
              sum( is.infinite(x) )))

  tab$PER <- c("",
               "",
               round(mean(x == tab$VAL[3], na.rm = T) * 100, 0), # of the values that are not missing, what percetnage of them are the most common value
               round(as.numeric(tab$VAL[4:7])/as.numeric(tab$VAL[1]) * 100,1))


  per.index <- nchar(tab$PER) > 0
  tab$PER[per.index] <- paste0("(", tab$PER[per.index], "%)")

  f <- function(x){ format(x,big.mark=",") }
  tab$VAL <- sapply( tab$VAL, f )
  ret <-jsonify_df(tab)
  return(ret)
  #return tab as json object

}


#' Check missing data
#'
#' internal function for get_properties to return amount of missing data
#'
#' @param x vector
#'
#' @return number of missing values in `x`
#'
#' @details
#' internal function for \link{get_properties}
#'
#' @keywords internal
is_missing <- function(x) {
  v1 <- is.na(x)
  v2 <- is.nan(x)
  v3 <- is.infinite(x)
  v4 <- grepl( "^[ ]{0,}$", x )
  v5 <- x == "NA"
  v6 <- x == "."
  missing <- v1 | v2 | v3 | v4 | v5 | v6
  return( sum( missing, na.rm=T ) )
}


#' Most common value
#'
#' Internal function for \link{get_properties} to find most common value.
#'
#' @param x vector
#'
#' @return most common value in `x`
#'
#' @details
#' internal function for \link{get_properties}
#'
#' @keywords internal
most_common_val <- function(x) {
  # use data table for speed:
  x <- c(x)
  tibble(x = x) %>%
    dplyr::count(x) %>%
    dplyr::filter(n==max(n)) %>%
    dplyr::slice(1) %>%
    dplyr::pull(x) %>%
    as.character %>%
    return()

  # counts <- data.table::as.data.table(x)[, .N, by=x]
  # most.counts <- counts[counts$N == max(counts$N), x]
  # if(is.null(most.counts) | length(most.counts) == 0){return(NA)}
  # return( as.character(most.counts[1]))
}





##############################
### Functions called to paste rg_stats into DGF
###############################

#' Generate Statistics Based on Variable Type
#'
#' Generates needed graphics for rg_stats column of the DGF. Used inside R/01-00-CREATE-DGF.R
#'
#' @param VNAME A character string specifying the name of the variable in the data frame. (From vname column of the DGF)
#' @param df A data frame containing the variable to be visualized.
#' @param VCLASS A character string indicating the class of the variable (e.g., "numeric", "factor", "logical", or other).
#'
#' @return Data table as JSON text string needed to store in the DGF to later generate the appropriate plot when rendering the RG.
#'
#' @details
#' The function calls different helper functions based on `VCLASS`:
#' \itemize{
#'   \item `"numeric"`: Calls `get_graphics_num(VNAME, df)`
#'   \item `"factor"`: Calls `get_graphics_fact(VNAME, df)`
#'   \item `"logical"`: Calls `get_graphics_log(VNAME, df)`
#'   \item Other classes: Calls `get_graphics_chr(VNAME, df)`
#' }
#' @export
get_stats <- function(VNAME, df, VCLASS){

  if(VCLASS == "numeric"){
    return(get_stats_num(VNAME,df))
  }else if(VCLASS == "factor"){
    return(get_stats_fact(VNAME,df))
  }else if(VCLASS == "logical"){
    return(get_stats_log(VNAME,df))
  }else(
    return(get_stats_chr(VNAME,df))
  )
}



### Character ---------------------------

# table of "Minimum", "Median",  "Mean", "Max", "Skew" for number of words in
# each string and number of characters in each string
get_stats_chr <-  function(VNAME, df){

  # VNAME <- xx[VNAME]
  # # for testing VNAME <- all.vars[1]
  #
  # x <- dat[[VNAME]] #this should be the input data set

  x <- unlist(df[[VNAME]])

  #number of characters
  n <- nchar(x)
  n <- n[!is.na(n)] #remove NA

  #number of spaces
  spaces <- stringr::str_count(x, "[:blank:]") + 1
  spaces <- spaces[!is.na(spaces)] #remove NA

  tab <-
    data.frame(STAT =  c( "Minimum", "Median",  "Mean", "Max", "Skew"),
               CHARACTERS = round(c(min(n, na.rm = TRUE),
                                    median(n, na.rm = TRUE),
                                    mean(n, na.rm = TRUE),
                                    max(n, na.rm = TRUE),
                                    psych::skew(n)), 2),
               WORDS = round(c(min(spaces, na.rm = TRUE),
                               median(spaces, na.rm = TRUE),
                               mean(spaces, na.rm = TRUE),
                               max(spaces, na.rm = TRUE),
                               psych::skew(spaces)), 2))

  ## Testing histogram in table - isn't saving as JSON object properly - can add back in later
  # tab <- rbind(tab, c("Histogram", "", ""))
  # tab$CHARACTERS[6] <-  htmltools::HTML(kableExtra::spec_hist(n)$svg_text)
  # tab$WORDS[6] <-  htmltools::HTML(kableExtra::spec_hist(spaces)$svg_text)
  #
  data_list <- list(
    STATS = tab,
    HIST = list(htmltools::HTML(kableExtra::spec_hist(n)$svg_text), htmltools::HTML(kableExtra::spec_hist(spaces)$svg_text))
  )

  #return tab as json object
  ret <- jsonlite::toJSON(data_list, pretty = TRUE, auto_unbox = TRUE)

  return(ret)


}


### Logical ------------------------

#returns table with the frequencies of the two values (and any NA's)
# could be combined with get_graphics_log to be more efficient
get_stats_log <-  function(VNAME, df){

  # VNAME <- xx[VNAME]
  # # for testing VNAME <- all.vars[1]
  #
  # f <- dat[[VNAME]] #this should be the input data set

  f <- as.character(df[[VNAME]])

  f[ is.na(f) ] <- "NA"
  tab <- as.data.frame(table( f ))
  colnames(tab) <- c("Value", "Frequency")


  ret <- jsonify_df(tab)
  return(ret)




}



### Factor ------------------------

# table of 5 most common values and their associated counts
get_stats_fact <-  function(VNAME, df){

  # VNAME <- xx[VNAME]
  # # for testing VNAME <- all.vars[1]
  #
  # x <- dat[[VNAME]] #this should be the input data set

  x <- df[[VNAME]]

  tab <- sort(table(x))
  #grab top 5 values (or all of them if less than 5)
  if(length(tab) <=5){
    index <- length(tab):1
  }else{
    index <- length(tab):(length(tab)-5)
  }
  tab <- tab[ index ]
  tab <- data.frame(tab)
  colnames(tab) <- c("Value", "Frequency")


  #return tab as json object
  ret <- jsonify_df(tab)
  return(ret)

}


### Numeric ----------------------------
# outputs table with min, q05, q25, q50, mean, q75, q95, max, and skewness

get_stats_num <- function( VNAME, df ){

  # VNAME <- xx[VNAME]
  # # for testing VNAME <- all.vars[1]
  #
  # x <- dat[[VNAME]] #this should be the input data set

  x <- df[[VNAME]]

  tab <- data.frame(
    STAT = c("Minimum", "Q - 05", "Q - 25", "Median", "Mean",
             "Q - 75", "Q - 95", "Maximum", "Skew"),
    VAL = c(min(x, na.rm = TRUE),
            quantile( x, probs=0.05, na.rm=T, names=F ),
            quantile( x, probs=0.25, na.rm=T, names=F ),
            quantile( x, probs=0.50, na.rm=T, names=F ),
            mean(x, na.rm = T),
            quantile( x, probs=0.75, na.rm=T, names=F ),
            quantile( x, probs=0.95, na.rm=T, names=F ),
            max(x, na.rm = TRUE),
            psych::skew(x))
  )

  tab$VAL <- round(tab$VAL , 2)
  f <- function(x){ format(x,big.mark=",") }
  tab$VAL <- sapply( tab$VAL, f )

  ret <- jsonify_df(tab)
  return(ret)

  # return( df )
}



############################
### Required Internal Functions
#############################


jsonify_stats <- function( df ) {
  jd <- jsonlite::toJSON( df )
  jd <- gsub( ",", ", \n    ", jd )
  jd <- gsub( "\\{", "  \\{ \n    ", jd )
  jd <- gsub( ":", "  :  ", jd )
  jd <- gsub( '","', '",  "', jd )
  jd <- gsub( "\\}", "\n  \\}", jd )
  jd <- gsub( "\\[", "\\[ \n", jd )
  jd <- gsub( "\\]", "\n\\]", jd )
  return(jd)
}

jsonify_df <- function( df )
{
  jd <- jsonlite::toJSON( df )
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





##################################
### Get_example functions
###################################
#not needed for logical or factor

get_examples <- function(VNAME, df){

  # VNAME <- xx[VNAME]
  # # for testing VNAME <- all.vars[1]

  x <- df[[VNAME]] #this should be the input data set

  if( max(nchar(as.character(x)),na.rm=T) > 48 )
  { x <- purrr::map_chr( x, function(x){ substr(x,1,48) } ) }

  t <- table( x ) |> sort( d=T )
  txt <- paste0( names(t[1:min(length(t), 2000)]), collapse=" ;; " )
  BLOCK <- substr( txt,   1, 400 ) |> trimws()
  BLOCK <- gsub( " ?;{1,2} ?$", "", BLOCK )
  return( BLOCK )

}



