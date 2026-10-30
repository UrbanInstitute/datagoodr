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
#'
#' @details A timestamp column can have as many distinct values as it has rows,
#'   and one table row per distinct value made a 568,000-row file store a
#'   39,700,000-character cell per timestamp variable (past Excel's cell limit,
#'   and the bulk of the DGF). When there are more than
#'   `getOption("datagoodr.temporal.max_values", 10000)` distinct values and they
#'   open with an ISO date, they are stored at the finest of minute, hour or day
#'   that fits the cap (see `.coarsen_timestamps()`). Nothing is lost for any grain
#'   the renderer can draw from a timestamp (date, week, month, year), and a
#'   column under the cap is stored exactly as before.
#' @noRd
get_graphics_temporal <- function(VNAME, df){
  x <- as.character( unlist( df[[VNAME]] ) )
  x <- x[ !is.na(x) & trimws(x) != "" & x != "." ]
  if( length(x) == 0 ) return("")
  x   <- .coarsen_timestamps( x, getOption( "datagoodr.temporal.max_values", 10000L ) )
  tt  <- table( x )
  tab <- data.frame( Value = names(tt),
                     Count = as.integer(tt),
                     stringsAsFactors = FALSE )
  jsonify_df( tab )
}


#' Coarsen ISO timestamps to fit a cap on distinct values (internal)
#'
#' @param x Character timestamps (already stripped of missing values).
#' @param max_values Most distinct values to keep. `NULL`, `NA` or a value below 1
#'   turns coarsening off.
#' @return `x`, unchanged unless it has more than `max_values` distinct values and
#'   at least 95% of them open with `YYYY-MM-DD`. Then every ISO value is cut to
#'   the first of 16 (minute), 13 (hour) or 10 (day) characters that brings the
#'   distinct count to `max_values` or below, falling back to the day. A prefix is
#'   kept, not a reformatted value, so the renderer's `parse_dates()` still reads it.
#' @noRd
.coarsen_timestamps <- function( x, max_values = 10000L ) {
  n <- .timestamp_cut( unique( x ), max_values )
  if( is.na(n) ) return( x )
  iso <- grepl( "^[0-9]{4}-[0-9]{2}-[0-9]{2}", x )
  x[ iso ] <- substr( x[ iso ], 1L, n )
  x
}

#' How many leading characters of an ISO timestamp to keep (internal)
#'
#' The one place that decides whether, and how far, a timestamp column is coarsened,
#' shared by the profiler (`.coarsen_timestamps()`) and the preflight check, so the
#' check predicts exactly what the profiler will do.
#'
#' @param ux Distinct character values.
#' @param max_values Cap on distinct values.
#' @return `NA` when nothing should be cut (under the cap, cap off, or not
#'   timestamps); otherwise 16 (minute), 13 (hour) or 10 (day).
#' @noRd
.timestamp_cut <- function( ux, max_values = 10000L ) {
  if( !is.numeric(max_values) || length(max_values) != 1 || is.na(max_values) ||
      max_values < 1 ) return( NA_integer_ )
  if( length(ux) <= max_values ) return( NA_integer_ )
  if( mean( grepl( "^[0-9]{4}-[0-9]{2}-[0-9]{2}", ux ) ) < 0.95 ) return( NA_integer_ )
  for( n in c( 16L, 13L ) )
    if( length( unique( substr( ux, 1L, n ) ) ) <= max_values ) return( n )
  10L
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

  tab1 <- as.data.frame(.freq_table(x))
  tab1$PER <- tab1$Freq / sum(tab1$Freq) * 100
  max.per <- tab1$PER[1]

  #only reformat if largest group has more than 2%
  if(max.per >= 2){
    tab1$is.g2 <- tab1$PER >=2
    tab <- tab1[tab1$is.g2, 1:2]
    tab$x <- as.character(tab$x)
    # Roll the sub-2% levels into "other" - but only when some exist. A factor
    # whose levels all sit at or above 2% (e.g. 50 states at 2.0% each) has no
    # tail to collect; appending an empty "other" row here would otherwise seed
    # a spurious 0-frequency level that paste_treemap() later inflates.
    if(any(!tab1$is.g2)){
      tab[nrow(tab)+1, 1] <- "other"
      tab[nrow(tab), 2] <- sum(tab1$Freq[!tab1$is.g2])
    }
  } else {
    # No single level reaches 2% (a flat, high-cardinality factor): keep the top
    # 20 levels by frequency and roll the long tail into "other". Without this
    # branch `tab` would be undefined and jsonify_df() below would error.
    n.keep <- min(nrow(tab1), 20)
    tab <- tab1[seq_len(n.keep), 1:2]
    tab$x <- as.character(tab$x)
    if(nrow(tab1) > n.keep){
      tab[nrow(tab)+1, 1] <- "other"
      tab[nrow(tab), 2] <- sum(tab1$Freq[(n.keep+1):nrow(tab1)])
    }
  }

  ret <- jsonify_df(tab)
  return(ret)
}



### Numeric (histogram)---------------------------------------

#' Detect the step values are rounded to (internal)
#'
#' Data are often "heaped": weights recorded to the nearest 5 lb, incomes to the
#' nearest 1,000, counts as whole numbers. Returns the largest step from 1, 2,
#' 5, 10, 25, 50, 100, ... (scaled to the data) that at least `share` of the
#' non-zero values are multiples of, or `NA` when the values are not heaped.
#' Zeros are left out: zero is a multiple of every step, so a pile of zeros
#' would otherwise suggest a huge step.
#'
#' @param x Numeric vector (NAs dropped).
#' @param share Minimum share of non-zero values that must sit on the step.
#' @param min.bins The step must leave at least this many steps across the range.
#' @return A single number, or `NA`.
#' @noRd
heap_step <- function( x, share = 0.8, min.bins = 4 ) {
  x  <- x[ is.finite(x) ]
  nz <- x[ x != 0 ]
  if( length(nz) < 10 ) return( NA_real_ )
  rng <- diff( range(x) )
  if( rng <= 0 ) return( NA_real_ )
  mags  <- 10^( seq( 0, max( 0, floor( log10( rng ) ) ) ) )
  steps <- sort( unique( c( outer( c(1, 2, 2.5, 5), mags ) ) ), decreasing = TRUE )
  steps <- steps[ steps <= rng / min.bins ]
  for( s in steps ) {
    on <- abs( nz / s - round( nz / s ) ) < 1e-8
    if( mean(on) >= share ) return( s )
  }
  NA_real_
}

#' Histogram break points (internal)
#'
#' About 50 equal-width bins. When the values are heaped on a step (see
#' [heap_step()]), the bin width is a whole multiple of that step and the
#' breaks sit on multiples of it, so every bin holds the same number of
#' possible values. Without this, 1.5-lb bins over weights rounded to 5 lb
#' catch a round number in every third bin and the chart looks like a comb.
#' Bins are left-closed (`right = FALSE`), so a value on a break counts in the
#' bin that starts there.
#'
#' @param x Numeric vector (the winsorized values to bin).
#' @param nbins Target number of bins.
#' @return An increasing numeric vector of breaks.
#' @noRd
hist_breaks <- function( x, nbins = 50 ) {
  rng <- range( x )
  # exactly `nbins` equal-width bins (a bare `breaks = 50` is only a suggestion
  # that hist() rounds to "pretty" limits, giving an inconsistent bin count)
  even <- seq( rng[1], rng[2], length.out = nbins + 1 )
  s <- heap_step( x )
  if( is.na(s) ) return( even )
  w <- s * max( 1, ceiling( diff(rng) / nbins / s ) )   # a whole number of steps
  lo <- floor( rng[1] / w ) * w
  hi <- ( floor( rng[2] / w ) + 1 ) * w                  # left-closed: max needs a bin
  seq( lo, hi, by = w )
}

#' Histogram data for a numeric variable (internal)
#'
#' Bins the variable into about 50 equal-width bins for plotting (snapped to
#' the rounding step of heaped data - see [hist_breaks()]), and carries the
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

  h <- hist( xw, breaks = hist_breaks( xw ), include.lowest = TRUE,
             right = FALSE, plot = FALSE )
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
