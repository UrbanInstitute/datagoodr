

###########################################
### Paste Graphics - Character
###########################################

### Paste word cloud (character) -------------------
#' Print Graphics of a character Variable into RG
#'
#' Read rg_graphics column of DGF and print word cloud in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"Word Cloud"`.
#'
#' @return This function does not return a value; it prints the formatted word cloud to the RG
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#' @import treemap
#' @export
v_to_wordcloud <- function( VNAME, LABEL = "WORD CLOUD" ) {

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  v <- json_to_df(info)

  # get for scaling - this isn't perfect but it works for now
  scale.f <- get_scale_f( v )
  scale.vec <- c(max(scale.f, 1), min(c(scale.f, 1)))


  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  wordcloud::wordcloud(
    words=v$ww, freq=v$Freq,
    max.words=nrow(v),
    min.freq=1,
    random.order=FALSE,
    scale=scale.vec,
    rot.per=0, fixed.asp=F,
    col=vc(), vfont=vf()  )

  cat( "\n\n" )


}




#  returns the max num
#  to be used in the
#  scale argument in wordcloud
#  using a ratio of the
#  sum of characters across
#  all words in the word count table,
#  and the distribution of their frequency

get_scale_f <- function( df ) {
  n.char <- sum( nchar(as.character( df$ww ))  )
  xxx <- df$Freq / max(df$Freq)
  n.scale <- sum( xxx )
  n.row <- nrow(df)
  scale.f <- 0.004 * ( n.char / exp( n.scale/n.row ) )
  return( scale.f )
}



# Simplifies long character strings to make them look nice for plot
# I think this is a duplicate defining of this function
# but I don't remember where the first one is so it doesn't hurt to define it twice

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



### Pick random color and font

vf <- function(){

  fonts <- list(
    c("script","bold"),
    c("serif","plain"),
    c("sans serif","bold"),
    NULL )

  sample( fonts, 1 ) |> unlist()

}

vc <- function() {

  colz <-
   c("navy", "slategray4", "darkorchid4", "forestgreen", "goldenrod4",
     "darkolivegreen4", "mistyrose4", "navajowhite4", "magenta4",
     "seagreen4", "yellow4", "dodgerblue1", "mediumvioletred")

  sample( colz, 1 )

}
