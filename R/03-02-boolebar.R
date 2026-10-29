###############################################################################
### Boolean graphic: one bar, split into its categories
###############################################################################
# An alternative to booleplot()'s stack of bars (R/03-02-booleplot.R). The
# whole variable is ONE bar at full width, divided into TRUE / FALSE / NA
# parts: the categories read as shares of a whole rather than as separate
# lengths, which is what a boolean actually is. It is also a third of the
# height, which is why the compact guide draws its booleans this way.
#
#   TRUE                         FALSE        NA        <- labels above
#   [ 412 (68.3%) | 174 (28.9%) | 17 (2.8%) ]           <- the bar
#   |    |    |    |    |    |    |    |    |    |      <- tenth ticks
#   0   10   20   30   40   50   60   70   80   90  100 <- reference scale
#
# The ticks are the reason the bar beats the stack at conveying 100%: without
# a scale a single bar says only "these are the parts", with one it says where
# each part sits in the whole.

# Fills, left to right: three light tints of the report's slate, each a step
# paler than the last. Light on purpose -- the bar is a quiet backdrop for the
# orange counts printed on it, not a block of colour competing with them.
.boolebar_fills <- c( "#A9BDD1", "#C9D6E1", "#E8EDF2" )

# The report's body font stack (see datagoodr.css), minus the web-only first
# choice when it is not installed. Base graphics draw with whatever the device
# can resolve, so the chart text matches the surrounding HTML only if we ask
# for the same family the page falls back to.
.report_family <- function() {
  want <- c( "Source Sans 3", "Segoe UI", "Helvetica", "Arial" )
  if( ! requireNamespace( "systemfonts", quietly = TRUE ) ) return( "" )
  have <- try( systemfonts::system_fonts()$family, silent = TRUE )
  if( inherits( have, "try-error" ) ) return( "" )
  found <- want[ want %in% have ]
  if( length(found) ) found[1] else ""
}

# Make a family name usable by the device that is actually drawing.
#
# The Windows device looks a family up in the windowsFonts() table rather than
# by name, so an unregistered "Segoe UI" warns -- "font family not found in
# Windows font database" -- once per text call. Under knitr those warnings are
# printed into the report, which is how this surfaced: the chart was fine
# standalone and the rendered guide had eight warning blocks above it.
.register_family <- function( family ) {
  if( ! nzchar(family) ) return( "" )
  if( .Platform$OS.type != "windows" ) return( family )
  ok <- tryCatch( {
          args <- stats::setNames( list( grDevices::windowsFont(family) ),
                                   "datagoodr" )
          do.call( grDevices::windowsFonts, args )
          TRUE
        }, error = function(e) FALSE, warning = function(w) FALSE )
  if( ok ) "datagoodr" else ""
}

# Registration says the name is mapped, not that the device can draw it, so
# ask the device: measure a character and watch for the font warning. Returns
# the family to use -- the one asked for, or none.
.family_or_default <- function( family ) {
  if( ! nzchar(family) ) return( "" )
  ok <- TRUE
  withCallingHandlers(
    graphics::strwidth( "M", family = family ),
    warning = function(w) {
      if( grepl( "font", conditionMessage(w), ignore.case = TRUE ) ) ok <<- FALSE
      invokeRestart( "muffleWarning" )
    } )
  if( ok ) family else ""
}

# Which labels mean "missing" and which mean "true". A DGF stores whatever the
# data said (`TRUE`/`FALSE`, but equally `yes`/`no`), so both are matched on
# the stored text rather than assumed.
.bool_is_na   <- function( x ) toupper( trimws(x) ) %in% c( "NA", "", "N/A", "<NA>" )
.bool_is_true <- function( x ) toupper( trimws(x) ) %in% c( "TRUE", "T", "YES", "Y", "1" )


#' Order a boolean variable's categories for display
#'
#' True-ish first, missing last, anything else by frequency in between, so the
#' same category sits in the same place in every bar of a guide.
#'
#' @param labels Character vector of category labels.
#' @param values Their counts.
#'
#' @return An integer ordering vector.
#' @noRd
.boolebar_order <- function( labels, values ) {
  order( .bool_is_na(labels), ! .bool_is_true(labels), -values )
}


#' Draw a boolean variable as one divided bar
#'
#' Draws a single full-width horizontal bar split into one part per category,
#' with the count and share inside each part, the category labels above, and a
#' tenths scale beneath. Unlike [booleplot()], which gives each category its
#' own bar, the parts here share one length, so they read as shares of the
#' whole.
#'
#' @param x A named numeric vector of counts (names are the category labels),
#'   already in display order --- see [paste_boolebar()], which orders them.
#' @param fills Fill colours, applied left to right. Defaults to three light
#'   tints of the report's slate, each a step paler than the last.
#' @param value_col Colour of the counts printed on the bar: the report's
#'   accent orange, which carries against every tint and so can be set smaller
#'   than the labels above it.
#' @param bar_border Outline around the whole bar. The tints are pale enough
#'   that without it the bar has no edge against the page.
#' @param na_border Outline for a missing-value part, the palest of the three.
#' @param tick_col,axis_col Colours for the tenth ticks and their numbers.
#' @param label_col Colour of the category labels above the bar.
#' @param family Font family for every label on the plot. Defaults to the
#'   first of the report's own body stack that is installed, so the chart text
#'   matches the surrounding page; falls back to the device default.
#' @param inset Fraction of the figure width left empty at each side, so the
#'   bar does not run edge to edge. Defaults to `0.10`.
#' @param cex.label,cex.value,cex.axis Text sizes for the category labels, the
#'   in-bar counts, and the scale numbers.
#' @param mar Plot margins, in lines. The defaults leave room for the labels
#'   above and the scale below and nothing else --- the bar itself runs the
#'   full width of the figure.
#'
#' @return No return value; draws the bar on the active device.
#'
#' @details A part too narrow for `12 (2.8%)` is labelled with just its share,
#'   and one too narrow even for that is left unlabelled rather than drawn
#'   with text spilling over its neighbours. The same test governs the labels
#'   above the bar.
#'
#' @seealso [booleplot()], the stacked-bar form the default guide uses.
#' @examples
#' boolebar(c(`TRUE` = 412, `FALSE` = 174, `NA` = 17))
#' @export
boolebar <- function( x,
                      fills      = .boolebar_fills,
                      value_col  = "#A5450F",
                      bar_border = "#8FA5BA",
                      na_border  = "#6E8498",
                      tick_col   = "#C3C8CF",
                      axis_col   = "#9AA3AC",
                      label_col  = "#2B3339",
                      family     = .report_family(),
                      inset      = 0.10,
                      cex.label  = 1.15,
                      cex.value  = 0.85,
                      cex.axis   = 0.85,
                      mar        = c( 1.9, 0.3, 1.4, 0.3 ) ) {

  values <- as.numeric( x )
  labels <- names( x )
  if( is.null(labels) ) labels <- as.character( seq_along(values) )

  if( ! length(values) )          stop( "`x` must contain at least one value." )
  if( any( ! is.finite(values) ) ) stop( "All values in `x` must be finite." )
  if( any( values < 0 ) )         stop( "`x` must be nonnegative." )

  total <- sum( values )
  if( total <= 0 ) stop( "`x` must contain at least one nonzero count." )

  # Drop empty categories: a zero-width part cannot be drawn or labelled, and
  # leaving it in only costs a colour.
  keep   <- values > 0
  values <- values[keep]; labels <- labels[keep]

  pct   <- values / total * 100
  right <- cumsum( pct )
  left  <- right - pct
  mid   <- ( left + right ) / 2

  is.na.part <- .bool_is_na( labels )
  fill   <- rep( fills, length.out = length(values) )
  # the missing part keeps the palest tint wherever it lands in the order
  fill[ is.na.part ] <- fills[ length(fills) ]
  # One orange for every part: the tints are all light, so the accent carries
  # on each of them, and it carries at a smaller size than plain ink would.
  border <- ifelse( is.na.part, na_border, "#FFFFFF" )

  # Save and restore only what we set: snapshotting the whole par list and
  # putting it back fails on a short device (see booleplot()).
  family  <- .register_family( family )
  old_par <- graphics::par( mar = mar, xpd = NA, family = "" )
  on.exit( graphics::par(old_par) )

  graphics::plot.new()
  # The bar still spans 0-100 in data units -- it is a percentage -- but the
  # window is widened so it occupies only the middle (1 - 2 * inset) of the
  # figure. Running edge to edge made it read as a page rule rather than a
  # measured quantity.
  inset <- min( max( inset, 0 ), 0.45 )
  pad   <- 100 * inset / ( 1 - 2 * inset )
  graphics::plot.window( xlim = c( -pad, 100 + pad ), ylim = c(0, 1),
                         xaxs = "i", yaxs = "i" )

  # Only now is there a device to ask whether it can actually draw the family.
  graphics::par( family = .family_or_default( family ) )

  y0 <- 0.40; y1 <- 0.86                      # the bar
  graphics::rect( left, y0, right, y1, col = fill, border = border, lwd = 1.2 )
  # The tints are pale enough that the bar needs an edge to sit against white,
  # and the palest part (missing) would otherwise have no shape at all.
  graphics::rect( 0, y0, 100, y1, col = NA, border = bar_border, lwd = 1 )

  # Text only where it fits. strwidth() is in user units, and the x axis IS
  # percent, so a width compares directly against a part's share.
  fits <- function( txt, i, cex, pad = 1.6 )
    graphics::strwidth( txt, cex = cex ) + pad < pct[i]

  count.txt <- paste0( abbrev_num( values ), " (",
                       formatC( pct, format = "f", digits = 1 ), "%)" )
  short.txt <- paste0( formatC( pct, format = "f", digits = 0 ), "%" )

  inside <- rep( NA_character_, length(pct) )
  for( i in seq_along(pct) ) {
    inside[i] <- if( fits( count.txt[i], i, cex.value ) ) count.txt[i]
                 else if( fits( short.txt[i], i, cex.value ) ) short.txt[i]
                 else NA_character_
    if( ! is.na( inside[i] ) )
      graphics::text( mid[i], ( y0 + y1 ) / 2, inside[i], cex = cex.value,
                      col = value_col, font = 2 )
  }

  # The row above the bar. A part wide enough to hold its own count is named
  # there; a sliver that could not be labelled inside carries its count up
  # here instead, so a 0.1% missing part still says what it is -- the whole
  # point of drawing NA at all.
  above <- ifelse( is.na(inside), paste( labels, count.txt ), labels )
  w     <- graphics::strwidth( above, cex = cex.label )
  x     <- pmax( mid - w / 2, 0 )                   # preferred left edge

  # Lay them out left to right, each clear of the one before.
  n <- length(x)
  for( i in seq_len(n)[-1] )
  { x[i] <- max( x[i], x[i - 1] + w[i - 1] + 1.5 ) }

  # If that ran the last one off the right edge, pack back from the right
  # instead. Parts at the end of a bar are the small ones -- the missing
  # category above all -- and pushing their labels off is exactly the case
  # worth handling.
  if( x[n] + w[n] > 100 ) {
    x[n] <- 100 - w[n]
    for( i in rev( seq_len(n - 1) ) )
    { x[i] <- min( x[i], x[i + 1] - w[i] - 1.5 ) }
    x <- pmax( x, 0 )
  }

  # Only drop a label when the labels genuinely cannot all fit on the line.
  show <- rep( TRUE, n )
  for( i in seq_len(n)[-1] )
  { if( x[i] < x[i - 1] + w[i - 1] + 0.8 ) show[i] <- FALSE }

  if( any(show) ) {
    # A label shifted clear of its neighbours no longer sits over its part, so
    # point it back at one: a hairline from the label down to the part's top.
    centre <- x + w / 2
    far    <- show & abs( centre - mid ) > 3
    if( any(far) )
      graphics::segments( centre[far], y1 + 0.055, mid[far], y1 + 0.005,
                          col = tick_col, lwd = 0.9 )
    graphics::text( x[show], y1 + 0.07, above[show], adj = c( 0, 0 ),
                    cex = cex.label, font = 2, col = label_col )
  }

  # Tenths: the reference that turns "these are the parts" into "and this is
  # where they sit in the whole".
  at <- seq( 0, 100, by = 10 )
  graphics::segments( at, y0 - 0.04, at, y0 - 0.19, col = tick_col, lwd = 1.1 )

  # All centred on their tick: the inset leaves room for 0 and 100 to sit
  # under theirs without the device edge clipping them.
  graphics::text( at, y0 - 0.24, format( at ), adj = c( 0.5, 1 ),
                  cex = cex.axis, col = axis_col )

  invisible( NULL )
}


#' Print a boolean variable's divided bar into the RG
#'
#' Reads the `rg_graphics` column of the DGF and draws the category counts
#' with [boolebar()]: one full-width bar split into TRUE / FALSE / NA parts,
#' each carrying its count and share, over a tenths scale. The compact guide's
#' boolean graphic; the default guide uses [paste_booleplot()].
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"rg_graphics"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"VALUES"`.
#'
#' @return No return value; draws the bar into the RG.
#' @seealso [paste_booleplot()], [boolebar()]
#' @export
paste_boolebar <- function( VNAME, LABEL = "VALUES" ) {

  info <- get_xx()[[VNAME]]
  v <- json_to_df( info )
  v$f    <- as.character( v$f )
  v$f[ is.na(v$f) | trimws(v$f) == "" ] <- "NA"
  v$Freq <- as.numeric( as.character( v$Freq ) )

  if( nzchar( trimws(LABEL) ) ) cat( paste0( "**", LABEL, "**", ": ", "\n\n" ) )

  # Order on the stored codes -- TRUE / yes / 1 is recognised there, not in a
  # curated label like "1 (straight)" -- then show the curated labels.
  i <- .boolebar_order( v$f, v$Freq )
  boolebar( stats::setNames( v$Freq[i], .level_labels( v$f[i] ) ) )

  cat( "\n\n" )
}
