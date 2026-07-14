

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
  mids <- as.numeric( unlist( x.info$mids ) )
  dens <- as.numeric( unlist( x.info$density ) )
  avex <- as.numeric( unlist( x.info$mean ) )
  medx <- as.numeric( unlist( x.info$median ) )
  minx <- as.numeric( unlist( x.info$min ) )
  maxx <- as.numeric( unlist( x.info$max ) )

  cat( paste0( "**", LABEL, "**", ": ", "\n\n" ) )

  # cap a dominant bar so the rest of the shape is visible
  srt  <- sort( dens, decreasing = TRUE )
  ycap <- if( length(srt) >= 2 && srt[1] > 2 * srt[2] ) srt[2] * 1.15 else max(dens)

  # draw the ~25 bins as solid dark-gray rectangles (white hairline between)
  par( mar = c(2, 0, 1.5, 0), xpd = NA )
  plot( range(brk), c(0, ycap), type = "n",
        axes = FALSE, xlab = "", ylab = "", xaxs = "i" )
  rect( brk[-length(brk)], 0, brk[-1], pmin( dens, ycap ),
        col = "gray25", border = "white", lwd = 0.6 )

  usr <- par("usr")

  # true min / max at the lower corners (abbreviated, so nothing crops)
  mtext( abbrev_num(minx), side = 1, at = usr[1], adj = 0, line = 0.1,
         cex = 1.1, font = 2, col = "gray40" )
  mtext( abbrev_num(maxx), side = 1, at = usr[2], adj = 1, line = 0.1,
         cex = 1.1, font = 2, col = "gray40" )

  # mean / median lines, clamped into the plot; labels on top
  clamp    <- function(v) max( min( v, usr[2] ), usr[1] )
  mean.pos <- clamp( avex )
  med.pos  <- clamp( medx )

  abline( v = med.pos,  lty = 3, lwd = 2, col = "steelblue" )
  abline( v = mean.pos, lty = 3, lwd = 2, col = "firebrick" )
  # Label placement: near an edge, push the text inward so it stays on-chart
  # (e.g. an outlier mean clamped to the right edge). In the middle, offset
  # median left / mean right so the two never collide when they sit close.
  lab_adj <- function( pos, side ) {
    frac <- ( pos - usr[1] ) / ( usr[2] - usr[1] )
    if( frac > 0.85 ) return( 1 )                 # near right: extend left
    if( frac < 0.15 ) return( 0 )                 # near left:  extend right
    if( side == "median" ) 1.05 else -0.05        # middle: split them
  }
  mtext( "median", side = 3, at = med.pos,  line = -0.3, cex = 1,
         font = 2, col = "steelblue", adj = lab_adj(med.pos,  "median") )
  mtext( "mean",   side = 3, at = mean.pos, line = -0.3, cex = 1,
         font = 2, col = "firebrick", adj = lab_adj(mean.pos, "mean") )

  cat( "\n\n" )
}
