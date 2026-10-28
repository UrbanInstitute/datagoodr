# Render a temporal variable's graphic. The build step stored a unit-agnostic
# value->count table in rg_graphics (get_graphics_temporal); which chart to draw
# is chosen HERE, at render, from stable_data_unit. So a user can retype the
# unit in the DGF and re-render without rebuilding:
#
#   date         -> calendar heatmap        (calendar_heat; one row per year.
#                   Spans > 3 years: options(datagoodr.calendar =) "top3"
#                   (default), "spread", or "fold")
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
#' @param calendar For dates spanning more than three calendar years: `"top3"`
#'   (the three most populated years, in order), `"spread"` (a random early,
#'   middle and late year), or `"fold"` (all years on one calendar). Defaults
#'   to `getOption("datagoodr.calendar", "top3")`, so a project can set it once
#'   in `DG.R`.
#'
#' @return No return value; draws a plot.
#' @noRd
paste_temporal_graphic <- function( VNAME, LABEL = "",
                                    calendar = getOption( "datagoodr.calendar", "top3" ) ) {

  info <- get_xx()[[VNAME]]
  if( is.null(info) || all(is.na(info)) || ! nzchar( trimws(as.character(info)) ) )
  { return( invisible(NULL) ) }

  tab <- json_to_df( info )
  if( nrow(tab) == 0 ) return( invisible(NULL) )
  val <- as.character( tab$Value )
  cnt <- suppressWarnings( as.numeric( as.character( tab$Count ) ) )

  # The render grain (date/hour/week/dow/month/year) comes from
  # desired_semantic_type (year, month, day_of_week, calendar, ...). A bare data
  # type there ("temporal") names no grain, so a DGF built before the v7 columns
  # falls back to its legacy desired_data_class (period.month, ...).
  xx  <- get_xx()
  pick <- function( nm ) {
    if( ! nm %in% names(xx) ) return( "" )
    v <- as.character( xx[[nm]] )
    if( ! length(v) || is.na(v) ) "" else trimws(v)
  }
  sem  <- .sem_leaf( pick( "desired_semantic_type" ) )   # path -> leaf
  cs   <- pick( "desired_data_class" )
  unit <- if( nzchar(sem) && ! sem %in% c(.render_types, "string") )
            .temporal_grain( paste0( "x.", sem ) )
          else if( nzchar(cs) ) .temporal_grain( cs )
          else ""

  if( nzchar( trimws(LABEL) ) ) cat( "**", LABEL, "**:\n\n", sep = "" )

  # --- date: calendar heatmap (falls back to a bar if values aren't dates) ---
  # Up to 3 calendar years: the daily calendar heatmap, one row per year.
  # Longer spans, by `calendar` (default from options(datagoodr.calendar)):
  #   "top3"   - the three years with the most observations, in year order
  #   "spread" - one year drawn at random from each of the early, middle and
  #              late thirds of the populated years (repeatable per variable)
  #   "fold"   - every year folded onto one calendar: each cell is the total
  #              for that month and day (on leap year 2000, so Feb 29 has a
  #              cell); weekday names hidden, panel titled with the year range
  if( unit == "date" ) {
    d <- parse_dates( val )
    if( mean( !is.na(d) ) >= 0.8 ) {
      ok <- !is.na(d)
      dd <- d[ok]; cc <- cnt[ok]
      yr <- as.integer( format( dd, "%Y" ) )
      mode <- .calendar_mode( calendar )
      # cap both tails of the colour scale (see calendar_heat's `winsor`);
      # NULL turns it off
      w <- getOption( "datagoodr.calendar.winsor", c( 0.05, 0.95 ) )
      if( diff( range(yr) ) + 1 <= 3 ) {
        calendar_heat( dd, cc, varname = "", color = "w2g2b", winsor = w )
      } else if( mode %in% c("top3", "spread") ) {
        by.yr    <- tapply( cc, yr, sum )
        show.yrs <- .pick_calendar_years( by.yr, mode, key = pick( "VNAME" ) )
        keep     <- yr %in% show.yrs
        calendar_heat( dd[keep], cc[keep], varname = "", color = "w2g2b",
                       years = show.yrs, winsor = w )
      } else {
        md  <- format( dd, "%m-%d" )
        agg <- tapply( cc, md, sum )
        calendar_heat( as.Date( paste0( "2000-", names(agg) ) ), as.numeric(agg),
                       varname = "", color = "w2g2b", weekday.labels = FALSE,
                       winsor = w,
                       year.label = paste0( min(yr), "-", max(yr),
                                            ", all years by month and day" ) )
      }
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


## Validate the calendar mode; an unknown value falls back to "top3".
#' @noRd
.calendar_mode <- function( calendar ) {
  modes <- c( "top3", "spread", "fold" )
  calendar <- as.character( calendar )[1]
  if( is.na(calendar) || ! calendar %in% modes ) {
    warning( "Unknown calendar mode '", calendar, "'; using \"top3\". ",
             "Choose one of: ", paste( modes, collapse = ", " ), ".", call. = FALSE )
    return( "top3" )
  }
  calendar
}


#' Choose which years a long date span shows as calendars (internal)
#'
#' @param by.yr Named numeric: observations per year (names are years).
#' @param mode `"top3"` or `"spread"`.
#' @param key A string (the variable name) that seeds the random pick, so a
#'   re-render shows the same years. The global random state is left as it was.
#' @return Up to three years, ascending.
#' @noRd
.pick_calendar_years <- function( by.yr, mode = c("top3", "spread"), key = "" ) {
  mode  <- match.arg( mode )
  by.yr <- by.yr[ ! is.na(by.yr) & by.yr > 0 ]
  years <- sort( as.integer( names(by.yr) ) )
  if( length(years) <= 3 ) return( years )

  if( mode == "top3" ) {
    top <- names( sort( by.yr, decreasing = TRUE ) )[ 1:3 ]
    return( sort( as.integer(top) ) )
  }

  # spread: one year from each third of the populated years
  had.seed <- exists( ".Random.seed", envir = globalenv(), inherits = FALSE )
  if( had.seed ) old.seed <- get( ".Random.seed", envir = globalenv() )
  on.exit( if( had.seed ) assign( ".Random.seed", old.seed, envir = globalenv() )
           else rm( ".Random.seed", envir = globalenv() ) )
  set.seed( sum( utf8ToInt( paste0( "dg-calendar-", key ) ) ) )
  third <- cut( seq_along(years), 3, labels = FALSE )
  sort( vapply( split( years, third ),
                function( y ) if( length(y) == 1 ) y else sample( y, 1 ),
                integer(1) ) )
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
                # written-out months: "Dec 27, 1981", "December 27, 1981",
                # "27 Dec 1981", "27-Dec-1981"
                "%b %d, %Y", "%B %d, %Y", "%b %d %Y", "%d %b %Y", "%d-%b-%Y",
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
