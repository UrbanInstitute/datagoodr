### Internal Functions
json_to_list <- function(json_text) {
  lst <- jsonlite::fromJSON(json_text, simplifyVector = FALSE)
  return(lst)
}

json_to_df <- function(json_text) {
  df <- jsonlite::fromJSON(json_text)
  return(as.data.frame(df))
}



###  CONVERT CELL VALUE TO DD MARKDOWN TEXT --------
v_to_txt <- function( VNAME, LABEL )
{
  value  <- xx[[VNAME]]
  txt <- paste0( "**", LABEL, "**", ": ",  value, "\n\n" )
  cat( txt )
}

###########################################
### Paste properties
###########################################


#' Print Properties of a Variable into RG
#'
#' Read rg_properties column of DGF and print properties in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"PROPERTIES"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_properties <- function(VNAME, LABEL = "PROPERTIES"){

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  tab <- json_to_df(info)

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( tab, align=c("l","r", "r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )
}


###########################################
#### Paste Stats
###########################################

### Numeric ---------
#' Print Statistic of a Numeric Variable into RG
#'
#' Read rg_stats column of DGF and print statistics in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"STATS"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_stats_num <- function( VNAME, LABEL = "STATS" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  tab <- json_to_df(info)

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( tab, align=c("l","r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )

  # return( df )
}

### Character --------
#' Print Statistic of a Character Variable into RG
#'
#' Read rg_stats column of DGF and print statistics in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"STATS"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_stats_chr <- function( VNAME, LABEL = "STATS" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  info.list <- json_to_list(info)
  info.tab <- as.data.frame(do.call(rbind, info.list[[1]]))
  info.hist <- as.data.frame(do.call(rbind, info.list[[2]]))

  # histogram in the table isn't currently working.
  # This is just an extra thing that would be cool if it did work but isn't technically necessary.
  # info.tab[6, ] <- c("Histogram", info.hist$V1[1], info.hist$V1[2])

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( info.tab, align=c("l","r", "r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )

  # return( df )
}



### Factor --------
#' Print Statistic of a Factor Variable into RG
#'
#' Read rg_stats column of DGF and print statistics in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"STATS"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_stats_fact <- function( VNAME, LABEL = "STATS" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  tab <- json_to_df(info)

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( tab, align=c("l","r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )

  # return( df )
}

#' Print Statistic of a Logical Variable into RG
#'
#' Read rg_stats column of DGF and print statistics in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"STATS"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_stats_log <- function( VNAME, LABEL = "STATS" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  tab <- json_to_df(info)

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( tab, align=c("l","r"))
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )

  # return( df )
}



###########################################
### Paste Preview
###########################################


### Numeric --------------------------
#' Print Preview of a Numeric Variable into RG
#'
#' Read rg_preview column of DGF and print preview in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"PREVIEW"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_preview_num  <- function( VNAME, LABEL = "STATS" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  info.txt <- trim_txt_block( info )
  info.txt <- unlist(stringr::str_split(info.txt, " ;; "))

  n <- length(info.txt)
  if(n > 20){
    info.txt <- info.txt[sample(1:n, 20)]
    n <-20
  }else{
    #remove the last entry if length is odd
    is.even <- length(info.txt) %% 2 == 0
    if(!is.even){info.txt <- info.txt[1:(length(info.txt)-1)]}
  }
  #make table of entries with 2 columns
  tab <- matrix(info.txt, ncol = 2)


  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <- knitr::kable( tab, align=c("l","l")) %>%
    kableExtra::kable_styling(full_width = TRUE) %>%
    kableExtra::column_spec(1:ncol(tab), border_right = TRUE, border_left = TRUE) %>%
    kableExtra::row_spec(1:nrow(tab), extra_css = "border: 1px solid black;")
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )

}


## function to trim a text block to the first 48 characters
trim_txt_block <- function( x ){

  x <- stringr::str_split(x, ";;", simplify = FALSE)[[1]]
  x <- x |> trimws()

  if( max(nchar(as.character(x)),na.rm=T) > 48 )
  { x <- purrr::map_chr( x, function(x){ substr(x,1,48) } ) }

  t <- table( x ) |> sort( d=T )
  n <- length(t)
  max.n <- min(length(x) , 200)


  txt <- paste0( names(t)[1:max.n], collapse=" ;; " )
  BLOCK <- substr( txt,   1, 400 ) |> trimws()
  BLOCK <- gsub( " ?;{1,2} ?$", "", BLOCK )
  return( BLOCK )
}


### Character -----------------------------
#' Print Preview of a Character Variable into RG
#'
#' Read rg_preview column of DGF and print preview in a table in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"PREVIEW"`.
#'
#' @return This function does not return a value; it prints the formatted table to the RG as html code
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @import knitr
#' @export
paste_preview_chr <-function( VNAME, LABEL = "PREVIEW" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  info.txt <- trim_txt_block( info )
  info.txt <- unlist(stringr::str_split(info.txt, " ;; "))

  #remove the last entry if length is odd
  is.even <- length(info.txt) %% 2 == 0
  if(!is.even){info.txt <- info.txt[1:(length(info.txt)-1)]}

  #make table of entries with 2 columns
  tab <- matrix(info.txt, ncol = 2)

  # paste to markdown
  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  k <-  knitr::kable( tab, align=c("l","l")) %>%
    kableExtra::kable_styling(full_width = TRUE) %>%
    kableExtra::column_spec(1:ncol(tab), border_right = TRUE, border_left = TRUE) %>%
    kableExtra::row_spec(1:nrow(tab), extra_css = "border: 1px solid black;")
  cat( paste0( k, " \n" ) )
  cat( "\n\n" )

}

