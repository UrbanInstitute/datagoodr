# Step 2: validate a DGF before it is used to render a Research Guide.
# After a user edits DGF fields by hand (Step 1 -> Step 2), inspect_dgf()
# checks that the file is still in a shape that Step 3 can render.

# Columns every DGF produced by create_dgf() must contain. The full v2 schema
# is defined once in dgf_schema_cols() (R/01-01-dgf-schema.R); inspect_dgf()
# validates against it so the two cannot drift.
.dgf_required_cols <- dgf_schema_cols()

# Columns whose non-empty cells must contain valid JSON. Note that rg_preview
# is intentionally excluded: it holds a " ;; "-delimited plain-text list of
# example values, not JSON.
.dgf_json_cols <- c("dd_f_levels", "rg_properties", "rg_stats", "rg_graphics")

# desired_data_type values Step 3 has a renderer + layout for (see
# R/03-01-layouts.R and the ontology). identifier/temporal are specified but
# not yet renderable.
.dgf_valid_classes <- c("number", "text", "string", "categorical", "boolean",
                        "identifier", "temporal")


#' Validate a DGF before rendering (Step 2)
#'
#' Inspects a Data Governance File and checks that it is still well formed
#' after any manual edits, so that Step 3 can render it without error. The
#' following checks are run:
#'
#' \itemize{
#'   \item all required DGF columns are present;
#'   \item every `desired_data_type` value is one Step 3 can render
#'     (number, string, categorical, boolean);
#'   \item all non-empty cells in the JSON columns (`dd_f_levels`,
#'     `rg_properties`, `rg_stats`, `rg_graphics`) contain valid JSON;
#'   \item every function named in the `desired_data_import_rule` and `stable_data_format` columns is
#'     defined and callable;
#'   \item every variable has a non-empty `prov_current_hash`.
#' }
#'
#' @param dgf A DGF data frame, or a path to a DGF `.xlsx` file (read with
#'   [load_dgf()]).
#' @param convert_env Environment in which to look for the functions named in
#'   the `desired_data_import_rule`/`stable_data_format` columns. Defaults to the caller's environment,
#'   so functions you have sourced (e.g. from a project `dgf.R`) are found.
#' @param verbose Logical; if `TRUE` (default) a human-readable report is
#'   printed to the console.
#'
#' @return Invisibly, a list with `valid` (a single logical) and `problems`
#'   (a named list describing any issues found). Called mainly for its report.
#' @seealso [validate_json()], [show_invalid()], [create_dgf()]
#' @export
inspect_dgf <- function( dgf, convert_env = parent.frame(), verbose = TRUE ) {

  if( is.character(dgf) && length(dgf) == 1 )
  { dgf <- load_dgf( dgf ) }

  problems <- list()
  say <- function(...) if( verbose ) cat( ... )

  say( "\nInspecting DGF (", nrow(dgf), " variables )\n",
       "----------------------------------------\n", sep = "" )

  ## 1. required columns -----------------------------------------------------
  missing.cols <- setdiff( .dgf_required_cols, names(dgf) )
  if( length(missing.cols) > 0 )
  {
    problems$missing_columns <- missing.cols
    say( "[FAIL] missing columns: ", paste(missing.cols, collapse=", "), "\n" )
  } else {
    say( "[ ok ] all required columns present\n" )
  }

  ## 2. variable classes -----------------------------------------------------
  if( "desired_data_type" %in% names(dgf) )
  {
    bad.class <- ! dgf$desired_data_type %in% .dgf_valid_classes
    if( any(bad.class) )
    {
      problems$invalid_vtype_class <-
        stats::setNames( dgf$desired_data_type[bad.class], dgf$var_name[bad.class] )
      say( "[FAIL] unrenderable desired_data_type for: ",
           paste(dgf$var_name[bad.class], collapse=", "), "\n" )
    } else {
      say( "[ ok ] all desired_data_type values are renderable\n" )
    }
  }

  ## 3. JSON columns ---------------------------------------------------------
  json.cols <- intersect( .dgf_json_cols, names(dgf) )
  bad.json <- list()
  for( col in json.cols )
  {
    vals <- dgf[[col]]
    filled <- ! ( is.na(vals) | trimws(as.character(vals)) == "" )
    if( ! any(filled) ) next
    ok <- validate_json( vals[filled] )
    if( ! all(ok) )
    {
      bad.vars <- dgf$var_name[filled][ ! ok ]
      bad.json[[col]] <- bad.vars
      say( "[FAIL] invalid JSON in ", col, " for: ",
           paste(bad.vars, collapse=", "), "\n" )
    }
  }
  if( length(bad.json) > 0 ) { problems$invalid_json <- bad.json }
  else { say( "[ ok ] all JSON cells are valid\n" ) }

  ## 4. referenced convert / format functions --------------------------------
  fx.cols <- intersect( c("desired_data_import_rule", "stable_data_format"), names(dgf) )
  fx.named <- unique( unlist( lapply( dgf[fx.cols], as.character ) ) )
  fx.named <- fx.named[ ! ( is.na(fx.named) | trimws(fx.named) == "" ) ]
  fx.named <- gsub( "\\(\\)", "", fx.named )
  missing.fx <- fx.named[ ! vapply( fx.named,
      function(f) exists( f, mode = "function", envir = convert_env ),
      logical(1) ) ]
  if( length(missing.fx) > 0 )
  {
    problems$missing_functions <- missing.fx
    say( "[FAIL] undefined convert/format functions: ",
         paste0( missing.fx, "()", collapse=", " ), "\n" )
  } else {
    say( "[ ok ] all convert/format functions are defined\n" )
  }

  ## 5. hash column ----------------------------------------------------------
  if( "prov_current_hash" %in% names(dgf) )
  {
    no.hash <- is.na(dgf$prov_current_hash) | trimws(as.character(dgf$prov_current_hash)) == ""
    if( any(no.hash) )
    {
      problems$missing_hash <- dgf$var_name[no.hash]
      say( "[FAIL] missing prov_current_hash for: ",
           paste(dgf$var_name[no.hash], collapse=", "), "\n" )
    } else {
      say( "[ ok ] all variables have an prov_current_hash\n" )
    }
  }

  valid <- length(problems) == 0
  say( "----------------------------------------\n",
       if( valid ) "DGF is valid.\n\n" else
         paste0( "DGF has ", length(problems), " problem type(s); see above.\n\n" ),
       sep = "" )

  return( invisible( list( valid = valid, problems = problems ) ) )
}
