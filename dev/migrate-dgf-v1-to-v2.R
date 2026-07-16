# One-off migration: rename a v1 DGF (flat 22-column schema) to the v2 six-
# family schema, IN PLACE, so hand-curation survives. Not a compatibility shim
# and not part of the package - run once against the working-example fixtures.
#
#   Rscript dev/migrate-dgf-v1-to-v2.R working-example/DGF-V2.xlsx
#
# Re-runnable: a file already in v2 is detected and left alone.

suppressMessages({
  library(openxlsx)
})

# Load dg_type_of + the schema without installing the package. Run from the
# package root (where dev/ and R/ live).
source("R/01-01-dgf-schema.R")

# v1 -> v2 column rename (drops are handled separately)
rename_map <- c(
  vname           = "var_name",
  vlabel          = "dd_vlabel",
  vdesc           = "dd_vdesc",
  vname_alias     = "dd_vname_alias",
  dd_f_level      = "dd_f_levels",
  raw_type        = "raw_data_storage",
  vconvert        = "raw_data_import_rule",
  duplicates      = "raw_duplicated",
  vtype           = "stable_data_storage",
  vformat         = "stable_data_format",
  dgf_standardize = "stable_data_transform",
  vlength         = "rg_max_chr",
  rg_hash         = "prov_current_hash",
  dgf_validate    = "validate_rules"
  # vtype_class handled specially (value re-map -> stable_data_type)
  # vscope, vloc dropped
)

migrate_dgf <- function( path ) {

  old <- read.xlsx( path, sheet = 1 )

  if ( "var_name" %in% names(old) && "stable_data_type" %in% names(old) ) {
    message( basename(path), " already v2; skipping." )
    return( invisible(FALSE) )
  }

  n <- nrow( old )
  blank <- rep( "", n )
  new <- data.frame( row.names = seq_len(n) )

  # 1. renamed columns carry their curated values across
  for ( from in names(rename_map) ) {
    if ( from %in% names(old) ) new[[ rename_map[[from]] ]] <- old[[ from ]]
  }

  # 2. columns whose name is UNCHANGED between v1 and v2 (raw_first5 and the
  #    rg_* artifacts) - carry them too, or they would be blanked out. This was
  #    the migration's first bug: dropping rg_preview left the render with NA.
  for ( col in intersect( names(old), dgf_schema_cols() ) ) {
    if ( is.null( new[[col]] ) ) new[[col]] <- old[[col]]
  }

  # 3. derived: vtype_class value -> ontology stable_data_type; raw_data_type
  #    from the raw storage class
  new$stable_data_type <- dg_type_of( old$vtype_class )
  new$raw_data_type    <- dg_type_of( old$raw_type )

  # 4. any remaining schema column is genuinely new -> blank
  for ( col in dgf_schema_cols() )
    if ( is.null( new[[col]] ) ) new[[col]] <- blank

  new <- new[ , dgf_schema_cols() ]

  # write both the .xlsx (source of truth) and the .csv mirror
  wb <- createWorkbook()
  addWorksheet( wb, "DGF" )
  writeData( wb, "DGF", new )
  saveWorkbook( wb, path, overwrite = TRUE )
  write.csv( new, sub( "\\.xlsx$", ".csv", path ), row.names = FALSE, na = "" )

  message( "Migrated ", basename(path), ": ", ncol(old), " -> ", ncol(new),
           " columns, ", n, " variables." )
  invisible( TRUE )
}

args <- commandArgs( trailingOnly = TRUE )
if ( length(args) > 0 ) for ( p in args ) migrate_dgf( p )
