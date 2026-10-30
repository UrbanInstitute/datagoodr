###########################################
### Project directories + versioned data + provenance manifest
###########################################
#
# A datagoodr *project* is a folder that keeps one dataset's whole life in one
# place: the raw file (written once, never touched), the DGF / DG.R / research
# guides at the root, and a `data/` folder holding numbered governed-CSV
# versions (v01, v02, ...) plus a `manifest.json` that logs, per version and
# per variable, what changed - the stabilizer and target type/format, the
# first-5 values at read vs after the transform, and the start/end content hash
# of each variable.
#
# The raw file is the floor: every version is built from the version below it
# (v01 from raw, v02 from v01, ...), so re-reading a version and finding a
# variable's hash no longer matches the end-hash recorded for the version below
# means the data was edited outside the workflow. A new version is written
# whenever stabilizing changes the data or the DGF carries a new conversion;
# functions that open the data default to the latest version.
#
# Reuses the existing machinery rather than reinventing it: hash_columns()
# (R/09), first_n() (R/00-utils), stabilize_data() + write_stable_csv() /
# read_stable_csv() (R/09, R/08), load_dgf() / is_absolute_path() /
# need_pkg() / log_message().

# ---- internal helpers -------------------------------------------------------

# Read any raw file (csv or xlsx) as an all-character data frame, matching how
# create_dgf() reads so hashes and first5 line up.
.dgp_read_all_chr <- function( path ) {
  ext <- tolower( tools::file_ext( path ) )
  if( ext %in% c("xlsx", "xls") ) {
    need_pkg( "readxl" )
    df <- readxl::read_excel( path, col_types = "text" )
  } else {
    df <- suppressMessages(
      readr::read_csv( path, col_types = readr::cols( .default = "c" ) ) )
  }
  as.data.frame( df, stringsAsFactors = FALSE, check.names = FALSE )
}

# The DGF's conversion signature: per variable, the stabilizer + the two legacy
# rules, keeping only variables that actually carry a conversion. Two versions
# with different signatures mean "new transformations were applied".
.dgp_conversions <- function( dgf ) {
  g <- function( col ) if( col %in% names(dgf) ) as.character( dgf[[col]] ) else rep( "", nrow(dgf) )
  stab <- g( "stabilizer" ); imp <- g( "desired_data_import_rule" ); raw <- g( "raw_to_stable_transform" )
  sig  <- trimws( paste( stab, imp, raw, sep = "|" ) )
  sig[ is.na(sig) ] <- ""
  keep <- nzchar( gsub( "|", "", sig, fixed = TRUE ) )   # any of the three set
  out  <- as.list( sig[keep] )
  names( out ) <- as.character( dgf$var_name )[keep]
  out
}

# Fold the manifest down to each variable's current end-hash (last version that
# touched it wins), so the next version knows the state it is building on.
.dgp_effective_hashes <- function( manifest ) {
  eff <- list()
  for( ver in manifest$versions )
    for( v in ver$variables )
      eff[[ v$var_name ]] <- v$hash_end
  eff
}

# Is `x` a path to a datagoodr project (a folder with data/manifest.json)?
.dgp_is_project <- function( x ) {
  is.character( x ) && length( x ) == 1 && dir.exists( x ) &&
    file.exists( file.path( x, "data", "manifest.json" ) )
}

.dgp_write_manifest <- function( project, manifest ) {
  jsonlite::write_json( manifest, project_paths( project )$manifest,
                        auto_unbox = TRUE, pretty = TRUE, null = "null" )
  invisible( manifest )
}

# ---- paths ------------------------------------------------------------------

#' Resolve the standard paths of a datagoodr project
#'
#' @param project Path to a project root (the folder created by
#'   [create_project()]).
#' @return A named list: `root`, `data`, `raw`, `manifest`, `dgf_xlsx`,
#'   `dgf_csv`.
#' @seealso [create_project()]
#' @export
project_paths <- function( project ) {
  root <- sub( "[\\/]+$", "", project )
  data <- file.path( root, "data" )
  list( root     = root,
        data     = data,
        raw      = file.path( data, "raw" ),
        manifest = file.path( data, "manifest.json" ),
        dgf_xlsx = file.path( root, "DGF.xlsx" ),
        dgf_csv  = file.path( root, "DGF.csv" ) )
}

#' The raw file of a project
#'
#' @param project Path to a project root.
#' @return Path to the single file under `data/raw/` (the original, untouched
#'   input).
#' @export
raw_path <- function( project ) {
  rawdir <- project_paths( project )$raw
  f <- list.files( rawdir, full.names = TRUE )
  if( length(f) == 0 ) stop( "No raw file in ", rawdir, call. = FALSE )
  if( length(f) >  1 ) warning( "More than one file in ", rawdir, "; using the first.", call. = FALSE )
  f[1]
}

#' List the data versions of a project
#'
#' @param project Path to a project root.
#' @return Character vector of version labels (`"v01"`, `"v02"`, ...) in order,
#'   or `character(0)` when none have been written yet.
#' @export
list_versions <- function( project ) {
  data <- project_paths( project )$data
  if( ! dir.exists( data ) ) return( character(0) )
  f <- list.files( data, pattern = "^v[0-9]+\\.csv$" )
  sort( sub( "\\.csv$", "", f ) )
}

#' The latest data version of a project
#'
#' @param project Path to a project root.
#' @return The highest version label (e.g. `"v02"`), or `NA_character_` when no
#'   version has been written yet.
#' @export
latest_version <- function( project ) {
  v <- list_versions( project )
  if( length(v) == 0 ) NA_character_ else v[ length(v) ]
}

#' Resolve a version to a file path
#'
#' @param project Path to a project root.
#' @param version A version label (`"v01"`), or `"latest"` (the default). When
#'   `"latest"` and no version exists yet, the raw file path is returned.
#' @return A file path.
#' @export
version_path <- function( project, version = "latest" ) {
  pp <- project_paths( project )
  if( identical( version, "latest" ) ) {
    v <- latest_version( project )
    if( is.na(v) ) return( raw_path( project ) )
    version <- v
  }
  file.path( pp$data, paste0( version, ".csv" ) )
}

# ---- manifest read ----------------------------------------------------------

#' Read a project's version manifest
#'
#' @param project Path to a project root.
#' @return The manifest as a nested list (see [create_version()] for its shape).
#' @export
read_manifest <- function( project ) {
  mf <- project_paths( project )$manifest
  if( ! file.exists( mf ) ) stop( "No manifest at ", mf, call. = FALSE )
  jsonlite::read_json( mf, simplifyVector = FALSE )
}

# ---- open data (default to latest) ------------------------------------------

#' Read a project's data, defaulting to the latest version
#'
#' The one entry point the project workflow uses to open data, so every caller
#' defaults to the newest version. The raw file is read as plain text; a `vNN`
#' governed CSV is read back through [read_stable_csv()].
#'
#' @param project Path to a project root.
#' @param version A version label, or `"latest"` (the default).
#' @return A data frame.
#' @seealso [version_path()], [read_stable_csv()]
#' @export
read_data <- function( project, version = "latest" ) {
  p <- version_path( project, version )
  if( identical( normalizePath( p, mustWork = FALSE ),
                 normalizePath( raw_path( project ), mustWork = FALSE ) ) )
    .dgp_read_all_chr( p )
  else
    read_stable_csv( p )$data
}

# ---- scaffold ---------------------------------------------------------------

#' Create a datagoodr project directory
#'
#' Scaffolds a project folder for one dataset: a `data/raw/` holding the
#' original file (copied in once and never touched afterwards) and a seeded
#' `data/manifest.json`. The DGF, `DG.R` and research guides are created later
#' at the project root (see [create_project_dgf()]).
#'
#' @param raw Path to the original data file (csv or xlsx).
#' @param name Project folder name. Defaults to `"datagoodr"`.
#' @param dir Parent directory the project is created in. Defaults to `"."`.
#' @param overwrite Overwrite an existing project folder? Defaults to `FALSE`
#'   (it refuses, to protect an existing raw file and history).
#' @return The project root path, invisibly.
#' @seealso [create_project_dgf()], [create_version()]
#' @export
create_project <- function( raw, name = "datagoodr", dir = ".", overwrite = FALSE ) {
  if( ! file.exists( raw ) ) stop( "Raw file not found: ", raw, call. = FALSE )

  root <- if( is_absolute_path( name ) ) name else file.path( dir, name )
  if( dir.exists( root ) && ! overwrite )
    stop( "Project folder already exists: ", root,
          "\nPass overwrite = TRUE to reuse it (the raw file is never rewritten).",
          call. = FALSE )

  pp <- project_paths( root )
  for( d in c( pp$root, pp$data, pp$raw ) )
    if( ! dir.exists( d ) ) dir.create( d, recursive = TRUE )

  dest <- file.path( pp$raw, basename( raw ) )
  if( ! file.exists( dest ) ) file.copy( raw, dest )   # written once, never again

  raw_df <- .dgp_read_all_chr( dest )
  manifest <- list(
    project           = basename( pp$root ),
    created           = format( Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC" ),
    datagoodr_version = as.character( utils::packageVersion( "datagoodr" ) ),
    raw = list( file  = file.path( "raw", basename( dest ) ),
                sha   = rlang::hash( raw_df ),
                read  = format( Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC" ),
                n_row = nrow( raw_df ),
                n_col = ncol( raw_df ) ),
    versions = list() )
  .dgp_write_manifest( root, manifest )

  log_message( paste0( "Created project ", pp$root, " (raw: ", basename(dest), ")" ),
               logfile = file.path( pp$root, "datagoodr.txt" ), console = TRUE )
  invisible( pp$root )
}

# ---- version creation -------------------------------------------------------

#' Stabilize the project's data into a new governed version
#'
#' Reads the current latest version (the raw file on the first run), applies the
#' DGF's rules with [stabilize_data()], and - when the data changed or the DGF
#' carries a new conversion - writes the next numbered governed CSV
#' (`data/vNN.csv`) and appends a manifest entry. The first version (`v01`) logs
#' every variable; later versions log only the variables that changed. A
#' variable whose read-hash no longer matches the end-hash recorded for the
#' version below it is flagged as changed outside the workflow.
#'
#' @param project Path to a project root.
#' @param dgf The DGF to stabilize with: a data frame, or a path. Defaults to
#'   the project root's `DGF.xlsx`.
#' @param note Optional free-text note stored on the version entry.
#' @param env Environment in which custom `read_*`/`as_*` rules are resolved.
#' @return The path of the version in force after the call (the new version, or
#'   the existing latest when nothing changed), invisibly.
#' @seealso [create_project()], [create_project_dgf()], [read_manifest()]
#' @export
create_version <- function( project, dgf = NULL, note = NULL, env = parent.frame() ) {
  pp <- project_paths( project )
  if( is.null( dgf ) ) dgf <- pp$dgf_xlsx
  if( is.character( dgf ) && length( dgf ) == 1 ) dgf <- load_dgf( dgf )
  stopifnot( is.data.frame( dgf ), "var_name" %in% names( dgf ) )

  manifest <- read_manifest( project )
  vers     <- list_versions( project )
  n        <- length( vers )
  prev_end <- .dgp_effective_hashes( manifest )

  # --- read the source (raw on first run, else the latest version) ----------
  # `lineage_start` is the parent's embedded pre-write current_hash, passed to
  # write_stable_csv so the governed CSV's in-file start_hash chains exactly.
  # `hash_start` is the read-back hash of the source, used for the manifest and
  # for external-change detection (compared, read-to-read, against the version
  # below's recorded hash_end - so it is immune to write/read representation
  # drift such as non-ASCII re-encoding).
  if( n == 0 ) {
    source_df     <- .dgp_read_all_chr( raw_path( project ) )
    source_label  <- manifest$raw$file
    lineage_start <- hash_columns( source_df )
  } else {
    parent_read   <- read_stable_csv( version_path( project, vers[n] ) )
    source_df     <- parent_read$data
    source_label  <- paste0( vers[n], ".csv" )
    lineage_start <- parent_read$meta$provenance$current_hash
  }

  hash_start  <- hash_columns( source_df )
  first5_read <- sapply( source_df, first_n )

  # --- stabilize ------------------------------------------------------------
  stabilized <- stabilize_data( source_df, dgf, env = env )
  end_pre    <- hash_columns( stabilized )

  # --- decide whether a new version is warranted ----------------------------
  conv       <- .dgp_conversions( dgf )
  last_conv  <- if( n > 0 ) manifest$versions[[n]]$conversions else NULL
  new_conv   <- n > 0 && ! identical( conv, last_conv )
  changed_pre <- vapply( names( end_pre ), function( v )
    is.null( prev_end[[v]] ) || ! identical( prev_end[[v]], end_pre[[v]] ), logical(1) )
  external   <- vapply( names( hash_start ), function( v )
    ! is.null( prev_end[[v]] ) && ! identical( hash_start[[v]], prev_end[[v]] ), logical(1) )

  write_it <- n == 0 || any( changed_pre ) || new_conv || any( external )
  if( ! write_it ) {
    log_message( "No data or conversion change; no new version written.",
                 logfile = file.path( pp$root, "datagoodr.txt" ), console = TRUE )
    return( invisible( version_path( project, "latest" ) ) )
  }

  # --- write the next governed version --------------------------------------
  next_label <- sprintf( "v%02d", n + 1 )
  next_path  <- file.path( pp$data, paste0( next_label, ".csv" ) )
  write_stable_csv( stabilized, next_path, dgf = dgf, start_hash = lineage_start )

  # round-trip the written file so end-hashes match the next run's read-hashes
  reread      <- read_stable_csv( next_path )$data
  hash_end    <- hash_columns( reread )
  first5_after <- sapply( stabilized, first_n )

  # --- build the manifest entry (v01: all vars; later: only changed) --------
  g <- function( col, v ) {
    if( ! col %in% names(dgf) ) return( "" )
    val <- dgf[[col]][ match( v, dgf$var_name ) ]
    if( length(val) == 0 || is.na(val) ) "" else as.character( val )
  }
  var_rows <- list(); changed_names <- character(0)
  for( v in names( hash_end ) ) {
    changed <- is.null( prev_end[[v]] ) || ! identical( prev_end[[v]], hash_end[[v]] )
    if( n > 0 && ! changed ) next           # later versions: only changed vars
    changed_names <- c( changed_names, v )
    var_rows[[ length(var_rows) + 1 ]] <- list(
      var_name      = v,
      stabilizer    = g( "stabilizer", v ),
      target_type   = g( "desired_data_type", v ),
      target_format = g( "desired_format_style", v ),
      first5_read   = unname( first5_read[[v]]  %||% "" ),
      first5_after  = unname( first5_after[[v]] %||% "" ),
      hash_start    = unname( hash_start[[v]] ),
      hash_end      = unname( hash_end[[v]] ),
      changed       = changed )
  }

  entry <- list(
    version                  = next_label,
    created                  = format( Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC" ),
    source                   = source_label,
    data_file                = paste0( next_label, ".csv" ),
    dgf_version              = as.character( utils::packageVersion( "datagoodr" ) ),
    external_change_detected = any( external ),
    changed_vars             = as.list( changed_names ),
    conversions              = conv,
    note                     = note %||% "",
    variables                = var_rows )

  manifest$versions <- c( manifest$versions, list( entry ) )
  .dgp_write_manifest( project, manifest )

  msg <- paste0( "Wrote ", next_label, " (", length(changed_names), " var(s) changed",
                 if( any(external) ) "; EXTERNAL change detected" else "", ").")
  log_message( msg, logfile = file.path( pp$root, "datagoodr.txt" ), console = TRUE )
  invisible( next_path )
}

#' Build the DGF and the first data version for a project
#'
#' The project-aware entry point that creates the DGF at the project root (via
#' [create_dgf()], reading the raw file) and then stabilizes it into `v01`
#' (via [create_version()]), seeding the manifest in one call.
#'
#' @param project Path to a project root (from [create_project()]).
#' @param ... Passed to [create_dgf()].
#' @param file DGF file stem. Defaults to `"DGF"` (so `DGF.xlsx` / `DGF.csv` at
#'   the root).
#' @param open Open the DGF when written? Defaults to `FALSE`.
#' @param env Environment for custom rule resolution in [create_version()].
#' @return The path of `v01`, invisibly.
#' @seealso [create_project()], [create_version()]
#' @export
create_project_dgf <- function( project, ..., file = "DGF", open = FALSE,
                                env = parent.frame() ) {
  pp <- project_paths( project )
  create_dgf( raw_path( project ), dir = pp$root, file = file, open = open, ... )
  create_version( project, dgf = file.path( pp$root, paste0( file, ".xlsx" ) ),
                  env = env )
}
