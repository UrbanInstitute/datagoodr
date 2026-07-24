# ---------------------------------------------------------------------------
#  Calendar Heatmap
#  by Paul Bleicher
#
#  An R version of a graphic from:
#    http://stat-computing.org/dataexpo/2009/posters/wicklin-allison.pdf
#
#  calendarHeat: an R function to display time-series data as a calendar heatmap.
#  Copyright 2009 Humedica. All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify it under
#  the terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details:
#  http://www.gnu.org/licenses/gpl-2.0.html
#
#  Vendored into datagoodr (GPL >= 3, compatible with the GPL-2-or-later grant
#  above) as the `temporal` type's date graphic. Changes from the original:
#    - dropped the unused `require(chron)` (no chron function is called);
#    - replaced require() with a need_pkg() guard on lattice/grid;
#    - fixed the fragile `class(x) == "character"` test to is.character/is.factor,
#      which is correct for multi-class objects.
#  The algorithm is otherwise verbatim.
# ---------------------------------------------------------------------------


#' Calendar heatmap of daily values
#'
#' Displays a date-indexed series as a calendar heatmap - one cell per day, laid
#' out in the familiar month-by-weekday grid, coloured by value. Used as the
#' `temporal` type's graphic for full dates.
#'
#' @param dates A vector of dates (Date, or character/factor parseable by
#'   `date.form`).
#' @param values Numeric values, one per date.
#' @param ncolors Number of colour steps. Defaults to 99.
#' @param color A colour ramp name: `"r2g"`, `"r2b"`, `"b2r"`, `"w2b"`, `"b2w"`,
#'   `"r2w"`. Defaults to `"r2g"`.
#' @param varname Title label for the plotted quantity.
#' @param date.form `strptime` format for parsing character dates. Defaults to
#'   `"%Y-%m-%d"`.
#' @param ... Unused; accepted for compatibility.
#'
#' @return No return value; draws the plot on the current device.
#'
#' @section Provenance:
#' Ported from Paul Bleicher's `calendarHeat` (Copyright 2009 Humedica, GPL-2 or
#' later), itself an R version of a SAS calendar graphic by Wicklin & Allison
#' (Data Expo 2009). See the file header for the full notice.
#'
#' @seealso the type ontology's `temporal` rows.
#' @noRd
calendar_heat <-
  function( dates,
            values,
            ncolors = 99,
            color = "r2g",
            varname = "Values",
            date.form = "%Y-%m-%d", ... ) {

  need_pkg( "lattice", "grid" )

  if( is.character(dates) || is.factor(dates) ) {
    dates <- strptime( as.character(dates), date.form )
  }
  caldat <- data.frame( value = values, dates = dates )
  min.date <- as.Date( paste( format( min(dates), "%Y" ), "-1-1",  sep = "" ) )
  max.date <- as.Date( paste( format( max(dates), "%Y" ), "-12-31", sep = "" ) )
  dates.f  <- data.frame( date.seq = seq( min.date, max.date, by = "days" ) )

  # Merge moves data by one day, avoid
  caldat <- data.frame( date.seq = seq( min.date, max.date, by = "days" ), value = NA )
  dates <- as.Date( dates )
  caldat$value[ match( dates, caldat$date.seq ) ] <- values

  caldat$dotw  <- as.numeric( format( caldat$date.seq, "%w" ) )
  caldat$woty  <- as.numeric( format( caldat$date.seq, "%U" ) ) + 1
  caldat$yr    <- as.factor( format( caldat$date.seq, "%Y" ) )
  caldat$month <- as.numeric( format( caldat$date.seq, "%m" ) )
  yrs   <- as.character( unique( caldat$yr ) )
  d.loc <- as.numeric()
  for( m in min(yrs):max(yrs) ) {
    d.subset <- which( caldat$yr == m )
    sub.seq  <- seq( 1, length(d.subset) )
    d.loc    <- c( d.loc, sub.seq )
  }
  caldat <- cbind( caldat, seq = d.loc )

  # colour styles
  r2w <- grDevices::colorRampPalette( c("gray40", "firebrick") )(5)
  r2g <- c( "#D61818", "#FFAE63", "#FFFFBD", "#B5E384" )   # red to green
  w2b <- c( "#045A8D", "#2B8CBE", "#74A9CF", "#BDC9E1", "#F1EEF6" )   # white to blue
  b2w <- c( "#B3B3B3", "#879CA9", "#5B86A0", "#2F7096", "#045A8D" )   # blue to white
  r2b <- grDevices::colorRampPalette( c("#045A8D", "gray70", "firebrick") )(5)
  b2r <- grDevices::colorRampPalette( c("firebrick", "gray70", "#045A8D") )(5)

  assign( "col.sty", get(color) )
  calendar.pal <- grDevices::colorRampPalette( (col.sty), space = "Lab" )
  def.theme <- lattice::lattice.getOption( "default.theme" )
  cal.theme <-
    function() {
      theme <-
        list(
          strip.background = list( col = "transparent" ),
          strip.border     = list( col = "transparent" ),
          axis.line        = list( col = "transparent" ),
          par.strip.text   = list( cex = 0.8 ) )
    }
  lattice::lattice.options( default.theme = cal.theme )
  yrs <- ( unique( caldat$yr ) )
  nyr <- length( yrs )
  print( cal.plot <- lattice::levelplot( value ~ woty * dotw | yr, data = caldat,
    as.table = TRUE,
    aspect   = .12,
    layout   = c( 1, nyr %% 7 ),
    between  = list( x = 0, y = c(1, 1) ),
    strip    = TRUE,
    main = NULL,
    scales = list(
      x = list(
        at = c( seq( 2.9, 52, by = 4.42 ) ),
        labels = month.abb,
        alternating = c( 1, rep(0, (nyr - 1)) ),
        tck = 0,
        cex = 0.7 ),
      y = list(
        at = c( 0, 1, 2, 3, 4, 5, 6 ),
        labels = c( "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday",
                    "Friday", "Saturday" ),
        alternating = 1,
        cex = 0.6,
        tck = 0 ) ),
    xlim = c( 0.4, 54.6 ),
    ylim = c( 6.6, -0.6 ),
    cuts = ncolors - 1,
    col.regions = ( calendar.pal(ncolors) ),
    xlab = "",
    ylab = "",
    colorkey = FALSE,
    subscripts = TRUE
  ) )
  panel.locs <- lattice::trellis.currentLayout()
  for( row in 1:nrow(panel.locs) ) {
    for( column in 1:ncol(panel.locs) ) {
      if( panel.locs[row, column] > 0 ) {
        lattice::trellis.focus( "panel", row = row, column = column,
          highlight = FALSE )
        xyetc <- lattice::trellis.panelArgs()
        subs  <- caldat[ xyetc$subscripts, ]
        dates.fsubs <- caldat[ caldat$yr == unique(subs$yr), ]
        y.start <- dates.fsubs$dotw[1]
        y.end   <- dates.fsubs$dotw[ nrow(dates.fsubs) ]
        dates.len <- nrow( dates.fsubs )
        adj.start <- dates.fsubs$woty[1]

        for( k in 0:6 ) {
          if( k < y.start ) { x.start <- adj.start + 0.5 } else { x.start <- adj.start - 0.5 }
          if( k > y.end )   { x.finis <- dates.fsubs$woty[ nrow(dates.fsubs) ] - 0.5 }
                       else { x.finis <- dates.fsubs$woty[ nrow(dates.fsubs) ] + 0.5 }
          grid::grid.lines( x = c(x.start, x.finis), y = c(k - 0.5, k - 0.5),
            default.units = "native", gp = grid::gpar( col = "grey", lwd = 1 ) )
        }
        if( adj.start < 2 ) {
          grid::grid.lines( x = c(0.5, 0.5), y = c(6.5, y.start - 0.5),
            default.units = "native", gp = grid::gpar( col = "grey", lwd = 1 ) )
          grid::grid.lines( x = c(1.5, 1.5), y = c(6.5, -0.5), default.units = "native",
            gp = grid::gpar( col = "grey", lwd = 1 ) )
          grid::grid.lines( x = c(x.finis, x.finis),
            y = c(dates.fsubs$dotw[dates.len] - 0.5, -0.5), default.units = "native",
            gp = grid::gpar( col = "grey", lwd = 1 ) )
          if( dates.fsubs$dotw[dates.len] != 6 ) {
            grid::grid.lines( x = c(x.finis + 1, x.finis + 1),
              y = c(dates.fsubs$dotw[dates.len] - 0.5, -0.5), default.units = "native",
              gp = grid::gpar( col = "grey", lwd = 1 ) )
          }
          grid::grid.lines( x = c(x.finis, x.finis),
            y = c(dates.fsubs$dotw[dates.len] - 0.5, -0.5), default.units = "native",
            gp = grid::gpar( col = "grey", lwd = 1 ) )
        }
        for( n in 1:51 ) {
          grid::grid.lines( x = c(n + 1.5, n + 1.5),
            y = c(-0.5, 6.5), default.units = "native", gp = grid::gpar( col = "grey", lwd = 1 ) )
        }
        x.start <- adj.start - 0.5

        if( y.start > 0 ) {
          grid::grid.lines( x = c(x.start, x.start + 1),
            y = c(y.start - 0.5, y.start - 0.5), default.units = "native",
            gp = grid::gpar( col = "black", lwd = 1.75 ) )
          grid::grid.lines( x = c(x.start + 1, x.start + 1),
            y = c(y.start - 0.5, -0.5), default.units = "native",
            gp = grid::gpar( col = "black", lwd = 1.75 ) )
          grid::grid.lines( x = c(x.start, x.start),
            y = c(y.start - 0.5, 6.5), default.units = "native",
            gp = grid::gpar( col = "black", lwd = 1.75 ) )
          if( y.end < 6 ) {
            grid::grid.lines( x = c(x.start + 1, x.finis + 1),
              y = c(-0.5, -0.5), default.units = "native",
              gp = grid::gpar( col = "black", lwd = 1.75 ) )
            grid::grid.lines( x = c(x.start, x.finis),
              y = c(6.5, 6.5), default.units = "native",
              gp = grid::gpar( col = "black", lwd = 1.75 ) )
          } else {
            grid::grid.lines( x = c(x.start + 1, x.finis),
              y = c(-0.5, -0.5), default.units = "native",
              gp = grid::gpar( col = "black", lwd = 1.75 ) )
            grid::grid.lines( x = c(x.start, x.finis),
              y = c(6.5, 6.5), default.units = "native",
              gp = grid::gpar( col = "black", lwd = 1.75 ) )
          }
        } else {
          grid::grid.lines( x = c(x.start, x.start),
            y = c(-0.5, 6.5), default.units = "native",
            gp = grid::gpar( col = "black", lwd = 1.75 ) )
        }

        if( y.start == 0 ) {
          if( y.end < 6 ) {
            grid::grid.lines( x = c(x.start, x.finis + 1),
              y = c(-0.5, -0.5), default.units = "native",
              gp = grid::gpar( col = "black", lwd = 1.75 ) )
            grid::grid.lines( x = c(x.start, x.finis),
              y = c(6.5, 6.5), default.units = "native",
              gp = grid::gpar( col = "black", lwd = 1.75 ) )
          } else {
            grid::grid.lines( x = c(x.start + 1, x.finis),
              y = c(-0.5, -0.5), default.units = "native",
              gp = grid::gpar( col = "black", lwd = 1.75 ) )
            grid::grid.lines( x = c(x.start, x.finis),
              y = c(6.5, 6.5), default.units = "native",
              gp = grid::gpar( col = "black", lwd = 1.75 ) )
          }
        }
        for( j in 1:12 ) {
          last.month <- max( dates.fsubs$seq[ dates.fsubs$month == j ] )
          x.last.m <- dates.fsubs$woty[last.month] + 0.5
          y.last.m <- dates.fsubs$dotw[last.month] + 0.5
          grid::grid.lines( x = c(x.last.m, x.last.m), y = c(-0.5, y.last.m),
            default.units = "native", gp = grid::gpar( col = "black", lwd = 1.75 ) )
          if( (y.last.m) < 6 ) {
            grid::grid.lines( x = c(x.last.m, x.last.m - 1), y = c(y.last.m, y.last.m),
              default.units = "native", gp = grid::gpar( col = "black", lwd = 1.75 ) )
            grid::grid.lines( x = c(x.last.m - 1, x.last.m - 1), y = c(y.last.m, 6.5),
              default.units = "native", gp = grid::gpar( col = "black", lwd = 1.75 ) )
          } else {
            grid::grid.lines( x = c(x.last.m, x.last.m), y = c(-0.5, 6.5),
              default.units = "native", gp = grid::gpar( col = "black", lwd = 1.75 ) )
          }
        }
      }
    }
  }
  lattice::trellis.unfocus()

  lattice::lattice.options( default.theme = def.theme )
}
