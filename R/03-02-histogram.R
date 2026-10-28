

###########################################
### Paste Graphics - Numeric
###########################################

#' Abbreviate numbers for compact, uniform axis/graphic labels
#'
#' Formats numbers with K/M/B/T suffixes (thousands, millions, billions,
#' trillions) at a fixed number of significant figures, so labels stay short
#' and roughly the same width. Negatives keep their sign; `0` maps to `"0"`.
#' Vectorised.
#'
#' @param x A numeric vector.
#' @param sig Significant figures to keep (default 3).
#'
#' @return A character vector of abbreviated numbers, e.g. `-61.5M`, `4.18B`.
#' @examples
#' abbrev_num(c(-61467591, 100, 3.9, 4178522311))
#' @export
abbrev_num <- function( x, sig = 3 ) {
  one <- function( v ) {
    if( is.na(v) )   return( NA_character_ )
    if( v == 0 )     return( "0" )
    sgn <- if( v < 0 ) "-" else ""
    a   <- abs(v)
    p   <- min( floor( log10(a) / 3 ), 4L )          # 0 . K . M . B . T
    paste0( sgn, signif( a / 1000^p, sig ),
            c("", "K", "M", "B", "T")[p + 1] )
  }
  vapply( x, one, character(1) )
}

### Paste Histogram (Numeric) -------------------
#' Print the histogram of a numeric variable into the RG
#'
#' Reads the `rg_graphics` column of the DGF and draws a clean, axis-free
#' histogram of the winsorized distribution, with the true min/max abbreviated
#' at the lower corners and mean/median marked (labels on top). A dominant
#' spike (e.g. a pile of zeros) is capped so the rest of the shape stays
#' visible, and mean/median lines are clamped to the plot so an outlier mean
#' pins to the edge to signal skew.
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"rg_graphics"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"HISTOGRAM"`.
#'
#' @return No return value; draws the histogram into the RG.
#' @details Internal to `create_div` in R/03-01-create-sections.R.
#' @export
paste_histogram <- function( VNAME, LABEL = "HISTOGRAM" ){

  info   <- get_xx()[[VNAME]]
  x.info <- json_to_list( info )

  brk  <- as.numeric( unlist( x.info$breaks ) )
  dens <- as.numeric( unlist( x.info$density ) )
  avex <- as.numeric( unlist( x.info$mean ) )
  medx <- as.numeric( unlist( x.info$median ) )

  if( nzchar(trimws(LABEL)) ) cat( paste0( "**", LABEL, "**", ": ", "\n\n" ) )

  # cap a dominant bar so the rest of the shape is visible
  srt  <- sort( dens, decreasing = TRUE )
  ycap <- if( length(srt) >= 2 && srt[1] > 2 * srt[2] ) srt[2] * 1.15 else max(dens)

  # draw the bins as solid rectangles, inset slightly so a thin gap separates them
  par( mar = c(2.6, 0, 1.5, 0), xpd = NA )
  plot( range(brk), c(0, ycap), type = "n",
        axes = FALSE, xlab = "", ylab = "", xaxs = "i" )
  xl  <- brk[-length(brk)]; xr <- brk[-1]
  gap <- ( xr - xl ) * 0.18                     # inset -> visible spacing between bars
  rect( xl + gap/2, 0, xr - gap/2, pmin( dens, ycap ),
        col = "#465A6F", border = NA )

  usr <- par("usr")

  # Label the corners with the winsorized window actually drawn (range of the
  # bins), not the true min/max - otherwise the axis would misrepresent where the
  # bars stop. The true min/max are shown in the STATS section (MIN / MAX).
  mtext( abbrev_num( min(brk) ), side = 1, at = usr[1], adj = 0, line = 0.1,
         cex = 1.54, font = 2, col = "steelblue" )
  mtext( abbrev_num( max(brk) ), side = 1, at = usr[2], adj = 1, line = 0.1,
         cex = 1.54, font = 2, col = "steelblue" )

  # mean / median lines, clamped into the plot; labels on top. Both use the
  # report's orange accent - the labels say which is which.
  accent   <- "#bd5416"
  clamp    <- function(v) max( min( v, usr[2] ), usr[1] )
  mean.pos <- clamp( avex )
  med.pos  <- clamp( medx )

  abline( v = med.pos,  lty = 3, lwd = 2, col = accent )
  abline( v = mean.pos, lty = 3, lwd = 2, col = accent )
  # Label placement. Whichever line is further left gets its label on its
  # left side, the other on its right, so the labels point away from each
  # other. (The mean is left of the median in left-skewed data, so a fixed
  # "median left / mean right" rule made them collide.) A label that would run
  # off the chart flips to the inside of its line; if the two still overlap,
  # the second drops one line lower.
  labs <- data.frame( txt = c("median", "mean"), at = c(med.pos, mean.pos),
                      col = c(accent, accent), stringsAsFactors = FALSE )
  labs$w   <- strwidth( labs$txt, cex = 1, font = 2 )
  left     <- if( mean.pos < med.pos ) 2 else 1
  labs$adj <- ifelse( seq_len(2) == left, 1.10, -0.10 )     # outward
  span <- function( i, a ) c( labs$at[i] - a * labs$w[i], labs$at[i] + (1 - a) * labs$w[i] )
  for( i in 1:2 ) {
    s <- span( i, labs$adj[i] )
    if( s[1] < usr[1] ) labs$adj[i] <- -0.10                # would cross left edge
    if( s[2] > usr[2] ) labs$adj[i] <-  1.10                # would cross right edge
  }
  s1 <- span( 1, labs$adj[1] ); s2 <- span( 2, labs$adj[2] )
  clash <- s1[1] < s2[2] && s2[1] < s1[2]
  labs$line <- c( -0.3, if( clash ) -1.4 else -0.3 )
  for( i in 1:2 )
    mtext( labs$txt[i], side = 3, at = labs$at[i], line = labs$line[i], cex = 1,
           font = 2, col = labs$col[i], adj = labs$adj[i] )

  cat( "\n\n" )
}
