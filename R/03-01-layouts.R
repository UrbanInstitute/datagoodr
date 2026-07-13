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
layout.numeric <-
  c( "div2 ;; vlabel         ;;               ;; v_to_txt",
     "div3 ;; vtype_class    ;; DATA TYPE     ;; v_to_txt",
     "div3 ;; vscope         ;; SCOPE         ;; v_to_txt",
     "div3 ;; vlength        ;; LENGTH        ;; v_to_txt",
     "div4 ;; vdesc          ;; DESCRIPTION   ;; v_to_txt",
     "div4 ;; vloc           ;; LOCATION CODE ;; v_to_txt",
     "div5 ;; rg_properties  ;; PROPERTIES    ;; paste_properties",
     "div6 ;; rg_stats       ;; QUANTILES     ;; paste_quantiles",
     "div7 ;; rg_stats       ;; STATS         ;; paste_stats_num",
     "div8 ;; rg_graphics    ;; HIST          ;; paste_histogram",
     "div9 ;; rg_preview     ;; DATA PREVIEW  ;; paste_preview_num"   )

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
  c( "div2  ;; vlabel        ;;               ;; v_to_txt",
     "div3  ;; vtype_class   ;; DATA TYPE     ;; v_to_txt",
     "div3  ;; vscope        ;; SCOPE         ;; v_to_txt",
     "div3  ;; vlength       ;; LENGTH        ;; v_to_txt",
     "div4  ;; vdesc         ;; DESCRIPTION   ;; v_to_txt",
     "div4  ;; vloc          ;; LOCATION CODE ;; v_to_txt",
     "div10 ;; rg_properties ;; PROPERTIES    ;; paste_properties",
     "div21 ;; rg_stats      ;; MOST COMMON   ;; paste_stats_chr_common",
     "div12 ;; rg_stats      ;; STATS         ;; paste_stats_chr",
     "div13 ;; rg_graphics   ;; WORD CLOUD    ;; v_to_wordcloud",
     "div11 ;; rg_preview    ;; PREVIEW       ;; paste_preview_chr"  )


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
  c( "div2 ;; vlabel         ;;               ;; v_to_txt",
     "div3 ;; vtype_class    ;; DATA TYPE     ;; v_to_txt",
     "div3 ;; vscope         ;; SCOPE         ;; v_to_txt",
     "div3 ;; vlength        ;; LENGTH        ;; v_to_txt",
     "div4 ;; vdesc          ;; DESCRIPTION   ;; v_to_txt",
     "div4 ;; dd_f_level     ;; LEVELS        ;; paste_levels",
     "div4 ;; vloc           ;; LOCATION CODE ;; v_to_txt",
     "div14 ;; rg_properties ;; PROPERTIES   ;; paste_properties",
     "div14 ;; rg_stats      ;; MOST COMMON  ;; paste_stats_fact",
     "div16 ;; rg_graphics   ;; TREEMAP      ;; paste_treemap"  )


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
  c("div2 ;; vlabel         ;;               ;; v_to_txt",
    "div3 ;; vtype_class    ;; DATA TYPE     ;; v_to_txt",
    "div3 ;; vscope         ;; SCOPE         ;; v_to_txt",
    "div3 ;; vlength        ;; LENGTH        ;; v_to_txt",
    "div4 ;; vdesc          ;; DESCRIPTION   ;; v_to_txt",
    "div4 ;; dd_f_level     ;; LEVELS        ;; paste_levels",
    "div4 ;; vloc           ;; LOCATION CODE ;; v_to_txt",
    "div17 ;; rg_properties ;; PROPERTIES    ;; paste_properties",
    "div19 ;; rg_graphics   ;; VALUES        ;; paste_booleplot"  )


### Save these in the R package
# usethis::use_data(
#   layout.numeric,
#   layout.character,
#   layout.factor,
#   layout.logical,
#   internal = TRUE,
#   overwrite = TRUE
# )
