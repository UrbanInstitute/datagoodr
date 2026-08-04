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

  # The render grain (date/hour/week/dow/month/year) now travels in
  # desired_data_class (period.month, phase.day_of_week, ...); derive it there
  # instead of from a separate unit column.
  cs   <- as.character( get_xx()[["desired_data_class"]] )
  unit <- if( length(cs) && ! is.na(cs) && nzchar(trimws(cs)) )
            .temporal_grain( cs ) else ""

  if( nzchar( trimws(LABEL) ) ) cat( "**", LABEL, "**:\n\n", sep = "" )

  # --- date: calendar heatmap (falls back to a bar if values aren't dates) ---
  if( unit == "date" ) {
    d <- parse_dates( val )
    if( mean( !is.na(d) ) >= 0.8 ) {
      ok <- !is.na(d)
      dd <- d[ok]; cc <- cnt[ok]
      # Keep only the two calendar years holding the most observations so the
      # heatmap fills its space instead of stretching across many sparse years.
      yr    <- as.integer( format( dd, "%Y" ) )
      by.yr <- tapply( cc, yr, sum )
      top2  <- as.integer( names( sort( by.yr, decreasing = TRUE ) ) )
      top2  <- top2[ seq_len( min(2, length(top2)) ) ]
      keep2 <- yr %in% top2
      calendar_heat( dd[keep2], cc[keep2], varname = "" )
      return( invisible(NULL) )
    }
    # not real dates -> fall through to the default bar
    unit <- ""
  }

  # --- hour / week: connected scatterplot -----------------------------------
  # The stored table is raw value -> count; aggregate to the hour/week bucket so
  # the scatter is count-by-hour (0-23) or count-by-week (1-52).
  if( unit %in% c("hour", "week") ) {
    bucket <- if( unit == "hour" ) parse_hour(val) else parse_week(val)
    if( any( !is.na(bucket) ) ) {
      keep <- !is.na(bucket)
      agg  <- tapply( cnt[keep], bucket[keep], sum )
      xn   <- as.numeric( names(agg) )
      o    <- order( xn )
      xlab <- if( unit == "hour" ) "Hour of the Day" else "Week"
      plot( xn[o], as.numeric(agg)[o], pch = 19, type = "b", cex = 2, bty = "n",
            xlab = xlab, ylab = "", yaxt = "n" )
      return( invisible(NULL) )
    }
    unit <- ""   # couldn't parse -> fall through to the default bar
  }

  # --- day-of-week / month: barchart, ordered ------------------------------
  # (axes = FALSE drops the count/frequency y-axis ticks and labels)
  if( unit %in% c("dow", "dayofweek", "weekday", "month") ) {
    ord <- temporal_order( val, unit )
    graphics::barplot( cnt[ord], names.arg = val[ord], las = 2, border = NA,
                       axes = FALSE, ylab = "" )
    return( invisible(NULL) )
  }

  # --- year: histogram when the span is wide, else a barchart ---------------
  if( unit == "year" ) {
    yn <- suppressWarnings( as.numeric(val) )
    if( length(yn) > 1 && diff(range(yn, na.rm = TRUE)) > 25 ) {
      graphics::hist( rep(yn, cnt), breaks = 30, main = "", xlab = "Year",
                      col = "grey80", border = "white", ylab = "", yaxt = "n" )
    } else {
      o <- order(yn)
      graphics::barplot( cnt[o], names.arg = val[o], las = 2, border = NA,
                         axes = FALSE, ylab = "" )
    }
    return( invisible(NULL) )
  }

  # --- default: barchart of value -> count ----------------------------------
  o <- order( suppressWarnings(as.numeric(val)), val )
  graphics::barplot( cnt[o], names.arg = val[o], las = 2, border = NA,
                     axes = FALSE, ylab = "" )
  invisible( NULL )
}


#' Extract the hour-of-day (0-23) from clock-ish values (internal)
#'
#' @param val Character times: `"8:13am"`, `"2:54pm"`, `"14:30"`, `"08:13:00"`,
#'   or a bare hour `"14"`.
#' @return Integer hours 0-23, `NA` where unparseable.
#' @noRd
parse_hour <- function( val ) {
  v <- tolower( trimws( as.character(val) ) )
  h <- suppressWarnings( as.integer( sub( "^\\s*(\\d{1,2}).*$", "\\1", v ) ) )
  pm <- grepl( "pm", v ); am <- grepl( "am", v )
  h[ pm & h < 12 ] <- h[ pm & h < 12 ] + 12   # 1pm -> 13
  h[ am & h == 12 ] <- 0                        # 12am -> 0
  h[ h < 0 | h > 23 ] <- NA
  h
}


#' Extract the week-of-year (1-53) from values (internal)
#'
#' @param val Character weeks (`"1".."52"`) or dates.
#' @return Numeric weeks, `NA` where unparseable.
#' @noRd
parse_week <- function( val ) {
  w <- suppressWarnings( as.numeric( as.character(val) ) )
  if( any( !is.na(w) & w >= 1 & w <= 53 ) ) return( ifelse( w >= 1 & w <= 53, w, NA ) )
  d <- parse_dates( val )                       # dates -> week of year
  suppressWarnings( as.numeric( format( d, "%U" ) ) + 1 )
}


#' Parse a character vector of dates, trying several formats (internal)
#'
#' @param val Character dates.
#' @return A `Date` vector; unparseable elements are `NA`. Handles ISO,
#'   `m-d-Y`/`d-m-Y`, and the 2-digit-year variants a messy extract carries.
#' @noRd
parse_dates <- function( val ) {
  val <- as.character( val )
  formats <- c( "%Y-%m-%d", "%Y/%m/%d",
                "%m-%d-%Y", "%d-%m-%Y", "%m/%d/%Y", "%d/%m/%Y",
                "%m-%d-%y", "%d-%m-%y", "%m/%d/%y", "%d/%m/%y" )
  out <- rep( as.Date(NA), length(val) )
  for( fmt in formats ) {
    need <- is.na( out )
    if( ! any(need) ) break
    got <- suppressWarnings( as.Date( val[need], format = fmt ) )
    # Reject implausible years so a wrong format is not mistaken for a match:
    # "14-07-16" under "%Y-%m-%d" parses as the year 14, which would blow up the
    # calendar's date sequence. Keep the loop trying later formats instead.
    yr  <- as.numeric( format( got, "%Y" ) )
    got[ !is.na(yr) & (yr < 1900 | yr > 2100) ] <- NA
    out[ which(need)[ !is.na(got) ] ] <- got[ !is.na(got) ]
  }
  out
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
