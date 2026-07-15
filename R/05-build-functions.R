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
#'
#' @return Invisibly, the path to the copied template.
#' @seealso [create_rg()], [create_dd()]
#' @export
use_datagoodr_template <- function( dir = ".", flavor = c("rg", "dd"),
                                    dg = TRUE, overwrite = FALSE ) {

  flavor   <- match.arg( flavor )
  template <- if( flavor == "rg" ) "RG.qmd" else "DD.qmd"
  out.name <- if( flavor == "rg" ) "research-guide.qmd" else "data-dictionary.qmd"

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
build_report <- function( dgf, dir, file, flavor, render, overwrite ) {

  # allow a DGF data frame: write it out next to the report
  if( is.data.frame(dgf) ) {
    dgf.path <- file.path( dir, "DGF.xlsx" )
    if( ! dir.exists(dir) ) dir.create( dir, recursive = TRUE )
    save_to_excel( dgf, filename = dgf.path, open = FALSE )
    dgf <- "DGF.xlsx"
  }

  dest <- use_datagoodr_template( dir = dir, flavor = flavor,
                                  dg = TRUE, overwrite = overwrite )
  # the copier names the file; rename if the caller asked for something else
  if( basename(dest) != file ) {
    new.dest <- file.path( dir, file )
    file.rename( dest, new.dest )
    dest <- new.dest
  }

  # point the template at the supplied DGF path
  txt <- readLines( dest, warn = FALSE )
  txt <- sub( '(\\s*dgf_file:\\s*).*', paste0( '\\1"', dgf, '"' ), txt )
  writeLines( txt, dest )

  if( render )
  { quarto::quarto_render( dest, execute_params = list( dgf_file = dgf ) ) }

  message( "Created ", dest,
           if( render ) " (rendered)" else " (edit, then render)" )
  invisible( dest )
}


#' Create a research guide project from a DGF
#'
#' Scaffolds a research-guide Quarto document (full data profile) pointed at a
#' DGF, plus a starter `DG.R`, ready to customize and render.
#'
#' @param dgf Path to a DGF `.xlsx` file, or a DGF data frame (which is written
#'   to `DGF.xlsx` in `dir`).
#' @param dir Directory to scaffold into. Defaults to the current directory.
#' @param file Name for the report document. Defaults to
#'   `"research-guide.qmd"`.
#' @param render Logical; render the document immediately. Defaults to `FALSE`
#'   (scaffold only, so the user can annotate it first).
#' @param overwrite Logical; overwrite an existing document. Defaults to
#'   `FALSE`.
#'
#' @return Invisibly, the path to the scaffolded (or rendered) document.
#' @seealso [create_dd()], [use_datagoodr_template()]
#' @export
create_rg <- function( dgf, dir = ".", file = "research-guide.qmd",
                       render = FALSE, overwrite = FALSE ) {
  build_report( dgf, dir, file, flavor = "rg",
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
#' @seealso [create_rg()], [use_datagoodr_template()]
#' @export
create_dd <- function( dgf, dir = ".", file = "data-dictionary.qmd",
                       render = FALSE, overwrite = FALSE ) {
  build_report( dgf, dir, file, flavor = "dd",
                render = render, overwrite = overwrite )
}
