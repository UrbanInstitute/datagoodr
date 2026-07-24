# Step 5: scaffold a customizable documentation project from the package
# templates. A project directory holds the data, the DGF (rules file), a DG.R
# customization file, and a .qmd that renders the report:
#
#   my-project/
#     DGF.xlsx              the rules file
#     DG.R                  custom formatting/graphic functions & layout overrides
#     research-guide.qmd    (or data-dictionary.qmd)


#' Return the datagoodr report stylesheet
#'
#' Reads the package's report CSS (`inst/templates/datagoodr.css`). The RG and
#' DD templates emit it inside a `<style>` block, so a single stylesheet drives
#' every report. To restyle, edit that file (or add overriding rules in your
#' project `.qmd`).
#'
#' @details A project-local `datagoodr.css` (in the render directory) takes
#'   precedence over the packaged one, so a scaffolded project can be restyled
#'   by editing its own copy.
#'
#' @return A single character string of CSS (empty if no stylesheet is found).
#' @export
datagoodr_css <- function() {
  path <- if( file.exists("datagoodr.css") ) "datagoodr.css"
          else system.file( "templates", "datagoodr.css", package = "datagoodr" )
  if( path == "" || ! file.exists(path) ) return( "" )
  paste( readLines( path, warn = FALSE ), collapse = "\n" )
}


#' Copy a datagoodr report template into a project
#'
#' Installs one of the package's Quarto templates (research guide or data
#' dictionary) into a directory, along with a starter `DG.R` customization
#' file, so it can be edited and rendered locally.
#'
#' @param dir Directory to write into. Created if it does not exist. Defaults
#'   to the current working directory.
#' @param flavor `"rg"` for the research guide (full data profile) or `"dd"`
#'   for the data dictionary (descriptors only). Defaults to `"rg"`.
#' @param dg Logical; also copy a starter `DG.R` if one is not already present.
#'   Defaults to `TRUE`.
#' @param overwrite Logical; overwrite an existing `.qmd` of the same name.
#'   Defaults to `FALSE`.
#' @param file Optional name for the copied document. Defaults to the flavor's
#'   standard name (`research-guide.qmd` / `data-dictionary.qmd`). The template
#'   is written straight to this name, so the overwrite guard applies to the
#'   file you actually asked for --- naming one report never touches another.
#'
#' @return Invisibly, the path to the copied template.
#' @seealso [create_rg()], [create_dd()]
#' @export
use_datagoodr_template <- function( dir = ".", flavor = c("rg", "dd"),
                                    dg = TRUE, overwrite = FALSE,
                                    file = NULL ) {

  flavor   <- match.arg( flavor )
  template <- if( flavor == "rg" ) "RG.qmd" else "DD.qmd"
  out.name <- if( ! is.null(file) && nzchar(file) ) file
              else if( flavor == "rg" ) "research-guide.qmd"
              else "data-dictionary.qmd"

  src <- system.file( "templates", template, package = "datagoodr" )
  if( src == "" )
  { stop( "Template not found. Is datagoodr installed?", call. = FALSE ) }

  if( ! dir.exists(dir) ) dir.create( dir, recursive = TRUE )

  dest <- file.path( dir, out.name )
  if( file.exists(dest) && ! overwrite )
  { stop( dest, " already exists; use overwrite = TRUE.", call. = FALSE ) }
  file.copy( src, dest, overwrite = overwrite )

  if( dg ) {
    dg.dest <- file.path( dir, "DG.R" )
    if( ! file.exists(dg.dest) )
    { file.copy( system.file("templates", "DG.R", package = "datagoodr"),
                 dg.dest ) }
  }

  # ship a local copy of the stylesheet so the project can be restyled
  css.dest <- file.path( dir, "datagoodr.css" )
  if( ! file.exists(css.dest) )
  { file.copy( system.file("templates", "datagoodr.css", package = "datagoodr"),
               css.dest ) }

  message( "Created ", dest )
  invisible( dest )
}


#' Scaffold a report qmd pointed at a DGF (internal)
#'
#' Shared body of [create_rg()] and [create_dd()]: installs the flavor's
#' template into `dir`, points it at the DGF, and optionally renders it.
#'
#' @param dgf A DGF data frame, or a path to a DGF `.xlsx`. A data frame is
#'   written out to `dir/DGF.xlsx` first, so the rendered document always reads
#'   from a file.
#' @param dir Directory to scaffold into. Created if it does not exist.
#' @param file Name for the report document.
#' @param flavor `"rg"` (full profile) or `"dd"` (descriptors only).
#' @param render Logical; render the document after scaffolding it.
#' @param overwrite Logical; overwrite an existing document of the same name.
#'
#' @return Invisibly, the path to the scaffolded (or rendered) document.
#' @seealso [use_datagoodr_template()], which copies the template.
#' @noRd
# Reduce a path to be relative to `dir` for baking into a qmd that lives there.
# A file directly inside `dir` becomes its basename; anything else is left as
# given (the caller's responsibility to make it resolvable from the qmd).
rel_to_dir <- function( path, dir ) {
  if( is.null(path) ) return( path )
  same_dir <- tryCatch(
    normalizePath( dirname(path), mustWork = FALSE ) ==
      normalizePath( dir, mustWork = FALSE ),
    error = function(e) FALSE )
  if( isTRUE(same_dir) ) basename(path) else path
}


build_report <- function( dgf, data, dir, file, flavor, embed_css,
                          render, overwrite ) {

  # allow a DGF data frame: write it out next to the report
  if( is.data.frame(dgf) ) {
    dgf.path <- file.path( dir, "DGF.xlsx" )
    if( ! dir.exists(dir) ) dir.create( dir, recursive = TRUE )
    save_to_excel( dgf, filename = dgf.path, open = FALSE )
    dgf <- "DGF.xlsx"
  }

  if( ! is.character(dgf) || length(dgf) != 1 )
  { stop( "`dgf` must be a DGF data frame or a path to a DGF .xlsx file.",
          call. = FALSE ) }

  # Write the template straight to the requested filename. Copying to the
  # flavor's default name and renaming would clobber (then move away) an
  # unrelated report of that default name -- e.g. scaffolding
  # research-guide-temporal-demo.qmd must never touch research-guide.qmd.
  dest <- use_datagoodr_template( dir = dir, flavor = flavor,
                                  dg = TRUE, overwrite = overwrite, file = file )

  # Bake the paths into the scaffolded document so it renders standalone from
  # RStudio/Positron. This is the only place the qmd is written: update_rg()
  # overrides at render time instead, so it can never clobber a user's edits.
  # set_qmd_param() verifies each edit landed rather than trusting the regex.
  #
  # The path is baked RELATIVE TO the qmd's own directory, since quarto renders
  # from there: a DGF sitting next to the qmd (the common case, e.g.
  # create_rg(dgf = "dir/DGF.xlsx", dir = "dir")) is baked as just its basename
  # so the standalone render finds it.
  set_qmd_param( dest, "dgf_file",  rel_to_dir(dgf,  dir) )
  if( ! is.null(data) ) set_qmd_param( dest, "data_file", rel_to_dir(data, dir) )

  if( embed_css ) embed_css_block( dest )

  # No execute_params here: the document's own YAML is the single source of
  # truth for its DGF. Passing it twice is how the two drifted apart before.
  if( render ) quarto::quarto_render( dest )

  message( "Created ", dest,
           if( render ) " (rendered)" else " (edit, then render)" )
  invisible( dest )
}


#' Replace the runtime stylesheet chunk with the stylesheet itself (internal)
#'
#' @param path Path to a scaffolded report qmd.
#'
#' @return Invisibly, `path`.
#'
#' @details By default the template calls [datagoodr_css()] at render, so the
#'   report tracks the package's stylesheet. Embedding writes the CSS into the
#'   document as a literal `css` chunk instead, so a power user can edit the
#'   rules in place. The trade is deliberate: an embedded copy stops tracking
#'   package updates. Distinct from `embed-resources: true`, which inlines CSS
#'   into the rendered *HTML*; this makes the *qmd* self-contained.
#'
#'   Verifies both ends: errors if the chunk anchor is missing, and again if the
#'   runtime call survives the rewrite.
#' @noRd
embed_css_block <- function( path ) {

  css <- datagoodr_css()
  if( ! nzchar(css) )
  { stop( "Cannot embed the stylesheet: datagoodr_css() found no CSS.",
          call. = FALSE ) }

  txt   <- readLines( path, warn = FALSE )
  start <- grep( "^```\\{r[ ,].*datagoodr-style", txt )

  if( length(start) != 1 )
  { stop( "Expected exactly one `datagoodr-style` chunk in ", basename(path),
          ", found ", length(start), ". The template has changed; embed_css ",
          "needs updating.", call. = FALSE ) }

  fences <- grep( "^```\\s*$", txt )
  end    <- fences[ fences > start ][1]
  if( is.na(end) )
  { stop( "The `datagoodr-style` chunk in ", basename(path),
          " is never closed.", call. = FALSE ) }

  # `echo=FALSE` in the chunk header rather than a `#| echo: false` option
  # line: inside a css chunk the option comment must be CSS (`/*| ... */`), and
  # quarto rejects the R form outright.
  block <- c( "```{css echo=FALSE}",
              "/* Embedded copy of datagoodr.css - edit freely. Because it is",
              "   embedded, it no longer tracks the packaged stylesheet. */",
              strsplit( css, "\n", fixed = TRUE )[[1]],
              "```" )

  txt <- append( txt[ -(start:end) ], block, after = start - 1 )
  writeLines( txt, path )

  # Verify against the chunk, not the text: datagoodr.css's own header comment
  # mentions datagoodr_css(), so grepping the whole file for that string finds
  # the embedded comment and not a live call.
  check <- readLines( path, warn = FALSE )
  if( any( grepl( "^```\\{r[ ,].*datagoodr-style", check ) ) )
  { stop( "Embedded the stylesheet into ", basename(path),
          " but the runtime `datagoodr-style` chunk survived.", call. = FALSE ) }
  if( ! any( grepl( "^```\\{css[ }]", check ) ) )
  { stop( "Rewrote ", basename(path), " but no css chunk was written.",
          call. = FALSE ) }

  invisible( path )
}


#' Create a research guide project from a DGF
#'
#' Scaffolds a research-guide Quarto document (full data profile) pointed at a
#' DGF, plus a starter `DG.R`, ready to customize and render.
#'
#' @param dgf Path to a DGF `.xlsx` file, or a DGF data frame (which is written
#'   to `DGF.xlsx` in `dir`). Defaults to `"DGF.xlsx"`.
#' @param data Optional path to the raw dataset. Defaults to `NULL`. The report
#'   renders from the DGF alone, so this is only needed when a custom chunk or
#'   `DG.R` wants the underlying values; when supplied it is read into
#'   `raw.data` in the document.
#' @param dir Directory to scaffold into. Defaults to the current directory.
#' @param file Name for the report document. Defaults to
#'   `"research-guide.qmd"`.
#' @param embed_css Logical; write the stylesheet into the document instead of
#'   calling [datagoodr_css()] at render. Defaults to `FALSE`. Use it to edit
#'   the CSS in place, accepting that an embedded copy stops tracking the
#'   packaged stylesheet.
#' @param render Logical; render the document immediately. Defaults to `FALSE`
#'   (scaffold only, so the user can annotate it first).
#' @param overwrite Logical; overwrite an existing document. Defaults to
#'   `FALSE`.
#'
#' @return Invisibly, the path to the scaffolded (or rendered) document.
#'
#' @details The DGF path is baked into the document's YAML, so it renders on its
#'   own from RStudio/Positron. To re-render against a different DGF later,
#'   use [update_rg()] rather than re-scaffolding: it overrides at render time
#'   and leaves your edits to the document intact.
#'
#' @seealso [create_dd()], [update_rg()], [use_datagoodr_template()]
#' @export
create_rg <- function( dgf = "DGF.xlsx", data = NULL, dir = ".",
                       file = "research-guide.qmd", embed_css = FALSE,
                       render = FALSE, overwrite = FALSE ) {
  build_report( dgf, data, dir, file, flavor = "rg", embed_css = embed_css,
                render = render, overwrite = overwrite )
}


#' Create a data dictionary project from a DGF
#'
#' Scaffolds a data-dictionary Quarto document (descriptors only — no data
#' profiles) pointed at a DGF, plus a starter `DG.R`.
#'
#' @inheritParams create_rg
#' @param file Name for the report document. Defaults to
#'   `"data-dictionary.qmd"`.
#'
#' @return Invisibly, the path to the scaffolded (or rendered) document.
#' @seealso [create_rg()], [update_rg()], [use_datagoodr_template()]
#' @export
create_dd <- function( dgf = "DGF.xlsx", data = NULL, dir = ".",
                       file = "data-dictionary.qmd", embed_css = FALSE,
                       render = FALSE, overwrite = FALSE ) {
  build_report( dgf, data, dir, file, flavor = "dd", embed_css = embed_css,
                render = render, overwrite = overwrite )
}
