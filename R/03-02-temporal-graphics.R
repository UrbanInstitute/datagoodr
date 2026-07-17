# Render a temporal variable's graphic. The build step stored a unit-agnostic
# value->count table in rg_graphics (get_graphics_temporal); which chart to draw
# is chosen HERE, at render, from stable_data_unit. So a user can retype the
# unit in the DGF and re-render without rebuilding:
#
#   date         -> calendar heatmap        (calendar_heat)
#   hour / week  -> connected scatterplot   (the crash-by-hour / by-week form)
#   dow / month  -> barchart
#   year         -> histogram if the span is wide (> 25), else a barchart
#   (blank/other)-> barchart  (the safe default)


#' Draw the temporal graphic for the current variable (internal)
#'
#' Reads the value/count table from `rg_graphics` and the unit from
#' `stable_data_unit`, and draws the unit-appropriate chart. Call inside a
#' `results = "asis"` chunk; the plot is captured by knitr.
#'
#' @param VNAME Character; the DGF column to read (the layout passes
#'   `"rg_graphics"`).
#' @param LABEL Optional section label.
#'
#' @return No return value; draws a plot.
#' @noRd
paste_temporal_graphic <- function( VNAME, LABEL = "" ) {

  info <- get_xx()[[VNAME]]
  if( is.null(info) || all(is.na(info)) || ! nzchar( trimws(as.character(info)) ) )
  { return( invisible(NULL) ) }

  tab <- json_to_df( info )
  if( nrow(tab) == 0 ) return( invisible(NULL) )
  val <- as.character( tab$Value )
  cnt <- suppressWarnings( as.numeric( as.character( tab$Count ) ) )

  unit <- tolower( trimws( as.character( get_xx()[["stable_data_unit"]] ) ) )
  if( length(unit) == 0 || is.na(unit) ) unit <- ""

  if( nzchar( trimws(LABEL) ) ) cat( "**", LABEL, "**:\n\n", sep = "" )

  # --- date: calendar heatmap (falls back to a bar if values aren't dates) ---
  if( unit == "date" ) {
    d <- suppressWarnings( as.Date( val ) )
    if( mean( !is.na(d) ) >= 0.8 ) {
      calendar_heat( d[!is.na(d)], cnt[!is.na(d)], varname = "" )
      return( invisible(NULL) )
    }
    # not real dates -> fall through to the default bar
    unit <- ""
  }

  # --- hour / week: connected scatterplot -----------------------------------
  if( unit %in% c("hour", "week") ) {
    xn <- suppressWarnings( as.numeric(val) )
    if( any( !is.na(xn) ) ) {   # values really are numeric hours/weeks
      keep <- !is.na(xn)
      o <- order( xn[keep] )
      xlab <- if( unit == "hour" ) "Hour of the Day" else "Week"
      plot( xn[keep][o], cnt[keep][o], pch = 19, type = "b", cex = 2, bty = "n",
            xlab = xlab, ylab = "Count" )
      return( invisible(NULL) )
    }
    unit <- ""   # not numeric -> fall through to the default bar
  }

  # --- day-of-week / month: barchart, ordered ------------------------------
  if( unit %in% c("dow", "dayofweek", "weekday", "month") ) {
    ord <- temporal_order( val, unit )
    graphics::barplot( cnt[ord], names.arg = val[ord], las = 2, border = NA )
    return( invisible(NULL) )
  }

  # --- year: histogram when the span is wide, else a barchart ---------------
  if( unit == "year" ) {
    yn <- suppressWarnings( as.numeric(val) )
    if( length(yn) > 1 && diff(range(yn, na.rm = TRUE)) > 25 ) {
      graphics::hist( rep(yn, cnt), breaks = 30, main = "", xlab = "Year",
                      col = "grey80", border = "white" )
    } else {
      o <- order(yn)
      graphics::barplot( cnt[o], names.arg = val[o], las = 2, border = NA )
    }
    return( invisible(NULL) )
  }

  # --- default: barchart of value -> count ----------------------------------
  o <- order( suppressWarnings(as.numeric(val)), val )
  graphics::barplot( cnt[o], names.arg = val[o], las = 2, border = NA )
  invisible( NULL )
}


#' Order temporal category labels sensibly (internal)
#'
#' @param val Character labels.
#' @param unit `"month"` or a day-of-week unit.
#' @return An ordering index putting Jan..Dec / Sun..Sat in calendar order,
#'   falling back to natural sort.
#' @noRd
temporal_order <- function( val, unit ) {
  v <- tolower( substr( trimws(val), 1, 3 ) )
  months <- c("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec")
  days   <- c("sun","mon","tue","wed","thu","fri","sat")
  key <- if( unit == "month" ) match( v, months ) else match( v, days )
  if( all( !is.na(key) ) ) return( order(key) )
  # numeric months (1-12) or unrecognised: natural order
  order( suppressWarnings(as.numeric(val)), val )
}
