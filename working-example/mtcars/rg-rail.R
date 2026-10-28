###############################################################################
### EXPERIMENTAL "rail" layout for the research guide
###############################################################################
# A draft, modelled on the econometrics course site: each variable is a unit
# with a narrow left rail (type, label, name, description, properties) and a
# wide right column (graphic, preview, stats). The table of contents follows
# the same site's numbered two-column list.
#
# It reuses the package's own block builders (paste_properties, paste_histogram,
# ...) and the default layouts - it only rearranges where each block goes - so
# nothing in the package changes. Used by research-guide-rail.qmd.

## helpers --------------------------------------------------------------------

# characters per preview line; the right column is exactly this many
# characters of the preview font wide (keep in step with 84ch in rg-rail.css)
rail_cols <- 84

rail_esc <- function( s ) {
  s <- as.character( s ); s[ is.na(s) ] <- ""
  s <- gsub( "&", "&amp;", s, fixed = TRUE )
  s <- gsub( "<", "&lt;",  s, fixed = TRUE )
  gsub( ">", "&gt;", s, fixed = TRUE )
}

rail_id <- function( v ) paste0( "var-", gsub( "[^A-Za-z0-9_-]+", "-", v ) )

rail_field <- function( xx, f ) {
  v <- if( f %in% names(xx) ) xx[[f]] else ""
  if( is.null(v) || ! length(v) || is.na(v) ) return( "" )
  trimws( as.character(v) )
}

# mode first, then the more specific data type when there is one
rail_types <- function( xx ) {
  x <- c( rail_field( xx, "dg_render_type" ), rail_field( xx, "dg_semantic_type" ) )
  x[ nzchar(x) ]
}

# one render context per variable, with the derived type fields added
rail_context <- function( dgf ) {
  if( ! nrow(dgf) ) return( list() )
  L <- datagoodr:::dgf_to_list( dgf )
  out <- lapply( names(L), function( v ) {
    xx <- L[[v]]
    xx[["VNAME"]] <- v
    datagoodr:::.add_render_fields( xx )
  } )
  stats::setNames( out, names(L) )
}

# run the layout rows for some divs, in layout order
rail_run <- function( rows ) {
  for( i in seq_len( nrow(rows) ) ) {
    fn  <- trimws( rows$FUNCTION[i] )
    # a user function wins; otherwise the package's (some are not exported)
    f   <- if( exists( fn, envir = globalenv() ) ) get( fn, envir = globalenv() )
           else get( fn, envir = asNamespace("datagoodr") )
    args <- list( VNAME = rows$VNAME[i], LABEL = rows$LABEL[i] )
    # previews wrap to the right column's width (84ch in rg-rail.css)
    if( "size" %in% names( formals(f) ) ) args$size <- rail_cols
    txt <- do.call( f, args )
    if( is.character(txt) ) cat( txt, sep = "\n" )
  }
}

rail_block <- function( rows, class ) {
  if( ! nrow(rows) ) return( invisible(NULL) )
  cat( "::: {.dg-block .", class, "}\n\n", sep = "" )
  rail_run( rows )
  cat( "\n\n:::\n\n" )
}


## table of contents ----------------------------------------------------------

#' groups: a named list of DGF subsets, e.g. list(Numeric = dgf.num, ...)
rail_toc <- function( groups, brand = "Research Guide" ) {

  groups <- groups[ vapply( groups, nrow, 1L ) > 0 ]
  h <- character()
  add <- function( ... ) h <<- c( h, paste0( ... ) )

  # sticky top bar: brand + a link per group
  add( '<div class="dg-bar"><div class="dg-bar-inner">' )
  add( '<a class="dg-bar-brand" href="#top">', rail_esc(brand), '</a>' )
  add( '<nav class="dg-bar-nav"><a href="#contents">Contents</a>' )
  for( g in names(groups) )
    add( '<a href="#', tolower(g), '">', rail_esc(g), '</a>' )
  add( '</nav></div></div>' )

  add( '<nav class="dg-contents" id="contents">' )
  add( '<h2>Contents</h2>' )
  n <- 0
  for( g in names(groups) ) {
    ctx <- rail_context( groups[[g]] )
    add( '<h3 class="toc-part">', rail_esc(g), ' &mdash; ', length(ctx),
         if( length(ctx) == 1 ) ' variable' else ' variables', '</h3>' )
    add( '<ul class="toc">' )
    for( v in names(ctx) ) {
      n  <- n + 1
      xx <- ctx[[v]]
      lab <- rail_field( xx, "dd_vlabel" ); if( lab == v ) lab <- ""
      add( '<li><a class="toc-unit" href="#', rail_id(v), '">',
           '<span class="n">', sprintf( "%02d", n ), '</span>',
           '<span class="t">', rail_esc(v), '</span></a>',
           '<ul class="toc-items"><li>',
           if( nzchar(lab) ) paste0( '<span class="it">', rail_esc(lab), '</span>' ) else "",
           '</li></ul></li>' )
    }
    add( '</ul>' )
  }
  add( '</nav>' )

  cat( "```{=html}\n", paste( h, collapse = "\n" ), "\n```\n\n", sep = "" )
}


## variable units -------------------------------------------------------------

rail_section <- function( v, xx, design ) {

  datagoodr:::set_xx( xx )
  rows <- design[ design$TYPE == xx[["dg_render_type"]], , drop = FALSE ]
  divs <- function( d ) rows[ trimws(rows$DIV) %in% d, , drop = FALSE ]

  lab  <- rail_field( xx, "dd_vlabel" )
  desc <- rail_field( xx, "dd_vdesc" )
  ty   <- rail_types( xx )

  cat( "::::: {.dg-unit #", rail_id(v), "}\n\n", sep = "" )

  # left rail: type / label / name / description / properties
  cat( ":::: {.dg-rail}\n\n" )
  cat( "```{=html}\n" )
  cat( '<p class="dg-kind">', paste( rail_esc(ty), collapse = " &middot; " ), "</p>\n", sep = "" )
  if( nzchar(lab) && lab != v ) {
    cat( '<p class="dg-label">', rail_esc(lab), "</p>\n", sep = "" )
    cat( '<p class="dg-vname"><code>', rail_esc(v), "</code></p>\n", sep = "" )
  } else {
    cat( '<p class="dg-label dg-label--code">', rail_esc(v), "</p>\n", sep = "" )
  }
  if( nzchar(desc) ) cat( '<p class="dg-desc">', rail_esc(desc), "</p>\n", sep = "" )
  cat( "```\n\n" )
  rail_block( divs("div7"), "dg-props" )
  cat( "::::\n\n" )

  # right column: graphic / preview / stats
  cat( ":::: {.dg-body}\n\n" )
  rail_block( divs("div8"),            "dg-graphic" )
  rail_block( divs(c("div5", "div6")), "dg-preview" )
  rail_block( divs("div9"),            "dg-stats" )
  cat( "::::\n\n" )

  cat( ":::::\n\n" )
}

#' Emit a group header and one unit per variable in `dgf`.
rail_group <- function( dgf, title ) {
  if( ! nrow(dgf) ) return( invisible(NULL) )
  design <- get_design()
  cat( "## ", title, " {#", tolower(title), " .dg-part}\n\n", sep = "" )
  ctx <- rail_context( dgf )
  for( v in names(ctx) ) rail_section( v, ctx[[v]], design )
}
