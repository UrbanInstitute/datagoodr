# Provenance for a rendered report: what DGF produced this HTML, with which
# version of the package, when.
#
# The record is written as an HTML comment by default rather than a visible
# section, because a Research Guide is a document you hand to someone - the
# provenance should travel with the file without taking up space in it.
#
# What it deliberately does NOT capture by default: the username and absolute
# paths. An absolute path here reads like
# "C:/Users/<name>/Dropbox (Personal)/<client>/..." and would be shipped to
# every recipient of the report. Pass identify = TRUE when the audit trail
# matters more than that, e.g. for an internal-only render.


#' Reduce a path to something safe to publish (internal)
#'
#' @param p A path, or `NULL`.
#'
#' @return `NULL` unchanged; an absolute path reduced to its file name; a
#'   relative path as-is.
#'
#' @details A relative path is already scoped to the project and says something
#'   useful ("data/DGF-V2.xlsx"). An absolute one leaks the machine's layout and
#'   usually the username, so only its basename survives.
#' @noRd
publishable_path <- function( p ) {
  if( is.null(p) || ! nzchar( trimws( as.character(p) ) ) ) return( NULL )
  p <- as.character(p)
  if( is_absolute_path(p) ) basename(p) else p
}


#' Hash a DGF by content (internal)
#'
#' @param dgf A DGF data frame.
#'
#' @return A hash string, or `NULL` when `dgf` is not a data frame.
#'
#' @details Hashes the *loaded* DGF, not the file. Writing identical data to
#'   .xlsx twice produces different bytes - the format embeds timestamps - so a
#'   file hash would change on every re-save and answer nothing.
#'
#'   Coerced to a plain data frame first so the tibble/data.frame distinction
#'   does not enter the hash.
#'
#'   The hash describes the DGF *as loaded*, which is what the report rendered
#'   from. Note that is not the same as describing the file: `readxl` and
#'   `openxlsx` genuinely disagree about a DGF's empty columns (`readxl` infers
#'   an all-empty column as logical `NA`, `openxlsx` reads it as character), so
#'   the same .xlsx read two ways hashes differently. That is fine for the
#'   question this answers - "is this the same DGF as last render?" - because
#'   the templates always load it the same way. It is not a checksum of the
#'   file, and should not be compared across readers.
#' @noRd
hash_dgf <- function( dgf ) {
  if( ! is.data.frame(dgf) ) return( NULL )
  rlang::hash( as.data.frame( dgf ) )
}


#' Build the render record (internal)
#'
#' @inheritParams render_record
#' @return A named list, ready to serialise.
#' @noRd
build_record <- function( dgf, dgf_file, data_file, identify ) {

  quarto.v <- tryCatch( as.character( quarto::quarto_version() ),
                        error = function(e) NULL )

  rec <- list(
    datagoodr      = as.character( utils::packageVersion("datagoodr") ),
    rendered_utc   = format( Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC" ),
    r              = paste( R.version$major, R.version$minor, sep = "." ),
    quarto         = quarto.v,
    dgf_file       = publishable_path( dgf_file ),
    dgf_hash       = hash_dgf( dgf ),
    dgf_variables  = if( is.data.frame(dgf) ) nrow(dgf) else NULL,
    data_file      = publishable_path( data_file )
  )

  if( identify ) {
    info <- Sys.info()
    rec$user      <- unname( info[["user"]] )
    rec$host      <- unname( info[["nodename"]] )
    rec$dgf_path  <- if( is.null(dgf_file) ) NULL else
                     normalizePath( dgf_file, winslash = "/", mustWork = FALSE )
    rec$data_path <- if( is.null(data_file) ) NULL else
                     normalizePath( data_file, winslash = "/", mustWork = FALSE )
  }

  # drop absent fields rather than emit nulls
  rec[ ! vapply( rec, is.null, logical(1) ) ]
}


#' Record what produced this report
#'
#' Emits a provenance record for the current render: which DGF was used and its
#' content hash, the datagoodr/R/quarto versions, and when it ran. Call it from
#' a `results = "asis"` chunk in a report document.
#'
#' @param dgf The DGF data frame the report was rendered from.
#' @param dgf_file Path to the DGF, as the document received it (e.g.
#'   `params$dgf_file`). Optional.
#' @param data_file Path to the raw dataset, if one was supplied (e.g.
#'   `params$data_file`). Optional.
#' @param visible Logical; also print the record as a table in the report.
#'   Defaults to `FALSE`, which emits it only as an HTML comment.
#' @param identify Logical; add the username, hostname, and absolute paths.
#'   Defaults to `FALSE`. See Details.
#'
#' @return Invisibly, the record as a named list. Called for the side effect of
#'   printing.
#'
#' @details Written as an HTML comment - `<!-- datagoodr-render-record {...} -->`
#'   carrying JSON - so it travels with the file, survives
#'   `embed-resources: true`, and can be recovered later without appearing in
#'   the report. Set `visible = TRUE` to also show it as a table.
#'
#'   `identify = FALSE` by default because a Research Guide is meant to be
#'   shared: the username and absolute paths would be shipped to every
#'   recipient. The default record still answers "which DGF produced this?" via
#'   `dgf_hash`, which is computed from the DGF's contents - not from the file's
#'   bytes, which change on every re-save because .xlsx embeds timestamps.
#'
#'   `dgf_hash` describes the DGF *as the report loaded it*. Compare it across
#'   renders of the same document to see whether the DGF changed; it is not a
#'   checksum of the .xlsx and is not comparable across different readers.
#'
#' @examples
#' \dontrun{
#' # in a report chunk:
#' render_record( dgf, params$dgf_file, params$data_file )
#'
#' # show it in the report as well
#' render_record( dgf, params$dgf_file, visible = TRUE )
#'
#' # internal render where the audit trail matters more than the leak
#' render_record( dgf, params$dgf_file, identify = TRUE )
#' }
#'
#' @seealso [read_render_record()], to recover a record from a rendered file.
#' @export
render_record <- function( dgf, dgf_file = NULL, data_file = NULL,
                           visible = FALSE, identify = FALSE ) {

  rec  <- build_record( dgf, dgf_file, data_file, identify )
  json <- jsonlite::toJSON( rec, auto_unbox = TRUE )

  # A value containing "-->" would close the comment early and spill the record
  # into the page. > is ">" to any JSON reader, so this stays parseable.
  json <- gsub( "-->", "--\\\\u003e", json, fixed = FALSE )

  cat( "\n<!-- datagoodr-render-record ", json, " -->\n", sep = "" )

  if( visible ) {
    cat( "\n**RENDER RECORD**\n\n" )
    tab <- data.frame( FIELD = names(rec),
                       VALUE = vapply( rec, as.character, character(1) ),
                       stringsAsFactors = FALSE )
    print( knitr::kable( tab, row.names = FALSE ) )
    cat( "\n" )
  }

  invisible( rec )
}


#' Recover the render record from a rendered report
#'
#' Reads back the provenance record [render_record()] embedded in a rendered
#' `.html`, so you can ask which DGF produced a report you were handed.
#'
#' @param path Path to a rendered `.html` file.
#'
#' @return The record as a named list, or `NULL` when the file carries none
#'   (e.g. it was produced before the record chunk existed).
#'
#' @examples
#' \dontrun{
#' rec <- read_render_record( "research-guide.html" )
#' rec$dgf_hash
#' }
#'
#' @seealso [render_record()]
#' @export
read_render_record <- function( path ) {

  if( ! file.exists(path) )
  { stop( "No such file: ", path, call. = FALSE ) }

  txt <- paste( readLines( path, warn = FALSE ), collapse = "\n" )
  m   <- regmatches( txt,
           regexpr( "<!-- datagoodr-render-record .*? -->", txt ) )

  if( ! length(m) ) return( NULL )

  json <- sub( "^<!-- datagoodr-render-record ", "", m )
  json <- sub( " -->$", "", json )

  jsonlite::fromJSON( json )
}
