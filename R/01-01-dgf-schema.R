# The DGF schema, v2. One row per variable, columns grouped into prefix
# families that map to the workflow stages:
#
#   dd_        data dictionary        user-authored, portable
#   raw_       the raw CSV            storage + profiling, as received
#   raw_to_stable_transform          the lossless reformat rule (raw -> canonical)
#   stable_    the governed CSV       current state (storage / unit / format)
#   desired_data_import_rule         the coercion rule (governed -> desired type)
#   desired_   the interpretation     stage-invariant type / subtype / class
#   rg_        research guide         program-generated, JSON strings (see below)
#   validate_  validation rules       portable, declarative
#   prov_      provenance hashes      mirror the governed CSV's embedded payload
#
# The two bridges (raw_to_stable_transform, desired_data_import_rule) hold as_*
# rule names; the is_* detectors are their guards. Unit and format describe the
# CURRENT (stable) data; the desired_ fields describe the intended type only.
#
# Two decisions worth stating at the top:
#
# rg_* are JSON STRINGS, not list-columns. The DGF round-trips through .xlsx,
# and openxlsx silently flattens a list-column ({"mean":1} becomes "1"), so a
# nested R object cannot survive. The whole render pipeline already reads these
# as JSON (json_to_df / json_to_list), so JSON text is both what works and what
# is expected.
#
# desired_data_type carries the ONTOLOGY vocabulary (number / categorical /
# string / boolean / identifier / temporal), not R storage classes. It is what
# the render engine dispatches on. dg_type_of() maps an R class onto it.


#' Map an R storage class to an ontology data type (internal)
#'
#' The render engine dispatches on the ontology vocabulary, not R classes.
#' This is the one place the two are bridged, so the mapping lives here and
#' nothing else re-derives it.
#'
#' @param storage A character vector of R classes (e.g. from `sapply(df, class)`)
#'   or the legacy `vtype_class` values (`numeric`/`factor`/`logical`/`character`).
#'
#' @return A character vector of ontology `data_type` values: `number`,
#'   `categorical`, `boolean`, `string`, or `unknown` for anything unmapped.
#'
#' @details The four mappings that keep today's four renderers working:
#'   `numeric`/`double`/`integer` -> `number`, `factor`/`ordered` ->
#'   `categorical`, `logical` -> `boolean`, `character` -> `string`. Types the
#'   engine cannot yet render (dates, identifiers, ...) fall through to
#'   `unknown` and are handled gracefully at render rather than erroring.
#' @seealso the type ontology in `data-types/research_data_type_ontology.csv`
#' @noRd
dg_type_of <- function( storage ) {
  storage <- as.character( storage )
  vapply( storage, function( s ) {
    switch( s,
      numeric    = "number",
      double     = "number",
      integer    = "number",
      factor     = "categorical",
      ordered    = "categorical",
      logical    = "boolean",
      character  = "text",
      # already-ontology values pass through, so a column that detection has
      # marked identifier/temporal keeps that type rather than falling to string.
      identifier = "identifier",
      temporal   = "temporal",
      "unknown" )
  }, character(1), USE.NAMES = FALSE )
}


#' Column names of a v2 DGF, in order (internal)
#'
#' The single source of truth for the schema. `create_dgf_skeleton()` builds
#' from it and `inspect_dgf()` validates against it.
#'
#' @return A character vector of column names.
#' @noRd
dgf_schema_cols <- function() {
  c(
    # variable key
    "var_name",

    # dd_: data dictionary (user-authored, portable)
    "dd_vname_alias", "dd_vlabel", "dd_vdesc", "dd_f_levels", "dd_is_join_key",

    # raw_: the raw CSV as received (storage + profiling, no semantic type)
    "raw_data_storage", "raw_data_format", "raw_first5", "raw_duplicated",

    # raw -> stable bridge: the lossless reformat rule (as_* transform)
    "raw_to_stable_transform",

    # stable_: the governed/canonical CSV, current state
    "stable_data_storage", "stable_data_unit", "stable_data_format",

    # stable -> desired bridge: the coercion-into-type rule (as_* import)
    "desired_data_import_rule",

    # desired_: the intended interpretation (stage-invariant) - the four
    # ontology coordinates (type / subtype / class / representation format)
    "desired_data_type", "desired_data_subtype", "desired_data_class",
    "desired_data_format",

    # rg_: research guide artifacts (JSON strings)
    "rg_properties", "rg_preview", "rg_stats", "rg_graphics", "rg_max_chr",

    # validate_: validation rules/results (portable)
    "validate_rules", "validate_format",

    # prov_: cached provenance hashes
    "prov_start_hash", "prov_current_hash"
  )
}


#' Create an empty v2 DGF skeleton
#'
#' Builds an empty Data Governance File: one row per variable, every schema
#' column present. `create_dgf()` populates it; call this directly only to see
#' the schema or build a DGF by hand.
#'
#' @param varnames Character vector of variable names from the raw source.
#'
#' @return A data frame with one row per variable and every DGF column, all
#'   blank except `var_name`.
#'
#' @details Columns are grouped by prefix family — `dd_`, `raw_`, `stable_`,
#'   `rg_`, `validate_`, `prov_`. The `rg_*` columns are character (they hold
#'   JSON), not list-columns, so the DGF survives an `.xlsx` round trip.
#'
#' @seealso [create_dgf()], [inspect_dgf()]
#' @export
create_dgf_skeleton <- function( varnames ) {

  n  <- length( varnames )
  na <- rep( NA_character_, n )

  cols <- dgf_schema_cols()
  df <- as.data.frame(
    stats::setNames( rep( list(na), length(cols) ), cols ),
    stringsAsFactors = FALSE
  )
  df$var_name <- as.character( varnames )
  df
}
