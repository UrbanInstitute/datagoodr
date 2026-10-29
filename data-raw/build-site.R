###############################################################################
### Build the pkgdown documentation site
###############################################################################
# Run from the package root:
#
#   Rscript data-raw/build-site.R               # install, then build the site
#   Rscript data-raw/build-site.R --no-install  # build against what is installed
#
# Why this exists rather than a bare pkgdown::build_site():
#
#   PANDOC  Rscript carries no pandoc of its own -- RStudio supplies one when
#           you build from the IDE, so the same call that works there fails
#           from the command line with "Pandoc not available". We fall back to
#           the copy that ships with quarto.
#
#   SYNCED  pkgdown writes vignettes/--find-assets.html once per article and
#           deletes it again. Inside a synced folder (Dropbox, OneDrive, ...)
#           that delete loses a race with the sync client and fails EBUSY; the
#           next article then aborts on EEXIST, part way through the build. So
#           when the package lives in a synced folder we copy the sources out
#           to a scratch folder, build there, and move docs/ back. That folder
#           has to sit at a SHORT path: many Windows calls still cap out at
#           260 characters, and pkgdown's nested paths are long.
#
# Rebuild the example guides with data-raw/example-guides.R, not from here --
# they are committed artifacts, not site output.

args       <- commandArgs( trailingOnly = TRUE )
do.install <- ! "--no-install" %in% args

pkg.root <- normalizePath( ".", winslash = "/", mustWork = TRUE )
if( ! file.exists( file.path( pkg.root, "DESCRIPTION" ) ) )
{ stop( "Run this from the package root (no DESCRIPTION in ", pkg.root, ").",
        call. = FALSE ) }


## pandoc ---------------------------------------------------------------------
# rmarkdown finds pandoc on PATH or via RSTUDIO_PANDOC; when it cannot, point
# it at quarto's bundled copy (quarto on PATH first, then RStudio's).
if( ! rmarkdown::pandoc_available() ) {

  quarto.bin <- Sys.which( "quarto" )
  guesses <- c(
    if( nzchar(quarto.bin) ) file.path( dirname(quarto.bin), "tools" ),
    "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools",
    "C:/Program Files/Quarto/bin/tools",
    "/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools",
    "/usr/lib/rstudio/bin/quarto/bin/tools" )

  has.pandoc <- function( d )
    nzchar(d) && any( file.exists( file.path( d, c("pandoc", "pandoc.exe") ) ) )

  found <- Find( has.pandoc, guesses )
  if( is.null(found) )
  { stop( "No pandoc. Install quarto, or set RSTUDIO_PANDOC to a folder ",
          "holding a pandoc binary.", call. = FALSE ) }

  Sys.setenv( RSTUDIO_PANDOC = found )
  if( ! rmarkdown::pandoc_available() )
  { stop( "Found a pandoc at ", found, " but rmarkdown still cannot use it.",
          call. = FALSE ) }
}
message( "pandoc ", as.character( rmarkdown::pandoc_version() ) )


## where to build -------------------------------------------------------------
# A synced folder breaks the build (see SYNCED above), so build elsewhere.
synced <- grepl( "dropbox|onedrive|google[ -]?drive|icloud|box sync",
                 pkg.root, ignore.case = TRUE )

# Everything pkgdown reads. Deliberately NOT docs/ (the destination), .git,
# tests, or the data working folders -- copying those just costs time.
sources <- function( root ) {
  want <- c( "DESCRIPTION", "NAMESPACE", "_pkgdown.yml", "README.md", "NEWS.md",
             "R", "man", "vignettes", "inst", "data", "pkgdown" )
  want <- c( want, list.files( root, pattern = "^LICENSE" ) )
  file.path( root, unique(want) )[ file.exists( file.path( root, unique(want) ) ) ]
}

if( synced ) {

  # Short on purpose: tempdir() under a deep profile path overflows PATH_MAX
  # once pkgdown nests its own folders under it.
  work <- file.path( dirname( tempdir() ), "pkgdown-build" )
  unlink( work, recursive = TRUE, force = TRUE )
  dir.create( work, recursive = TRUE, showWarnings = FALSE )
  if( nchar(work) > 60 )
  { warning( "Scratch path is long (", nchar(work), " chars); the build may ",
             "hit the Windows 260-character limit." ) }

  message( "Synced folder: building in ", work )
  ok <- file.copy( sources( pkg.root ), work, recursive = TRUE )
  if( ! all(ok) ) stop( "Could not copy the sources to ", work, call. = FALSE )

} else {
  work <- pkg.root
}


## build ----------------------------------------------------------------------
# The articles run the package's own code, so install this checkout first
# unless the caller says the installed copy is already current.
if( do.install )
{ devtools::install( pkg.root, quick = TRUE, upgrade = "never", quiet = TRUE,
                     build = FALSE ) }

pkgdown::build_site( pkg = work, preview = FALSE, install = FALSE,
                     new_process = FALSE )


## move the site back ---------------------------------------------------------
if( synced ) {

  built <- file.path( work, "docs" )
  dest  <- file.path( pkg.root, "docs" )
  dir.create( dest, recursive = TRUE, showWarnings = FALSE )

  # File by file, rather than clearing docs/ and copying the new site in:
  # deleting a few hundred files inside a synced folder half-succeeds -- the
  # sync client holds some of them open -- and what it leaves behind is a
  # gutted site. So overwrite what this build produced, then prune only the
  # pages it no longer produces.
  rel  <- list.files( built, recursive = TRUE, all.files = TRUE, no.. = TRUE )
  dirs <- setdiff( unique( dirname(rel) ), "." )
  for( d in dirs )
  { dir.create( file.path( dest, d ), recursive = TRUE, showWarnings = FALSE ) }

  ok <- file.copy( file.path( built, rel ), file.path( dest, rel ),
                   overwrite = TRUE )
  if( ! all(ok) )
  { stop( "Built the site in ", built, " but could not copy ", sum(!ok),
          " file(s) into docs/: ",
          paste( head( rel[!ok], 3 ), collapse = ", " ),
          ". The site there is complete; copy it over by hand.",
          call. = FALSE ) }

  stale <- setdiff( list.files( dest, recursive = TRUE, all.files = TRUE,
                                no.. = TRUE ), rel )
  if( length(stale) ) {
    message( "Pruning ", length(stale), " file(s) the build no longer makes" )
    unlink( file.path( dest, stale ) )
  }

  unlink( work, recursive = TRUE, force = TRUE )
  message( "Site copied to ", dest )
}

message( "Done: ", length( list.files( file.path( pkg.root, "docs" ),
                                       recursive = TRUE ) ), " files in docs/" )
