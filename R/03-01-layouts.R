# Default section layouts, keyed by the ontology data_type. Each layout is a
# character vector; every element is "div ;; DGF column ;; LABEL ;; function".
#
# SINGLE SOURCE OF TRUTH: these live only here, returned by default_layouts().
# get_design() reads them from this function (a user can still shadow any layout
# by defining `layout.numeric`/`layout.character`/... in the global environment,
# e.g. from a project DG.R). They are NOT duplicated in R/sysdata.rda anymore --
# that duplication let the two copies drift.
#
# Shared div scheme across every type so a reader never has to reorient:
#   div3 attributes (1/3)  + div4 description (2/3)
#   div5 PREVIEW label (1/3) + div6 preview data (2/3)
#   div7 PROPERTIES (1/3)    + div8 graphic (2/3)
#   div9 full-width extra table (3/3): STATS / levels / most-common

#' Default section layouts
#'
#' Returns the built-in layout for each ontology `data_type`, used by
#' \link{get_design}. The `div3` block lists a variable's ontology coordinates
#' --- DATA TYPE / SUBTYPE / CLASS / FORMAT (and UNIT for temporals) --- plus its
#' field width (MAX NCHAR). `v_to_txt` renders a blank for any coordinate a
#' variable does not carry, so a plain number simply shows fewer rows.
#'
#' @return A named list of character-vector layouts, keyed
#'   `numeric`/`character`/`factor`/`logical`/`identifier`/`temporal`.
#' @keywords internal
#' @noRd
default_layouts <- function() {

  # the shared descriptor "attributes" column (top-left, 1/3): the ontology
  # coordinates followed by the field width. `unit = TRUE` adds the temporal
  # UNIT (stable_data_unit), which drives the temporal graphic.
  attrs <- function( unit = FALSE ) c(
    "div3 ;; desired_data_type    ;; DATA TYPE ;; v_to_txt",
    "div3 ;; desired_data_subtype ;; SUBTYPE   ;; v_to_txt",
    "div3 ;; desired_data_class   ;; CLASS     ;; v_to_txt",
    "div3 ;; desired_data_format  ;; FORMAT    ;; v_to_txt",
    if( unit ) "div3 ;; stable_data_unit ;; UNIT ;; v_to_txt" else NULL,
    "div3 ;; rg_max_chr           ;; MAX NCHAR ;; v_to_txt" )

  list(

    numeric = c(
      "div2 ;; dd_vlabel      ;;             ;; v_to_txt",
      attrs(),
      "div4 ;; dd_vdesc       ;; DESCRIPTION ;; v_to_txt",
      "div5 ;; rg_preview     ;; PREVIEW     ;; paste_label",
      "div6 ;; rg_preview     ;;             ;; paste_preview_num",
      "div7 ;; rg_properties  ;; PROPERTIES  ;; paste_properties",
      "div8 ;; rg_graphics    ;;             ;; paste_histogram",
      "div9 ;; rg_stats       ;; STATS       ;; paste_stats_horizontal",
      "div9 ;; rg_stats       ;; DISTRIBUTION SHAPE ;; paste_distribution_shape" ),

    character = c(
      "div2 ;; dd_vlabel      ;;             ;; v_to_txt",
      attrs(),
      "div4 ;; dd_vdesc       ;; DESCRIPTION ;; v_to_txt",
      "div5 ;; rg_preview     ;; PREVIEW     ;; paste_label",
      "div6 ;; rg_preview     ;;             ;; paste_preview_chr",
      "div7 ;; rg_properties  ;; PROPERTIES  ;; paste_properties",
      "div8 ;; rg_graphics    ;;             ;; v_to_wordcloud",
      "div9 ;; rg_stats       ;; MOST COMMON VALUES ;; paste_stats_chr_common" ),

    factor = c(
      "div2 ;; dd_vlabel      ;;             ;; v_to_txt",
      attrs(),
      "div4 ;; dd_vdesc       ;; DESCRIPTION ;; v_to_txt",
      "div5 ;; rg_preview     ;; PREVIEW     ;; paste_label",
      "div6 ;; rg_preview     ;;             ;; paste_preview_chr",
      "div7 ;; rg_properties  ;; PROPERTIES  ;; paste_properties",
      "div8 ;; rg_graphics    ;;             ;; paste_treemap",
      "div9 ;; dd_f_levels    ;; FACTOR LEVELS ;; paste_levels_freq" ),

    logical = c(
      "div2 ;; dd_vlabel      ;;             ;; v_to_txt",
      attrs(),
      "div4 ;; dd_vdesc       ;; DESCRIPTION ;; v_to_txt",
      "div5 ;; rg_preview     ;; PREVIEW     ;; paste_label",
      "div6 ;; rg_preview     ;;             ;; paste_preview_chr",
      "div7 ;; rg_properties  ;; PROPERTIES  ;; paste_properties",
      "div8 ;; rg_graphics    ;;             ;; paste_booleplot",
      "div9 ;; dd_f_levels    ;; CATEGORY LABELS ;; paste_levels_horizontal" ),

    identifier = c(
      "div2 ;; dd_vlabel      ;;             ;; v_to_txt",
      attrs(),
      "div4 ;; dd_vdesc       ;; DESCRIPTION ;; v_to_txt",
      "div5 ;; rg_preview     ;; PREVIEW     ;; paste_label",
      "div6 ;; rg_preview     ;;             ;; paste_preview_chr",
      "div7 ;; rg_properties  ;; PROPERTIES  ;; paste_properties",
      "div8 ;; rg_stats       ;; MOST COMMON VALUES ;; paste_stats_chr_common" ),

    temporal = c(
      "div2 ;; dd_vlabel      ;;             ;; v_to_txt",
      attrs( unit = TRUE ),
      "div4 ;; dd_vdesc       ;; DESCRIPTION ;; v_to_txt",
      "div5 ;; rg_preview     ;; PREVIEW     ;; paste_label",
      "div6 ;; rg_preview     ;;             ;; paste_preview_chr",
      "div7 ;; rg_properties  ;; PROPERTIES  ;; paste_properties",
      "div8 ;; rg_graphics    ;;             ;; paste_temporal_graphic" )
  )
}
