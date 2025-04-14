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
#' Read rg_properties column of DGF and print properties in a table in teh RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string for the section title. Defaults to `"PROPERTIES"`.
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



###########################################
### Paste Graphics
### (some graphics have their own 03-0*-*.R File)
###########################################

### Paste Histogram (Numeric) -------------------

paste_histogram <- function( VNAME, LABEL = "HISTOGRAM" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  x.info <- json_to_list(info)

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  par( mar=c(2,0,1,0) )
  plot( x.info$mids, x.info$d,
        type="h", bty="n", lwd=4, axes=F, col="gray30" )

  x1 <- unlist(x.info$mids[1])
  x2 <- unlist(x.info$mids[length(x.info$mids)])
  min.x <- x1 |> make3()
  max.x <- x2 |> make3()

  axis( side=1, at=c(x1,x2),
        labels=c(x.info$min, x.info$max), cex.axis=1.3,
        line=-0.5, tick=F, font=2, col.axis="gray40" )

  avex <- unlist(x.info$mean)
  medx <- unlist(x.info$median)

  abline( v=avex, lty=3, lwd=2, col="firebrick" )
  abline( v=medx, lty=3, lwd=2, col="steelblue" )
  axis( side=1, at=medx, label="median", font=2,
        col.axis="steelblue", tick=F, line=-1 )
  axis( side=1, at=avex, label="mean", font=2,
        col.axis="firebrick", tick=F, line=-0.5 )

  cat( "\n\n" )

}

# FORMAT NUMBER LABELS
# SO THEY ARE ALWAYS A
# UNIFORM WIDTH FOR GRAPHS

make3 <- function(x){
  # need to fix for
  # large negative nums
  if( x < 0 ){
    x <- paste0( round(x,3) )
    return(x)
  }
  if( x >= 0 & x < 10 ){
    x <- paste0( round(x,2)  )
    return(x)
  }
  if( x >= 10 & x < 100 ){
    x <- paste0( round(x,1)  )
    return(x)
  }
  if( x > 10^2 & x < 10^6 ){
    x <- paste0( round(x/(10^3),0), "K" )
    return(x)
  }
  if( x >= 10^6 & x < 10^9 ){
    x <- paste0( round(x/(10^6),0), "M" )
    return(x)
  }
  if( x >= 10^9 & x < 10^12 ){
    x <- paste0( round(x/(10^9),0), "B" )
    return(x)
  }
  if( x >= 10^12 & x < 10^15 ){
    x <- paste0( round(x/(10^12),0), "T" )
    return(x)
  }
  if( x >= 10^15 ){
    x <- "BFN"
    return(x)
  }
}

