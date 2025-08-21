

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

#' Compute a scaling factor for word clouds
#'
#' Calculates a scaling factor based on word lengths and frequencies in a data frame.
#'
#' @param df A data frame containing at least two columns:
#'   - `ww`: character vector of words
#'   - `Freq`: numeric vector of frequencies corresponding to each word
#'
#' @return A numeric scaling factor.
#'
#' @details
#' - The function sums the number of characters across all words.
#' - It normalizes the frequencies and calculates a factor based on word lengths
#'   and normalized frequency.
#' - Used for scaling word sizes in word clouds in \link{v_to_wordcloud}.
#'
#' @keywords internal
#' @noRd
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

#' Simplify character vector for word frequency analysis
#'
#' Processes a character vector by removing English stopwords and punctuation,
#' and returns a frequency table of remaining words. Used in \link{simplify_char}.
#'
#' @param v A character vector or string to process.
#'
#' @return A data frame with two columns:
#'   - `ww`: unique words after cleaning
#'   - `Freq`: frequency of each word, sorted in decreasing order
#'   The result is limited to the top 400 words if there are more.
#'
#' @details
#' - Splits the input text by spaces.
#' - Removes English stopwords (both lowercase and uppercase).
#' - Removes punctuation and empty strings.
#' - Counts word frequencies and returns a sorted data frame.
#'
#' @keywords internal
#' @noRd
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
#' Randomly select a font style
#'
#' Picks one of several predefined font families and styles at random.
#' Used in \link{v_to_wordcloud}.
#'
#' @return A character vector of length 2 containing the font family and style,
#'   or `NULL`.
#'
#' @details
#' - Possible selections include `"script"`/`"bold"`, `"serif"`/`"plain"`,
#'   `"sans serif"`/`"bold"`, or `NULL`.
#'
#' @keywords internal
#' @noRd
vf <- function(){

  fonts <- list(
    c("script","bold"),
    c("serif","plain"),
    c("sans serif","bold"),
    NULL )

  sample( fonts, 1 ) |> unlist()

}
#' Randomly select a color
#'
#' Picks one color at random from a predefined set of colors.
#' Used in \link{v_to_wordcloud}.
#'
#' @return A single character string representing a color name.
#'
#' @details
#' - Colors include `"navy"`, `"slategray4"`, `"darkorchid4"`, `"forestgreen"`,
#'   `"goldenrod4"`, `"darkolivegreen4"`, `"mistyrose4"`, `"navajowhite4"`,
#'   `"magenta4"`, `"seagreen4"`, `"yellow4"`, `"dodgerblue1"`, `"mediumvioletred"`.
#'
#' @keywords internal
#' @noRd
vc <- function() {

  colz <-
   c("navy", "slategray4", "darkorchid4", "forestgreen", "goldenrod4",
     "darkolivegreen4", "mistyrose4", "navajowhite4", "magenta4",
     "seagreen4", "yellow4", "dodgerblue1", "mediumvioletred")

  sample( colz, 1 )

}
