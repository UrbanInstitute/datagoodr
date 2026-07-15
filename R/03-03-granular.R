# Granular per-variable API.
#
# These helpers let a user drop a single variable's profile - or one element of
# it - into a narrative document (or the console), instead of auto-rendering
# every variable. Each sets the render context for one variable and calls the
# appropriate render function, so no prior create_all_sections() sweep is
# needed. Call them inside a `results = "asis"` chunk in a Quarto document.


#' Publish one variable's DGF row to the render context (internal)
#'
#' The render functions read the current variable from a package-internal
#' context env rather than taking it as an argument. This sets that context for
#' a single variable, which is what lets the `dg_*()` helpers render one
#' element without a prior [create_all_sections()] sweep.
#'
#' @param dgf A DGF data frame.
#' @param vname The variable name (a value of `dgf$vname`).
#'
#' @return The variable's `vtype_class`, used by the callers to pick a
#'   type-appropriate render function. Errors if `vname` is not in the DGF.
#' @seealso [set_xx()], [get_xx()]
#' @noRd
set_dg_context <- function( dgf, vname ) {
  i <- match( vname, dgf$vname )
  if( is.na(i) )
  { stop( "Variable not found in DGF: ", vname, call. = FALSE ) }
  xx <- as.list( dgf[ i, , drop = FALSE ] )
  xx <- lapply( xx, function(v) v[[1]] )   # scalars, not length-1 vectors
  xx[["VNAME"]] <- vname
  set_xx( xx )
  as.character( xx[["vtype_class"]] )
}


#' Render one variable's full profile section
#'
#' Emits the complete layout section (all divs) for a single variable, exactly
#' as it would appear in a full report. Use it to place one variable's profile
#' inline in a narrative document.
#'
#' @param dgf A DGF data frame.
#' @param vname The variable name (a value of `dgf$vname`).
#' @param style `"rg"` (full profile) or `"dd"` (descriptors only). Defaults to
#'   `"rg"`.
#' @param layouts Optional layout override passed to [get_design()].
#'
#' @return No return value; prints the section. Call inside a
#'   `results = "asis"` chunk.
#' @seealso [dg_stats()], [dg_properties()], [dg_levels()], [dg_field()]
#' @export
dg_section <- function( dgf, vname, style = "rg", layouts = NULL ) {
  L <- dgf_to_list( dgf )
  create_section( vname, get_design( style = style, layouts = layouts ), L )
  invisible( NULL )
}


#' Render one element of a variable's profile
#'
#' Print a single piece of a variable's profile inline: its summary statistics,
#' data-quality properties, value preview, factor levels, graphic, or any text
#' field from the DGF.
#'
#' @param dgf A DGF data frame.
#' @param vname The variable name (a value of `dgf$vname`).
#' @param label Optional section label; defaults to the render function's own
#'   default (e.g. `"STATS"`).
#'
#' @return No return value; prints the element. Call inside a
#'   `results = "asis"` chunk.
#' @name dg_element
#' @seealso [dg_section()]
NULL

#' @describeIn dg_element Summary statistics (type-appropriate).
#' @export
dg_stats <- function( dgf, vname, label = "STATS" ) {
  type <- set_dg_context( dgf, vname )
  f <- switch( type,
    numeric   = paste_stats_num,
    character = paste_stats_chr,
    factor    = paste_stats_fact,
    logical   = paste_stats_log,
    stop( "No stats renderer for type '", type, "'.", call. = FALSE ) )
  f( "rg_stats", label )
  invisible( NULL )
}

#' @describeIn dg_element Data-quality properties (rows, distinct, missing, ...).
#' @export
dg_properties <- function( dgf, vname, label = "PROPERTIES" ) {
  set_dg_context( dgf, vname )
  paste_properties( "rg_properties", label )
  invisible( NULL )
}

#' @describeIn dg_element Quantile table (numeric variables).
#' @export
dg_quantiles <- function( dgf, vname, label = "QUANTILES" ) {
  type <- set_dg_context( dgf, vname )
  if( type != "numeric" )
  { stop( "Quantiles are only available for numeric variables (got '",
          type, "').", call. = FALSE ) }
  paste_quantiles( "rg_stats", label )
  invisible( NULL )
}

#' @describeIn dg_element Preview of example values (numeric or character).
#' @param size Maximum line width for `dg_preview`, in characters (default 80).
#' @export
dg_preview <- function( dgf, vname, label = "PREVIEW", size = 80 ) {
  type <- set_dg_context( dgf, vname )
  f <- switch( type,
    numeric   = paste_preview_num,
    character = paste_preview_chr,
    stop( "Previews are only available for numeric and character variables ",
          "(got '", type, "').", call. = FALSE ) )
  f( "rg_preview", label, size = size )
  invisible( NULL )
}

#' @describeIn dg_element Factor/logical level dictionary.
#' @export
dg_levels <- function( dgf, vname, label = "LEVELS" ) {
  set_dg_context( dgf, vname )
  paste_levels( "dd_f_level", label )
  invisible( NULL )
}

#' @describeIn dg_element The type-appropriate graphic (histogram, treemap,
#'   bar plot, or word cloud). Set chunk `fig.width`/`fig.height` to size it.
#' @export
dg_graphic <- function( dgf, vname, label = NULL ) {
  type <- set_dg_context( dgf, vname )
  f <- switch( type,
    numeric   = paste_histogram,
    factor    = paste_treemap,
    logical   = paste_booleplot,
    character = v_to_wordcloud,
    stop( "No graphic for type '", type, "'.", call. = FALSE ) )
  if( is.null(label) ) f( "rg_graphics" ) else f( "rg_graphics", label )
  invisible( NULL )
}

#' @describeIn dg_element Any text field from the DGF (e.g. `"vdesc"`,
#'   `"vlabel"`, `"vscope"`). `field` is the DGF column name.
#' @param field DGF column name to print (for `dg_field`).
#' @export
dg_field <- function( dgf, vname, field, label = toupper(field) ) {
  set_dg_context( dgf, vname )
  v_to_txt( field, label )
  invisible( NULL )
}
