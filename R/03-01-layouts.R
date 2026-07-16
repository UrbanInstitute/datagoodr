# LAYOUTS WILL BE SAVED AS DATA OBJECTS

#' Numeric variable layout definitions
#'
#' Internal layout specification for numeric variables. Each element
#' is a string describing a div, variable, label, and function to use.
#'
#' @format A character vector.
#'
#' @details
#' Called in \link{get_design} to define layout options.
#'
#' @keywords internal
#' @noRd
# Standard section template (shared div scheme across all four types so users
# never have to reorient):
#   div3 attributes (1/3) + div4 description (2/3)
#   div5 PREVIEW label (1/3) + div6 preview data (2/3)
#   div7 PROPERTIES (1/3)    + div8 graphic (2/3)
#   div9 full-width extra table (3/3): STATS / levels / most-common
layout.numeric <-
  c( "div2 ;; dd_vlabel         ;;               ;; v_to_txt",
     "div3 ;; stable_data_type    ;; DATA TYPE     ;; v_to_txt",
     "div3 ;; rg_max_chr        ;; LENGTH        ;; v_to_txt",
     "div4 ;; dd_vdesc          ;; DESCRIPTION   ;; v_to_txt",
     "div5 ;; rg_preview     ;; PREVIEW       ;; paste_label",
     "div6 ;; rg_preview     ;;               ;; paste_preview_num",
     "div7 ;; rg_properties  ;; PROPERTIES    ;; paste_properties",
     "div8 ;; rg_graphics    ;;               ;; paste_histogram",
     "div9 ;; rg_stats       ;; STATS         ;; paste_stats_horizontal"   )

#' Character variable layout definitions
#'
#' Internal layout specification for character string variables. Each element
#' is a string describing a div, variable, label, and function to use.
#'
#' @format A character vector.
#'
#' @details
#' Called in \link{get_design} to define layout options.
#'
#' @keywords internal
#' @noRd
layout.character <-
  c( "div2 ;; dd_vlabel         ;;                    ;; v_to_txt",
     "div3 ;; stable_data_type    ;; DATA TYPE          ;; v_to_txt",
     "div3 ;; rg_max_chr        ;; LENGTH             ;; v_to_txt",
     "div4 ;; dd_vdesc          ;; DESCRIPTION        ;; v_to_txt",
     "div5 ;; rg_preview     ;; PREVIEW            ;; paste_label",
     "div6 ;; rg_preview     ;;                    ;; paste_preview_chr",
     "div7 ;; rg_properties  ;; PROPERTIES         ;; paste_properties",
     "div8 ;; rg_graphics    ;;                    ;; v_to_wordcloud",
     "div9 ;; rg_stats       ;; MOST COMMON VALUES ;; paste_stats_chr_common"  )


#' Factor variable layout definitions
#'
#' Internal layout specification for factor variables. Each element
#' is a string describing a div, variable, label, and function to use.
#'
#' @format A character vector.
#'
#' @details
#' Called in \link{get_design} to define layout options.
#'
#' @keywords internal
#' @noRd
layout.factor <-
  c( "div2 ;; dd_vlabel         ;;               ;; v_to_txt",
     "div3 ;; stable_data_type    ;; DATA TYPE     ;; v_to_txt",
     "div3 ;; rg_max_chr        ;; LENGTH        ;; v_to_txt",
     "div4 ;; dd_vdesc          ;; DESCRIPTION   ;; v_to_txt",
     "div5 ;; rg_preview     ;; PREVIEW       ;; paste_label",
     "div6 ;; rg_preview     ;;               ;; paste_preview_chr",
     "div7 ;; rg_properties  ;; PROPERTIES    ;; paste_properties",
     "div8 ;; rg_graphics    ;;               ;; paste_treemap",
     "div9 ;; dd_f_levels     ;; FACTOR LEVELS ;; paste_levels_freq"  )


#' Logical/Boolean variable layout definitions
#'
#' Internal layout specification for logical/Boolean variables. Each element
#' is a string describing a div, variable, label, and function to use.
#'
#' @format A character vector.
#'
#' @details
#' Called in \link{get_design} to define layout options.
#'
#' @keywords internal
#' @noRd
layout.logical <-
  c("div2 ;; dd_vlabel         ;;                 ;; v_to_txt",
    "div3 ;; stable_data_type    ;; DATA TYPE       ;; v_to_txt",
    "div3 ;; rg_max_chr        ;; LENGTH          ;; v_to_txt",
    "div4 ;; dd_vdesc          ;; DESCRIPTION     ;; v_to_txt",
    "div5 ;; rg_preview     ;; PREVIEW         ;; paste_label",
    "div6 ;; rg_preview     ;;                 ;; paste_preview_chr",
    "div7 ;; rg_properties  ;; PROPERTIES      ;; paste_properties",
    "div8 ;; rg_graphics    ;;                 ;; paste_booleplot",
    "div9 ;; dd_f_levels     ;; CATEGORY LABELS ;; paste_levels_horizontal"  )


### The default layouts ship as internal package data (R/sysdata.rda). After
### editing any layout.* above, regenerate it by running:
# usethis::use_data(
#   layout.numeric,
#   layout.character,
#   layout.factor,
#   layout.logical,
#   internal = TRUE,
#   overwrite = TRUE
# )
