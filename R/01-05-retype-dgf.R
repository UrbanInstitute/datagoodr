# Re-profile a DGF after correcting a variable's type.
#
# create_dgf() guesses types roughly (R's type inference is limited), so a user
# opens the DGF and fixes the guesses - a date column mis-read as a string, a
# code mis-read as a number. But the rg_* profile columns were computed from the
# original guess, so a corrected type needs its stats/graphics recomputed.
# retype_dgf() does that recompute, for just the corrected variables, against
# the raw data. It closes the "wrong type -> re-profile" gap the render pipeline
# otherwise leaves to a full rebuild.


# ontology data_type -> the internal build vocabulary get_stats/get_graphics use
.dgf_vclass_of <- function( type ) {
  switch( type,
    number      = "numeric",
    categorical = "factor",
    boolean     = "logical",
    text        = "character",
    string      = "character",   # back-compat alias for pre-rename DGFs
    identifier  = "identifier",
    temporal    = "temporal",
    stop( "Unknown desired_data_type: '", type, "'.", call. = FALSE ) )
}


# Cast the columns named in `types` from text to what each target type's profile
# expects (used when retype_dgf() reads a .csv as text). Columns not named are left
# as text; a column that is not in `data` is skipped (retype_dgf() warns about it).
#' @noRd
.cast_for_types <- function( data, types ) {
  for( v in intersect( names(types), names(data) ) ) {
    data[[v]] <- switch( types[[v]],
      number      = suppressWarnings( as.numeric( data[[v]] ) ),
      categorical = factor( data[[v]] ),
      boolean     = factor( data[[v]] ),
      data[[v]] )                      # text / identifier / temporal stay character
  }
  data
}


#' Correct a variable's type in a DGF and re-profile it
#'
#' `create_dgf()` guesses types roughly; this applies your corrections and
#' recomputes the affected variables' `rg_*` profile columns (stats, graphic,
#' properties, preview) so the report renders them as the corrected type. Use it
#' for the iterative Step-1 -> Step-2 loop: build, correct, re-profile, render.
#'
#' @param dgf A DGF data frame (or a path to a DGF `.xlsx`).
#' @param data The raw dataset the DGF was built from (a data frame, or a path
#'   to a `.csv`). Needed to recompute the profile.
#' @param types A named character vector mapping variable name to the corrected
#'   `desired_data_type` (`"temporal"`, `"identifier"`, `"number"`,
#'   `"categorical"`, `"boolean"`, `"text"`).
#' @param units A named character vector mapping variable name to a temporal
#'   grain (e.g. `c(founded = "year")`), written into `desired_semantic_type` as
#'   the matching temporal semantic type (`year`, `month`, `day_of_week`,
#'   `calendar`, ...) - what the render engine reads to pick the graphic - and
#'   into the legacy `desired_data_class` when present. Temporal only; may name
#'   variables already the right type but needing a grain.
#' @param env Environment for any rule functions (unused today; reserved).
#'
#' @return The DGF with the named variables re-typed, re-united, and re-profiled.
#'
#' @details Only the named variables are touched; everything else is left
#'   verbatim, including any curation. The temporal graphic is chosen at render
#'   from `desired_data_class`, so a units-only change needs no re-profile - but a
#'   type change to `temporal` does, to store the value/count table its graphic
#'   reads.
#'
#' @examples
#' \dontrun{
#' dgf <- create_dgf(raw, file = "DGF")
#' dgf <- retype_dgf(dgf, raw,
#'          types = c(founded = "temporal", county = "identifier"),
#'          units = c(founded = "year"))
#' create_rg(dgf, dir = ".")
#' }
#'
#' @seealso [create_dgf()], [inspect_dgf()]
#' @export
retype_dgf <- function( dgf, data, types = NULL, units = NULL,
                        env = parent.frame() ) {

  if( is.character(dgf) && length(dgf) == 1 ) dgf <- load_dgf( dgf )
  if( is.character(data) && length(data) == 1 ) {
    # Read every column as text, as create_dgf() does (`read_as_text = TRUE`).
    # Letting readr infer types turned "00" into 0 and "06037" into 6037 before the
    # corrected type was ever profiled -- exactly the columns a user retypes to
    # `identifier` or `categorical` to protect. Only the columns being retyped are
    # then cast, to what their new type's profile expects.
    data <- as.data.frame( suppressMessages(
      readr::read_csv( data, col_types = readr::cols( .default = readr::col_character() ) ) ) )
    data <- .cast_for_types( data, types )
  }

  stopifnot( is.data.frame(dgf), is.data.frame(data), "var_name" %in% names(dgf) )

  for( v in names(types) ) {
    i <- match( v, dgf$var_name )
    if( is.na(i) ) { warning( "Not in DGF, skipped: ", v, call. = FALSE ); next }
    if( ! v %in% names(data) ) { warning( "Not in data, skipped: ", v, call. = FALSE ); next }

    ty <- types[[v]]
    vc <- .dgf_vclass_of( ty )
    dgf$desired_data_type[i] <- ty
    # keep the v7 target in step, so dg_render_type() routes the variable to
    # the template its new profile was built for (a data type name is a valid
    # desired_semantic_type; the user can refine it to a semantic type)
    if( "desired_semantic_type" %in% names(dgf) ) dgf$desired_semantic_type[i] <- ty

    # recompute the profile from the raw column for the corrected type
    dgf$rg_properties[i] <- get_properties( v, data )
    dgf$rg_preview[i]    <- get_examples( v, df = data )
    dgf$rg_stats[i]      <- as.character( get_stats( v, data, vc ) )
    dgf$rg_graphics[i]   <- as.character( get_graphics( v, data, vc ) )

    # The level dictionary belongs to the type too. It kept the old spellings
    # (e.g. 0/1/false/true after a recode to boolean) and was empty for a variable
    # newly made categorical, so the report printed stale or missing CATEGORY LABELS.
    # Rebuild it from the data, keeping any label the user already edited for a
    # level that still exists. A type with no levels is left as it was, so a retype
    # never discards labels someone curated.
    if( "dd_f_levels" %in% names(dgf) && ty %in% c("categorical", "boolean") )
      dgf$dd_f_levels[i] <- merge_level_labels( dgf$dd_f_levels[i], .levels_json( data[[v]] ) )
  }

  ## `units` names a temporal grain (year/month/date/dow/...); the grain now
  ## lives in desired_data_class (period.year, phase.day_of_week, ...), which the
  ## render engine reads to pick the graphic - no separate unit column.
  .grain_class <- function( u ) switch( u,
    year = "period.year", quarter = "period.quarter", month = "period.month",
    semester = "period.semester", season = "period.season",
    date = "date.calendar", datetime = "date.timestamp", timestamp = "date.timestamp",
    hour = "phase.hour_of_day", dow = "phase.day_of_week",
    week = "phase.week_of_year", period = "period.reporting_period", u )
  ## The render reads the grain from desired_semantic_type (the v7 temporal
  ## semantic types); the legacy desired_data_class is kept in step for DGFs
  ## that still carry it.
  .grain_semantic <- function( u ) switch( u,
    date = "calendar", datetime = "timestamp", timestamp = "timestamp",
    hour = "hour_of_day", dow = "day_of_week", week = "week_of_year",
    period = "reporting_period", u )
  for( v in names(units) ) {
    i <- match( v, dgf$var_name )
    if( is.na(i) ) next
    if( "desired_semantic_type" %in% names(dgf) )
      dgf$desired_semantic_type[i] <- .grain_semantic( units[[v]] )
    if( "desired_data_class" %in% names(dgf) )
      dgf$desired_data_class[i] <- .grain_class( units[[v]] )
  }

  dgf
}
