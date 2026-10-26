##############################
### v7 stabilizer planning (DRAFT)
###############################
## THE v7 SEAM. formex v7 models a value's format as a triple
## (semantic_type, format_style, unit_type) and exposes stabilization as a graph
## search over read_/write_/convert_ edges (formex/R/22-fx-transform-path.R,
## ONTOLOGY-V7-PLAN.md). This file is datagoodr's adapter over that API: it turns
## a column's guessed format and the human's desired format into a transform PLAN,
## and reads the plan back into DGF cells (stabilizer, stable_first5, the needed
## flags). Nothing here is detection and nothing reaches formex internals.
##
## STATUS: DRAFT, intentionally not wired into create_dgf(). Two formex v7 pieces
## are not landed yet -- the detector does not resolve format_style/unit_type on
## $route, and fx_transforms() is still a seed registry -- so these functions are
## callable but cannot be exercised end to end until formex v7 is installed. Every
## formex v7 call is gated on .formex_has_v7(); on an older formex this module is
## inert and the v6 path (R/01-06-guess-dgf-types.R, dgf_schema_cols()) is
## untouched. See dev/v7-dgf-integration-plan.md for the column map and the
## testing gate.


## Is an installed formex new enough to carry the v7 transform-path API? Checked
## by export name so the draft is safe to load against either generation.
#' @keywords internal
#' @noRd
.formex_has_v7 <- function() {
  if (!requireNamespace("formex", quietly = TRUE)) return(FALSE)
  need <- c("fx_format", "fx_plan_transform", "fx_transformable", "fx_apply_plan")
  all(need %in% getNamespaceExports("formex"))
}


## Forward-compat shim for the one place the formex generations differ: the
## route's leaf axes. v7 emits format_style + unit_type directly; v6 emits
## format_label + dd_unit, from which we derive the axes. Everything downstream
## reads THIS, so the detector landing in formex changes only this function.
##
## v6 derivation: format_label is mostly a copy of semantic_type and only
## sometimes a real style (range/{comma_pair,to_range}, coordinate/{dms,iso6709}).
## When it equals the semantic_type it carries no style, so we return NA; dd_unit
## becomes the unit axis.
#' @keywords internal
#' @noRd
.route_axes <- function(r) {
  if (is.null(r)) return(list(format_style = NA_character_, unit_type = NA_character_))
  # v7: axes present on the route record
  if (!is.null(r$format_style) || !is.null(r$unit_type))
    return(list(format_style = r$format_style %||% NA_character_,
                unit_type    = r$unit_type    %||% NA_character_))
  # v6: derive from format_label / dd_unit
  fl <- r$format_label %||% NA_character_
  st <- r$semantic_type %||% NA_character_
  style <- if (!is.na(fl) && !identical(fl, st)) fl else NA_character_
  list(format_style = style, unit_type = r$dd_unit %||% NA_character_)
}

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0L) b else a


## Build a formex v7 fx_format descriptor from three DGF cells. Blank strings are
## normalized to NA so an unresolved axis reads as "no constraint" in the search.
#' @keywords internal
#' @noRd
.dgf_fx_format <- function(semantic_type, format_style = NA, unit_type = NA) {
  if (!.formex_has_v7()) stop("formex v7 transform-path API not available")
  na_if_blank <- function(x) if (is.na(x) || !nzchar(trimws(x))) NA_character_ else x
  formex::fx_format(semantic_type,
                    format_style = na_if_blank(as.character(format_style)),
                    unit_type    = na_if_blank(as.character(unit_type)))
}


## Render an fx_plan's edge path as the DGF stabilizer cell:
##   read_<style> :: [convert_<u>_<u>] :: write_<style>
## An identity plan (from == to) renders to "" -- no stabilizer needed.
#' @keywords internal
#' @noRd
.render_stabilizer <- function(plan) {
  if (!length(plan$path)) return("")
  steps <- vapply(plan$path, function(e) e$name, character(1))
  paste0("{{ ", paste(steps, collapse = " :: "), " }}")
}


#' Plan the stabilizer for one DGF variable (v7, DRAFT)
#'
#' Expresses the column's guessed format and the human's desired format as
#' `formex::fx_format()` descriptors and asks `formex::fx_plan_transform()`
#' whether -- and how -- one can be turned into the other. Reads the plan back
#' into the DGF cells the v7 schema adds.
#'
#' @param guess A list with `semantic_type`, `format_style`, `unit_type` -- the
#'   column as detected (see [.route_axes()]).
#' @param desired A list with the same three fields -- the human's target form.
#' @param raw_first5 Optional character vector of raw example values; when the
#'   plan is executable they are run through it to populate `stable_first5`.
#'
#' @return A one-row data frame with `stabilizer`, `stabilizer_needed`,
#'   `stabilizer_status`, and `stable_first5`. On a formex without the v7 API,
#'   every field is blank (the draft is inert).
#'
#' @details `stabilizer_status` is one of: `ready` (a path exists and its edges
#'   are executable), `identity` (already in the desired form), or
#'   `not-transformable` with the search's reason (no registered path -- e.g. a
#'   fiscal->calendar year with no converter). `stable_first5` is populated only
#'   when the status is `ready`.
#' @seealso [.route_axes()], dev/v7-dgf-integration-plan.md
#' @keywords internal
#' @noRd
plan_stabilizer <- function(guess, desired, raw_first5 = NULL) {
  blank <- data.frame(stabilizer = "", stabilizer_needed = "",
                      stabilizer_status = "", stable_first5 = "",
                      stringsAsFactors = FALSE)
  if (!.formex_has_v7()) return(blank)

  from <- .dgf_fx_format(guess$semantic_type,   guess$format_style,   guess$unit_type)
  to   <- .dgf_fx_format(desired$semantic_type, desired$format_style, desired$unit_type)
  plan <- formex::fx_plan_transform(from, to)

  if (!isTRUE(plan$transformable)) {
    blank$stabilizer_needed <- "unknown"
    blank$stabilizer_status <- paste0("not-transformable: ", plan$reason)
    return(blank)
  }

  cell   <- .render_stabilizer(plan)
  needed <- if (nzchar(cell)) "yes" else "no"
  status <- if (nzchar(cell)) "ready" else "identity"

  first5 <- ""
  if (nzchar(cell) && !is.null(raw_first5) && length(raw_first5)) {
    ## fx_apply_plan can legitimately fail on a value the seed edges do not
    ## cover; a failed PREVIEW must never abort DGF construction, so trap it.
    first5 <- tryCatch(
      paste(as.character(formex::fx_apply_plan(raw_first5, plan)), collapse = " ;; "),
      error = function(e) paste0("(preview failed: ", conditionMessage(e), ")")
    )
  }

  data.frame(stabilizer = cell, stabilizer_needed = needed,
             stabilizer_status = status, stable_first5 = first5,
             stringsAsFactors = FALSE)
}


#' Column names of a v7 DGF, in order (DRAFT)
#'
#' The format-first schema: the type+class cluster collapses to a guessed leaf
#' label split across the `format_style` / `unit_type` axes, the stabilizer is a
#' `read :: [convert] :: write` plan, and `stable_first5` shows its effect. Not
#' yet the schema `create_dgf()` builds -- see the testing gate in
#' dev/v7-dgf-integration-plan.md.
#'
#' @return A character vector of column names.
#' @keywords internal
#' @noRd
dgf_schema_cols_v7 <- function() {
  c(
    # variable key
    "var_name",

    # dd_: data dictionary (user-authored)
    "dd_vname_alias", "dd_vlabel", "dd_vdesc", "dd_is_join_key",

    # raw_: as received
    "raw_first5", "raw_data_mode", "raw_duplicated",

    # guess_: machine proposal from formex guess_data_type()$route (+ legacy $guess)
    "guess_label", "guess_semantic_type", "guess_format_style", "guess_unit_type",
    "guess_match_kind", "guess_confidence", "guess_depth", "guess_variant_id",

    # desired_: the human's confirmed/overridden target form
    "desired_semantic_type", "desired_format_style", "desired_unit_type",

    # stabilizer: the read :: [convert] :: write plan (formex fx_plan_transform)
    "stabilizer_needed", "stabilizer", "stabilizer_status", "stable_first5",

    # load rule: reading the governed CSV back into R
    "load_rule_needed", "load_rule",

    # rg_ / validate_ / prov_: unchanged from v2
    "rg_properties", "rg_preview", "rg_stats", "rg_graphics", "rg_max_chr",
    "validate_rules", "validate_format",
    "prov_start_hash", "prov_current_hash"
  )
}
