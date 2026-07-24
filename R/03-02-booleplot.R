

###########################################
### Paste Graphics - Logical
###########################################

### Booleplot drawing primitive -------------------
#' Draw a compact horizontal bar plot with consistent bar geometry
#'
#' A horizontal count bar plot whose bar thickness is a fixed multiple of the
#' label text height, so the graphic reads the same regardless of how many
#' categories it has (two-value flags no longer render as fat slabs). Category
#' names sit in the left margin; each bar is labelled to its right with its
#' count and share (e.g. `22.6K  (90.4%)`) via [abbrev_num()], so the count
#' table travels inside the plot. Categories are sorted largest-to-smallest with
#' the missing (`NA`) category always pushed last and drawn as a light bar with
#' a steel-blue outline, so missingness reads as a gap rather than a value.
#'
#' @param x A named numeric vector (or one-way `table`) of non-negative counts;
#'   the names are the category labels.
#' @param bar_text_ratio Target bar thickness as a multiple of the label text
#'   height. Defaults to `3`.
#' @param gap_ratio Gap between bars as a fraction of bar height. Defaults to
#'   `1/3`.
#' @param bar_col Fill for ordinary bars. Defaults to `"steelblue"`.
#' @param na_col,na_border,na_lty,na_lwd Fill, border colour, line type and line
#'   width for the missing (`NA`) bar.
#' @param na_label The label treated as the missing category. Defaults to
#'   `"NA"`.
#' @param cex.names,cex.value Text scaling for the category names (left) and the
#'   count/share labels (right).
#' @param value_col Colour of the count/share labels. Defaults to `"gray30"`.
#' @param x_pad Fractional padding added past the longest bar. Defaults to
#'   `0.03`.
#' @param plot_height_inches Device plot height used to size the bars. Defaults
#'   to the actual device height (`par("pin")[2]`), which is what keeps the bar
#'   thickness consistent across variables.
#' @param mar Plot margins (bottom, left, top, right). The left margin holds the
#'   category names. Defaults to `c(0, 4.5, 0, 0.5)`.
#' @param ... Passed to [graphics::rect()].
#'
#' @return Invisibly, a list describing the geometry actually used.
#' @export
booleplot <- function(
    x,
    bar_text_ratio     = 2,
    gap_ratio          = 1 / 3,
    bar_col            = "steelblue",
    na_col             = "#d7e0e8",
    na_border          = "steelblue",
    na_lty             = 1,
    na_lwd             = 1.3,
    na_label           = "NA",
    cex.names          = 1.8,
    cex.value          = 1.4,
    value_col          = "gray30",
    x_pad              = 0.03,
    plot_height_inches = NULL,
    mar                = c(0, 6.0, 0, 1.5),
    ... ) {

  # Convert tables and other named numeric objects to a named vector
  values <- as.numeric(x)
  labels <- names(x)
  if( is.null(labels) ) labels <- as.character( seq_along(values) )

  if( ! length(values) )        stop( "`x` must contain at least one value." )
  if( any( ! is.finite(values) ) ) stop( "All values in `x` must be finite." )
  if( any( values < 0 ) )
  { stop( "This function currently supports nonnegative values only." ) }

  # Identify, then order: ordinary categories largest-to-smallest, NA last.
  is_na_category <- is.na(labels) | labels == na_label
  ordinary <- which( ! is_na_category )
  missing  <- which(   is_na_category )
  ordinary <- ordinary[ order( values[ordinary], decreasing = TRUE ) ]
  missing  <- missing [ order( values[missing],  decreasing = TRUE ) ]
  ord      <- c( ordinary, missing )

  values         <- values[ord]
  labels         <- labels[ord]
  is_na_category <- is_na_category[ord]
  labels[ is.na(labels) ] <- na_label

  n <- length(values)

  # count + share labels drawn to the right of each bar
  total     <- sum(values)
  share     <- if( total > 0 ) values / total * 100 else rep(0, n)
  right_lab <- paste0( abbrev_num(values), "  (",
                       formatC( share, format = "f", digits = 1 ), "%)" )

  old_par <- graphics::par( no.readonly = TRUE )
  on.exit( graphics::par(old_par) )
  graphics::par( mar = mar )

  # Initiate the plotting frame so physical device dimensions are available
  graphics::plot.new()

  # Geometry in arbitrary vertical user-coordinate units. Bars are 1 unit tall.
  bar_height <- 1
  gap_height <- gap_ratio * bar_height
  step       <- bar_height + gap_height
  required_range <- n * bar_height + (n - 1) * gap_height

  # Physical text heights/widths (inches), read off the live device
  text_height_inches <- graphics::strheight( "Mg", units = "inches", cex = cex.names )
  if( is.null(plot_height_inches) ) plot_height_inches <- graphics::par("pin")[2]

  # Vertical range that makes one bar ~ bar_text_ratio * the text height; never
  # smaller than the space the bars themselves need.
  target_range <- plot_height_inches / ( bar_text_ratio * text_height_inches )
  y_range      <- max( target_range, required_range )

  # Largest category at the top; centre the bars when there is spare room.
  y_offset <- ( y_range - required_range ) / 2
  y <- rev( seq( from = bar_height / 2, by = step, length.out = n ) ) + y_offset
  ylim <- c( 0, y_range )

  # Reserve horizontal room for the right-hand count/share labels so they fit
  # inside the plot instead of being clipped. Convert the widest label from
  # inches to user units against the plot's physical width.
  xmax <- max(values); if( xmax == 0 ) xmax <- 1
  pin_w    <- graphics::par("pin")[1]
  lab_w_in <- max( graphics::strwidth( right_lab, units = "inches", cex = cex.value ) )
  gap_in   <- graphics::strwidth( "00", units = "inches", cex = cex.value )
  avail_in <- pin_w - lab_w_in - gap_in
  if( avail_in <= pin_w * 0.25 ) avail_in <- pin_w * 0.55   # degenerate: keep bars visible
  xmax_user <- xmax * ( 1 + x_pad ) * pin_w / avail_in

  graphics::plot.window( xlim = c(0, xmax_user), ylim = ylim,
                         xaxs = "i", yaxs = "i" )

  draw_bars <- function( idx, col, border, lty = 1, lwd = 1 ) {
    if( ! any(idx) ) return( invisible() )
    graphics::rect( xleft = 0, ybottom = y[idx] - bar_height / 2,
                    xright = values[idx], ytop = y[idx] + bar_height / 2,
                    col = col, border = border, lty = lty, lwd = lwd, ... )
  }
  draw_bars( ! is_na_category, bar_col, NA )                       # ordinary bars
  draw_bars(   is_na_category, na_col, na_border, na_lty, na_lwd ) # NA bar

  # category names in the left margin
  graphics::axis( side = 2, at = y, labels = labels, las = 1, tick = FALSE,
                  cex.axis = cex.names, col.axis = "gray30" )

  # count + share to the right of each bar
  graphics::text( values, y, labels = right_lab, pos = 4, offset = 0.4,
                  cex = cex.value, font = 2, col = value_col, xpd = NA )

  invisible( list(
    values = stats::setNames( values, labels ),
    y = y, bar_height = bar_height, gap_height = gap_height,
    requested_bar_text_ratio = bar_text_ratio,
    actual_bar_text_ratio = plot_height_inches / y_range / text_height_inches ) )
}


### Paste Booleplot (logical) -------------------
#' Print the bar plot of a logical variable into the RG
#'
#' Reads the `rg_graphics` column of the DGF and draws the logical value counts
#' with [booleplot()]: a fixed-geometry horizontal bar plot with the category
#' names in the left margin and each bar's count and share (`22.6K  (90.4%)`) to
#' its right. Categories are sorted largest-to-smallest with the missing (`NA`)
#' category last, drawn as a light bar with a steel-blue outline.
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"rg_graphics"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"VALUES"`.
#'
#' @return No return value; draws the bar plot into the RG.
#' @details Internal to `create_div` in R/03-01-create-sections.R.
#' @export
paste_booleplot <- function( VNAME, LABEL = "VALUES" ) {

  info <- get_xx()[[VNAME]]
  v <- json_to_df(info)
  v$f    <- as.character( v$f )
  v$f[ is.na(v$f) | trimws(v$f) == "" ] <- "NA"
  v$Freq <- as.numeric( as.character( v$Freq ) )

  if( nzchar(trimws(LABEL)) ) cat( paste0( "**", LABEL, "**", ": ", "\n\n" ) )

  # sorting (desc, NA last), colours and the count/share labels all live in
  # booleplot(); here we just hand it a named count vector.
  booleplot( stats::setNames( v$Freq, v$f ) )

  cat( "\n\n" )
}
