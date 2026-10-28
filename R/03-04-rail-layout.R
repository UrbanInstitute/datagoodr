###############################################################################
### Research guide "rail" layout (the default research guide style)
###############################################################################
# Each variable is a unit with a narrow left rail (type, label, name,
# description, properties) and a wide right column (graphic, preview, stats).
# Variables are grouped under a header per data type, and the guide opens with
# a numbered two-column contents list.
#
# The rail reuses the same block builders and layouts as the vintage grid
# (paste_properties, paste_histogram, ... via get_design()); it only changes
# where each block goes:
#   rail : div7 PROPERTIES
#   body : div8 graphic, then div5/div6 PREVIEW, then div9 stats tables
# The div2/div3/div4 descriptor rows are replaced by the rail header.

# Characters per preview line. The right column is exactly this many characters
# of the preview font wide (84ch in datagoodr.css), so graphics and preview text
# end at the same edge.
.rail_cols <- 84

# Group order and titles for the rail guide, keyed by dg_render_type().
.rail_groups <- c( boolean = "Boolean", categorical = "Categorical",
                   number = "Numeric", text = "Text",
                   identifier = "Identifier", temporal = "Temporal" )

.rail_esc <- function( s ) {
  s <- as.character( s ); s[ is.na(s) ] <- ""
  s <- gsub( "&", "&amp;", s, fixed = TRUE )
  s <- gsub( "<", "&lt;",  s, fixed = TRUE )
  gsub( ">", "&gt;", s, fixed = TRUE )
}

.rail_id <- function( v ) paste0( "var-", gsub( "[^A-Za-z0-9_-]+", "-", v ) )

.rail_field <- function( xx, f ) {
  v <- if( f %in% names(xx) ) xx[[f]] else ""
  if( is.null(v) || ! length(v) || is.na(v) ) return( "" )
  trimws( as.character(v) )
}

# data mode first, then the more specific data type when there is one
.rail_types <- function( xx ) {
  x <- c( .rail_field( xx, "dg_render_type" ), .rail_field( xx, "dg_semantic_type" ) )
  x[ nzchar(x) ]
}

# one render context per variable, with the derived type fields added
.rail_context <- function( dgf ) {
  if( ! nrow(dgf) ) return( list() )
  L <- dgf_to_list( dgf )
  out <- lapply( names(L), function( v ) {
    xx <- L[[v]]
    xx[["VNAME"]] <- v
    .add_render_fields( xx )
  } )
  stats::setNames( out, names(L) )
}

# run layout rows in order; a function defined by the user (e.g. in DG.R) wins
# over the package's own of the same name
.rail_run <- function( rows ) {
  for( i in seq_len( nrow(rows) ) ) {
    fn <- trimws( rows$FUNCTION[i] )
    f  <- if( exists( fn, envir = globalenv() ) ) get( fn, envir = globalenv() )
          else get( fn, envir = asNamespace("datagoodr") )
    args <- list( VNAME = rows$VNAME[i], LABEL = rows$LABEL[i] )
    if( "size" %in% names( formals(f) ) ) args$size <- .rail_cols
    txt <- do.call( f, args )
    if( is.character(txt) ) cat( txt, sep = "\n" )
  }
}

.rail_block <- function( rows, class ) {
  if( ! nrow(rows) ) return( invisible(NULL) )
  cat( "::: {.dg-block .", class, "}\n\n", sep = "" )
  .rail_run( rows )
  cat( "\n\n:::\n\n" )
}

# one variable unit
.rail_unit <- function( v, xx, design ) {

  set_xx( xx )
  rows <- design[ design$TYPE == xx[["dg_render_type"]], , drop = FALSE ]
  divs <- function( d ) rows[ trimws(rows$DIV) %in% d, , drop = FALSE ]

  lab  <- .rail_field( xx, "dd_vlabel" )
  desc <- .rail_field( xx, "dd_vdesc" )
  ty   <- .rail_types( xx )

  cat( "::::: {.dg-unit #", .rail_id(v), "}\n\n", sep = "" )

  # left rail: type / label / name / description / properties
  cat( ":::: {.dg-rail}\n\n" )
  cat( "```{=html}\n" )
  cat( '<p class="dg-kind">', paste( .rail_esc(ty), collapse = " &middot; " ), "</p>\n", sep = "" )
  if( nzchar(lab) && lab != v ) {
    cat( '<p class="dg-label">', .rail_esc(lab), "</p>\n", sep = "" )
    cat( '<p class="dg-vname"><code>', .rail_esc(v), "</code></p>\n", sep = "" )
  } else {
    cat( '<p class="dg-label dg-label--code">', .rail_esc(v), "</p>\n", sep = "" )
  }
  if( nzchar(desc) ) cat( '<p class="dg-desc">', .rail_esc(desc), "</p>\n", sep = "" )
  cat( "```\n\n" )
  .rail_block( divs("div7"), "dg-props" )
  cat( "::::\n\n" )

  # right column: graphic / preview / stats
  cat( ":::: {.dg-body}\n\n" )
  .rail_block( divs("div8"),            "dg-graphic" )
  .rail_block( divs(c("div5", "div6")), "dg-preview" )
  .rail_block( divs("div9"),            "dg-stats" )
  cat( "::::\n\n" )

  cat( ":::::\n\n" )
}


#' Split a DGF into the research guide's data-type groups
#'
#' Groups variables by the report template they render with
#' ([dg_render_type()]), in the order the research guide shows them: Boolean,
#' Categorical, Numeric, Text, Identifier, Temporal.
#'
#' @param dgf A DGF data frame.
#'
#' @return A named list of DGF subsets, one per group (empty groups included).
#' @seealso [rail_contents()], [rail_sections()]
#' @export
rail_groups <- function( dgf ) {
  rt <- dg_render_type( dgf )
  out <- lapply( names(.rail_groups), function( k ) dgf[ rt == k, , drop = FALSE ] )
  stats::setNames( out, unname(.rail_groups) )
}


#' Print the research guide's top bar and contents list
#'
#' Writes a sticky top bar (a link per data-type group) and a numbered
#' two-column contents list: variable number and name on the left, its label on
#' the right, grouped by data type. Call inside a `results = "asis"` chunk.
#'
#' @param groups A named list of DGF subsets, as returned by [rail_groups()].
#'   Empty groups are skipped.
#' @param brand Text for the top bar. Defaults to `"Research Guide"`.
#'
#' @return No return value; prints raw HTML.
#' @seealso [rail_sections()]
#' @export
rail_contents <- function( groups, brand = "Research Guide" ) {

  groups <- groups[ vapply( groups, nrow, 1L ) > 0 ]
  h <- character()
  add <- function( ... ) h <<- c( h, paste0( ... ) )

  add( '<div class="dg-bar"><div class="dg-bar-inner">' )
  add( '<a class="dg-bar-brand" href="#top">', .rail_esc(brand), '</a>' )
  add( '<nav class="dg-bar-nav"><a href="#contents">Contents</a>' )
  for( g in names(groups) )
    add( '<a href="#', tolower(g), '">', .rail_esc(g), '</a>' )
  add( '</nav></div></div>' )

  add( '<nav class="dg-contents" id="contents">' )
  add( '<h2>Contents</h2>' )
  n <- 0
  for( g in names(groups) ) {
    ctx <- .rail_context( groups[[g]] )
    add( '<h3 class="toc-part">', .rail_esc(g), ' &mdash; ', length(ctx),
         if( length(ctx) == 1 ) ' variable' else ' variables', '</h3>' )
    add( '<ul class="toc">' )
    for( v in names(ctx) ) {
      n   <- n + 1
      lab <- .rail_field( ctx[[v]], "dd_vlabel" ); if( lab == v ) lab <- ""
      add( '<li><a class="toc-unit" href="#', .rail_id(v), '">',
           '<span class="n">', sprintf( "%02d", n ), '</span>',
           '<span class="t">', .rail_esc(v), '</span></a>',
           '<ul class="toc-items"><li>',
           if( nzchar(lab) ) paste0( '<span class="it">', .rail_esc(lab), '</span>' ) else "",
           '</li></ul></li>' )
    }
    add( '</ul>' )
  }
  add( '</nav>' )

  cat( "```{=html}\n", paste( h, collapse = "\n" ), "\n```\n\n", sep = "" )
}


#' Print one data-type group of the research guide
#'
#' Writes the group's header band, then one unit per variable: a left rail
#' with the data type, label, name, description and PROPERTIES table, and a
#' right column with the graphic, PREVIEW and stats tables. Call inside a
#' `results = "asis"` chunk; set the chunk's `fig.width`/`fig.height` for the
#' group's graphic.
#'
#' @param dgf A DGF subset (one element of [rail_groups()]). Nothing is
#'   printed when it has no rows.
#' @param title The group's header text, e.g. `"Numeric"`. Also its anchor
#'   (lower-cased), which [rail_contents()] links to.
#' @param layouts Optional named list of layout vectors overriding the package
#'   defaults; passed to [get_design()].
#'
#' @return No return value; prints markdown.
#' @seealso [rail_contents()], [create_all_sections()] for the vintage grid
#' @export
rail_sections <- function( dgf, title, layouts = NULL ) {
  if( ! nrow(dgf) ) return( invisible(NULL) )
  design <- get_design( layouts = layouts )
  cat( "## ", title, " {#", tolower(title), " .dg-part}\n\n", sep = "" )
  ctx <- .rail_context( dgf )
  for( v in names(ctx) ) .rail_unit( v, ctx[[v]], design )
}
