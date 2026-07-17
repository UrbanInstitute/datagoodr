##############################
### Functions called to paste rg_graphics into DGF
###############################
## need to load R/01-03-get-stats.R before loading this file

#' Generate Graphics Based on Variable Type
#'
#' Generates needed graphics for rg_graphics column of the DGF. Used inside R/01-00-CREATE-DGF.R
#'
#' @param VNAME A character string specifying the name of the variable in the data frame. (From var_name column of the DGF)
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
  }else if(VCLASS == "identifier"){
    return("")                          # identifiers have no visualization
  }else if(VCLASS == "temporal"){
    return(get_graphics_temporal(VNAME,df))
  }else(
    return(get_graphics_chr(VNAME,df))
  )
}


### Temporal ------------------------------------

#' Frequency data for a temporal variable (internal)
#'
#' Stores a value -> count table of the raw temporal values. This is
#' deliberately unit-independent: which chart to draw (calendar heatmap,
#' scatterplot, barchart, histogram) is decided at render time from
#' `stable_data_unit`, so a user can change the unit in the DGF and re-render
#' without rebuilding the DGF. See [paste_temporal_graphic()].
#'
#' @param VNAME Character; the variable name (a column of `df`).
#' @param df The dataset being profiled.
#'
#' @return A JSON string: a two-column Value/Count table, stored in the DGF's
#'   `rg_graphics` column.
#' @noRd
get_graphics_temporal <- function(VNAME, df){
  x <- as.character( unlist( df[[VNAME]] ) )
  x <- x[ !is.na(x) & trimws(x) != "" & x != "." ]
  if( length(x) == 0 ) return("")
  tt  <- table( x )
  tab <- data.frame( Value = names(tt),
                     Count = as.integer(tt),
                     stringsAsFactors = FALSE )
  jsonify_df( tab )
}


### Character (Word Cloud) ------------------------------------

#' Word-cloud data for a character variable (internal)
#'
#' Splits the variable's text into words, drops stop words and punctuation, and
#' keeps the 50 most frequent remaining words with their counts.
#'
#' @param VNAME Character; the variable name (a column of `df`).
#' @param df The dataset being profiled.
#'
#' @return A JSON string: a two-column word/frequency table, stored in the
#'   DGF's `rg_graphics` column and read back by [v_to_wordcloud()].
#' @noRd
get_graphics_chr <- function(VNAME, df){

  v <- df[[VNAME]] #this should be the input data set
  ddd <- head(simplify_char( v ), 50)
  ret <- jsonify_df(ddd)
  return(ret)
  #later use R/03-04-wordcloud.R
}


### Logical (Bar Plot/ Boolean Plot) ------------------------------------
#' Bar-plot data for a logical variable (internal)
#'
#' Tabulates the variable's two categories, counting `NA` as its own level so
#' missingness stays visible on the plot.
#'
#' @param VNAME Character; the variable name (a column of `df`).
#' @param df The dataset being profiled.
#'
#' @return A JSON string: a value/frequency table, stored in the DGF's
#'   `rg_graphics` column and read back by [paste_booleplot()].
#' @noRd
get_graphics_log <-  function( VNAME, df ) {

    f <- as.character(df[[VNAME]]) #this should be the input data set
    f[ is.na(f) ] <- "NA"
    t <- as.data.frame(table( f ))
    ret <- jsonify_df(t)
    return(ret)
    #later use R/03-03-booleplot.R
}


### Factor (treemap) ---------------------------------------

#' Treemap data for a factor variable (internal)
#'
#' Tabulates the factor's levels by frequency and collapses the long tail into
#' a single `"other"` category, so a variable with many rare levels still
#' produces a readable treemap.
#'
#' @param VNAME Character; the variable name (a column of `df`).
#' @param df The dataset being profiled.
#'
#' @return A JSON string: a level/frequency table, stored in the DGF's
#'   `rg_graphics` column and read back by [paste_treemap()].
#'
#' @details Levels holding at least 2% of values are kept individually; the
#'   rest are summed into `"other"`. The collapse only happens when the largest
#'   level itself clears 2% - otherwise every level is rare and the table is
#'   returned as-is.
#' @noRd
get_graphics_fact <- function(VNAME, df ){

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

#' Histogram data for a numeric variable (internal)
#'
#' Bins the variable into 50 equal-width bins for plotting, and carries the
#' true mean/median/min/max alongside so the chart can annotate them.
#'
#' @param VNAME Character; the variable name (a column of `df`).
#' @param df The dataset being profiled.
#'
#' @return A JSON string holding `breaks`, `density`, `y`, `mids`, `mean`,
#'   `median`, `min` and `max`, stored in the DGF's `rg_graphics` column and
#'   read back by [paste_histogram()].
#'
#' @details Bins are computed on values winsorized to the 5th/95th percentiles
#'   so long tails do not flatten the bulk of the distribution; the summary
#'   statistics returned are computed on the unclipped data.
#' @noRd
get_graphics_num <- function(VNAME, df ){

  need_pkg( "psych" )

  x <- df[[VNAME]] #this should be the input data set

  # these values should be saved in the dgf for the quantiles table
  me = mean(x, na.rm = TRUE)
  med = median(x, na.rm = TRUE)
  min = min(x, na.rm = TRUE)
  max = max(x, na.rm = TRUE)
  sk = psych::skew(x)

  # Winsorize at the 5th/95th percentiles so long tails - including a handful of
  # negative outliers common in financial indicators - don't dominate the x-scale
  # and the bulk's shape stays visible. The true min/max/mean/median are stored
  # above and shown on the chart; a dominant bar (e.g. a pile of zeros) is capped
  # at render.
  x  <- x[ !is.na(x) ]
  lo <- quantile( x, 0.05, names = FALSE )
  hi <- quantile( x, 0.95, names = FALSE )
  xw <- x[ x >= lo & x <= hi ]
  if( length( unique(xw) ) < 2 ) xw <- x     # degenerate clip -> use all

  # exactly 50 equal-width bins (a bare `breaks = 50` is only a suggestion that
  # hist() rounds to "pretty" limits, giving an inconsistent bin count)
  rng <- range( xw )
  h <- hist( xw, breaks = seq( rng[1], rng[2], length.out = 51 ),
             include.lowest = TRUE, plot = FALSE )
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



# simplify_char() lives in R/03-02-wordcloud.R, next to the word-frequency code
# it shares its stop-word handling with. get_graphics_chr() above calls it.
