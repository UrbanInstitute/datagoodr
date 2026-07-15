# Re-rendering an existing report.
#
# create_rg()/create_dd() scaffold a document once and bake the DGF path into
# its YAML, so it renders standalone from RStudio/Positron. update_rg() is the
# other half: re-render that document against a different DGF or dataset
# WITHOUT editing it, so a user's annotations and layout edits survive.
#
# The division is deliberate. Only the scaffolder ever writes to the qmd;
# update_rg() only passes execute_params. Quarto merges those over the YAML
# defaults, so nothing has to be patched at render time - and nothing can be
# clobbered.


#' Read the params declared in a qmd's YAML front matter (internal)
#'
#' @param path Path to a `.qmd`/`.Rmd`.
#'
#' @return A named list of the declared `params`, or an empty list when the
#'   document declares none.
#'
#' @details Parses only the front matter between the first two `---` fences, so
#'   it costs nothing next to a render. `yaml` is reachable as a knitr
#'   dependency but is declared in Imports so this does not rely on that.
#' @noRd
read_qmd_params <- function( path ) {

  if( ! file.exists(path) )
  { stop( "No such file: ", path, call. = FALSE ) }

  txt <- readLines( path, warn = FALSE )
  fences <- grep( "^---\\s*$", txt )

  if( length(fences) < 2 )
  { stop( basename(path), " has no YAML front matter (expected a block ",
          "delimited by ---).", call. = FALSE ) }

  fm <- paste( txt[ (fences[1] + 1):(fences[2] - 1) ], collapse = "\n" )
  y  <- yaml::yaml.load( fm )

  if( is.null(y$params) ) list() else y$params
}


#' Encode a scalar as a YAML string (internal)
#'
#' @param x A length-1 character, or `NULL`.
#'
#' @return A YAML scalar.
#'
#' @details Single-quoted style: YAML treats backslashes literally inside single
#'   quotes, so a Windows path (`C:\\data\\DGF.xlsx`) survives without escaping.
#'   Only an embedded `'` needs doubling.
#' @noRd
yaml_scalar <- function( x ) {
  if( is.null(x) ) return( "null" )
  paste0( "'", gsub( "'", "''", as.character(x) ), "'" )
}


#' Set one param in a qmd's YAML, and verify the edit landed (internal)
#'
#' @param path Path to the qmd.
#' @param key Param name, e.g. `"dgf_file"`.
#' @param value Value to write.
#'
#' @return Invisibly, `path`.
#'
#' @details Never `sub()` and hope. The previous scaffolder patched a
#'   `file_name_placeholder` token that the template had stopped containing, so
#'   the substitution silently did nothing and the argument it served
#'   (`rg.name`) quietly stopped working. This errors when the anchor is missing
#'   or ambiguous, then re-parses the YAML to confirm the value round-trips -
#'   which also catches quoting bugs a regex cannot see.
#' @noRd
set_qmd_param <- function( path, key, value ) {

  txt    <- readLines( path, warn = FALSE )
  anchor <- paste0( "^(\\s*)", key, ":\\s*.*$" )
  hit    <- grep( anchor, txt )

  if( length(hit) != 1 )
  { stop( "Expected exactly one `", key, ":` line in ", basename(path),
          ", found ", length(hit), ". The template's YAML no longer matches ",
          "what the scaffolder patches; they have drifted apart.",
          call. = FALSE ) }

  indent    <- sub( anchor, "\\1", txt[hit] )
  txt[hit]  <- paste0( indent, key, ": ", yaml_scalar(value) )
  writeLines( txt, path )

  got <- read_qmd_params( path )[[ key ]]
  if( ! identical( got, as.character(value) ) )
  { stop( "Wrote `", key, ": ", value, "` to ", basename(path),
          " but re-reading the YAML gives ", deparse(got),
          ". The patch did not take effect.", call. = FALSE ) }

  invisible( path )
}


#' Resolve a create/update sentinel to a render override (internal)
#'
#' @param value The user's argument: `"in_qmd"`, `"none"`, or a path.
#' @param key The param it maps to (`"dgf_file"` / `"data_file"`).
#' @param declared The params already declared in the qmd.
#' @param arg The argument name, for messages.
#'
#' @return A length-1 list to merge into `execute_params`, or `NULL` for "leave
#'   the document's own value alone".
#'
#' @details Sentinels rather than `NULL` because `NULL` would have to mean both
#'   "don't override" and "explicitly no file", and a caller could not say which
#'   they meant. A real file named `in_qmd` or `none` is caught here rather than
#'   being silently swallowed as a sentinel.
#' @noRd
resolve_sentinel <- function( value, key, declared, arg ) {

  if( ! is.character(value) || length(value) != 1 )
  { stop( "`", arg, "` must be a single string: a file path, \"in_qmd\", or ",
          "\"none\".", call. = FALSE ) }

  if( value %in% c("in_qmd", "none") && file.exists(value) )
  { stop( "`", arg, " = \"", value, "\"` is ambiguous: that is a sentinel, but ",
          "a file named \"", value, "\" also exists here. Rename the file, or ",
          "pass an explicit path like \"./", value, "\".", call. = FALSE ) }

  if( value == "none" ) return( NULL )

  if( value == "in_qmd" ) {
    got <- declared[[ key ]]
    if( is.null(got) || ! nzchar( trimws( as.character(got) ) ) )
    { stop( "`", arg, " = \"in_qmd\"` means use the value in the document, but ",
            "it declares no `", key, "` (or declares it as null). Pass a path ",
            "for `", arg, "` instead.", call. = FALSE ) }
    return( NULL )   # the document's own value already stands; nothing to override
  }

  if( ! file.exists(value) )
  { stop( "`", arg, "` file not found: ", value, call. = FALSE ) }

  stats::setNames( list(value), key )
}


#' Re-render an existing report against a different DGF or dataset
#'
#' Renders a report document that already exists, optionally pointing it at a
#' different DGF and/or raw dataset. The document itself is never modified, so
#' any annotations, custom chunks, or layout edits in it are preserved.
#'
#' @param QMD Path to the report `.qmd` (as scaffolded by [create_rg()] or
#'   [create_dd()]).
#' @param DGF Which DGF to render against. `"in_qmd"` (default) uses the path
#'   the document declares; a file path renders against that DGF instead.
#'   Errors if `"in_qmd"` but the document declares no `dgf_file`.
#' @param CSV Which raw dataset to supply. `"none"` (default) passes nothing, so
#'   the document's own `data_file` default stands. `"in_qmd"` uses the path the
#'   document declares (erroring if it declares none), and a file path supplies
#'   that dataset.
#' @param render Logical; render the document. Defaults to `TRUE`. `FALSE`
#'   validates the arguments and returns the overrides without rendering, which
#'   is useful for checking what a call would do.
#'
#' @return Invisibly, the list of `execute_params` used (empty when the
#'   document's own values were used unchanged).
#'
#' @details The document is read but never written. Overrides are passed to
#'   Quarto as `execute_params`, which merges them over the YAML defaults -
#'   params that are not overridden keep the values declared in the file.
#'
#' @examples
#' \dontrun{
#' # re-render against an updated DGF, keeping every edit in the qmd
#' update_rg( "research-guide.qmd", DGF = "DGF-V2.xlsx" )
#'
#' # supply the raw data too
#' update_rg( "research-guide.qmd", DGF = "DGF-V2.xlsx", CSV = "data-2026.csv" )
#'
#' # just re-render what the document already points at
#' update_rg( "research-guide.qmd" )
#' }
#'
#' @seealso [create_rg()], [create_dd()]
#' @export
update_rg <- function( QMD, DGF = "in_qmd", CSV = "none", render = TRUE ) {

  if( ! file.exists(QMD) )
  { stop( "No such report document: ", QMD, call. = FALSE ) }

  declared <- read_qmd_params( QMD )

  dgf.override <- resolve_sentinel( DGF, "dgf_file",  declared, "DGF" )
  csv.override <- resolve_sentinel( CSV, "data_file", declared, "CSV" )

  # Build the override list with the safe idiom. `ep$x <- NULL` would silently
  # remove the element rather than set it, so only ever assign a real value.
  ep <- list()
  if( ! is.null(dgf.override) ) ep$dgf_file  <- dgf.override[["dgf_file"]]
  if( ! is.null(csv.override) ) ep$data_file <- csv.override[["data_file"]]

  if( render ) {
    before <- if( file.exists(QMD) ) tools::md5sum(QMD)[[1]] else NA_character_
    quarto::quarto_render( QMD, execute_params = ep )
    after <- tools::md5sum(QMD)[[1]]
    if( ! identical( before, after ) )
    { warning( basename(QMD), " changed during render; update_rg() is not ",
               "supposed to modify the document.", call. = FALSE ) }
  }

  invisible( ep )
}
