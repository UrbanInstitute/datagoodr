

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
#' @export
v_to_wordcloud <- function( VNAME, LABEL = "WORD CLOUD" ) {

  need_pkg( "ggplot2", "ggwordcloud", "scales", "tm", "wordcloud" )

  info <- get_xx()[[VNAME]]
  v <- json_to_df(info)
  v$ww   <- as.character( v$ww )
  v$Freq <- suppressWarnings( as.numeric( as.character( v$Freq ) ) )
  v <- v[ ! is.na(v$Freq) & nzchar( trimws(v$ww) ), , drop = FALSE ]
  v <- v[ order( -v$Freq ), , drop = FALSE ]

  if( nzchar(trimws(LABEL)) ) cat( paste0( "**", LABEL, "**", ": ", "\n\n" ) )

  if( nrow(v) == 0 ) { cat( "\n\n" ); return( invisible(NULL) ) }

  # Prefer ggwordcloud: a static ggplot with wordcloud2-style packing/hierarchy
  # and no headless-browser screenshot. Fall back to the wordcloud package when
  # ggwordcloud / ggplot2 are unavailable.
  if( requireNamespace("ggwordcloud", quietly = TRUE) &&
      requireNamespace("ggplot2",     quietly = TRUE) ) {
    print( build_wordcloud_gg( v ) )
  } else {
    scale.f   <- get_scale_f( v )
    scale.vec <- c( max(scale.f, 1), min(c(scale.f, 1)) )
    wordcloud::wordcloud(
      words = v$ww, freq = v$Freq, max.words = nrow(v), min.freq = 1,
      random.order = FALSE, scale = scale.vec, rot.per = 0, fixed.asp = FALSE,
      col = vc(), vfont = vf() )
  }

  cat( "\n\n" )
}


#' Build a wordcloud2-style ggwordcloud plot
#'
#' Renders a word-frequency table as a static [ggplot2] word cloud using
#' [ggwordcloud::geom_text_wordcloud_area()]: ~1/3 of words are rotated and
#' colour ramps from steel to ink by frequency.
#'
#' The size aesthetic is deliberately decoupled from the raw frequency
#' distribution so the cloud reads consistently across variables. Raw frequency
#' ranges swing enormously between fields (e.g. ~5:1 for contact names vs ~66:1
#' for street addresses); mapping that straight through `scale_size_area` makes
#' peaked variables collapse into a small central clump and flat ones sprawl.
#' Instead the frequencies are sqrt-compressed and rescaled into a fixed
#' `[0.30, 1]` window, and a fixed word count is used, so both the footprint and
#' the range of word sizes stay comparable regardless of input.
#'
#' @param v A data frame with columns `ww` (word) and `Freq` (numeric count).
#' @param max.words Maximum number of words to place (default 40).
#'
#' @return A `ggplot` object.
#' @keywords internal
#' @noRd
build_wordcloud_gg <- function( v, max.words = 40 ) {

  if( nrow(v) > max.words ) v <- v[ seq_len(max.words), , drop = FALSE ]

  # Compress the raw frequencies into a fixed size window. sqrt() gentles the
  # peak of highly skewed distributions; rescaling to [0.30, 1] then pins the
  # size range so it no longer depends on the distribution's shape (the floor
  # keeps the smallest words legible; the ceiling caps the largest). Both size
  # and colour read off this compressed value.
  s <- sqrt( v$Freq )
  v$sz <- scales::rescale( s / max(s), to = c(0.30, 1) )

  # ~1/3 of words rotated 90 degrees; fixed seed keeps the layout stable across
  # re-renders of the same variable.
  set.seed( 42 )
  v$rot <- sample( c(0, 0, 90), nrow(v), replace = TRUE )

  ggplot2::ggplot( v, ggplot2::aes( label = ww, size = sz,
                                    colour = sz, angle = rot ) ) +
    ggwordcloud::geom_text_wordcloud_area(
      family = "sans", fontface = "bold",
      eccentricity = 0.65, shape = "circle",
      rm_outside = FALSE, grid_margin = 1 ) +
    ggplot2::scale_size_area( max_size = 22 ) +
    ggplot2::scale_colour_gradient( low = "#7c93a8", high = "#12263a" ) +
    ggplot2::theme_void() +
    ggplot2::theme( legend.position = "none",
                    plot.margin = ggplot2::margin(0, 0, 0, 0) )
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

  # also reached from get_graphics_chr() at DGF-build time, not just at render
  need_pkg( "tm" )

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
