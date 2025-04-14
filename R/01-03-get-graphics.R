##############################
### Functions called to paste rg_graphics into DGF
###############################
## need to load R/01-03-get-stats.R before loading this file

#' Generate Graphics Based on Variable Type
#'
#' Generates needed graphics for rg_graphics column of the DGF. Used inside R/01-00-CREATE-DGF.R
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
get_graphics <- function(VNAME, df, VCLASS){

  if(VCLASS == "numeric"){
    return(get_graphics_num(VNAME,df))
  }else if(VCLASS == "factor"){
    return(get_graphics_fact(VNAME,df))
  }else if(VCLASS == "logical"){
    return(get_graphics_log(VNAME,df))
  }else(
    return(get_graphics_chr(VNAME,df))
  )
}


### Character (Word Cloud) ------------------------------------

# outputs table of 50 most common strings and their associated frequencies
get_graphics_chr <- function(VNAME, df){

  # VNAME <- xx[VNAME]
  # # for testing VNAME <- all.vars[1]

  v <- df[[VNAME]] #this should be the input data set
  ddd <- head(simplify_char( v ), 50)
  ret <- jsonify_df(ddd)
  return(ret)
  #later use R/03-04-wordcloud.R
}


### Logical (Bar Plot/ Boolean Plot) ------------------------------------
# outputs table of 2 strings (and any NA's ) and their associated frequencies
get_graphics_log <-  function( VNAME, df ) {

    # VNAME <- xx[VNAME]
    # # for testing VNAME <- all.vars[1]

    f <- as.character(df[[VNAME]]) #this should be the input data set
    f[ is.na(f) ] <- "NA"
    t <- as.data.frame(table( f ))
    ret <- jsonify_df(t)
    return(ret)
    #later use R/03-03-booleplot.R
}


### Factor (treemap) ---------------------------------------

# outputs table of (max) 50 most common factors and their frequencies
# anything with less than 2% frequency gets put into "other" category
get_graphics_fact <- function(VNAME, df ){

  # VNAME <- xx[VNAME]
  # # for testing VNAME <- all.vars[1]

  x <- df[[VNAME]] #this should be the input data set
  x <- as.character(x)

  tab1 <- as.data.frame(sort(table(x), decreasing = TRUE))
  tab1$PER <- tab1$Freq / sum(tab1$Freq) * 100
  max.per <- tab1$PER[1]

  #only reformat if largest group has more than 2%
  if(max.per >= 2){
    tab1$is.g2 <- tab1$PER >=2
    tab <- tab1[tab1$is.g2, 1:2]
    tab$x <- as.character(tab$x)
    tab[nrow(tab)+1, 1] <- "other"
    tab[nrow(tab), 2] <- sum(tab1$Freq[!tab1$is.g2])
  }

  ret <- jsonify_df(tab)
  return(ret)
}



### Numeric (histogram)---------------------------------------

# list of information needed to generate histogram
get_graphics_num <- function(VNAME, df ){

  # VNAME <- xx[VNAME]
  # # for testing VNAME <- all.vars[1]

  x <- df[[VNAME]] #this should be the input data set

  # these values should be saved in the dgf for the quantiles table
  me = mean(x, na.rm = TRUE)
  med = median(x, na.rm = TRUE)
  min = min(x, na.rm = TRUE)
  max = max(x, na.rm = TRUE)
  sk = skew(x)

  #windsorize
  x <- x[!is.na(x)]
  lower <- quantile(x, probs = c(0.05), na.rm = TRUE)
  upper <- quantile(x, probs = c(0.9), na.rm = TRUE)
  x <- x[x >= lower & x <= upper]
  # x[x < lower ] <- lower
  # x[x > upper ] <- upper


  #cutoff according to the skew
  if(sk >0){
    quant <- 0.75 +  0.25 / (log(sk+20))
    cutoff <- quantile(x, quant)
    x <- x[x<=cutoff]
  }else{
    quant <- 0.25 * (1-1/log(sk+20))
    cutoff <- quantile(x, quant)
    x <- x[x>=cutoff]
  }



  # cut off upper values
  h <- hist( x, 100, plot=F )
  b <- h$breaks
  d <- h$density/sum(h$density)
  y <- h$counts
  mids <- h$mids # xx

  ret <- list(breaks=b, density=d, y=y, mids=mids,
              mean = me, median = med,
              min = min, max = max)
  ret <- jsonify_stats(ret)

  return(ret)
}



##############################
### Internal Funcs
##############################

# simplifies character string to first 400 characters
simplify_char <- function(v) {

  ww <- strsplit( v, " " ) |> unlist()
  stop.words <- tm::stopwords("english")
  stop.words <- c( stop.words, toupper(stop.words) )
  ww <- ww[ ! ww %in% stop.words ]
  ww <- gsub( "[[:punct:]]", "", ww )
  ww <- ww[ ww != "" ]

  dd <- as.data.frame(sort(table(ww),decreasing=T))
  n.row <- nrow(dd)
  if( n.row > 400 )
  { dd <- dd[1:400,] }

  return(dd)
}
