# LAYOUTS WILL BE SAVED AS DATA OBJECTS

layout.numeric <-
  c( "div2 ;; vlabel         ;; LABEL         ;; v_to_txt",
     "div3 ;; vtype_class    ;; DATA TYPE     ;; v_to_txt",
     "div4 ;; vdesc          ;; DESCRIPTION   ;; v_to_txt",
     "div5 ;; rg_properties  ;; PROPERTIES    ;; paste_properties",
     "div7 ;; rg_stats       ;; STATS         ;; paste_stats_num",
     "div8 ;; rg_graphics    ;; HIST          ;; paste_histogram",
     "div9 ;; rg_preview     ;; DATA PREVIEW  ;; paste_preview_num"   )

#    "div6 ;; vname        ;; QUANTILES     ;; get_quantiles",


layout.character <-
  c( "div2  ;; vlabel        ;; LABEL         ;; v_to_txt",
     "div3  ;; vtype_class   ;; DATA TYPE     ;; v_to_txt",
     "div4  ;; vdesc         ;; DESCRIPTION   ;; v_to_txt",
     "div10  ;; rg_properties ;; PROPERTIES    ;; paste_properties",
     "div11  ;; rg_preview    ;; PREVIEW       ;; paste_preview_chr",
     "div12 ;; rg_stats      ;; STATS         ;; paste_stats_chr",
     "div13 ;; rg_graphics   ;; Word Cloud    ;; v_to_wordcloud"  )

layout.factor <-
  c( "div2 ;; vlabel         ;; LABEL         ;; v_to_txt",
     "div3 ;; vtype_class    ;; DATA TYPE     ;; v_to_txt",
     "div4 ;; vdesc          ;; DESCRIPTION   ;; v_to_txt",
     "div14 ;; rg_properties ;; PROPERTIES          ;; paste_properties",
     "div15 ;; rg_stats      ;; MOST COMMON VALUES  ;; paste_stats_fact",
     "div16 ;; rg_graphics   ;; TREEMAP             ;; paste_treemap"  )

layout.logical <-
  c("div2 ;; vlabel         ;; LABEL         ;; v_to_txt",
    "div3 ;; vtype_class    ;; DATA TYPE     ;; v_to_txt",
    "div4 ;; vdesc          ;; DESCRIPTION   ;; v_to_txt",
    "div17 ;; rg_properties ;; PROPERTIES    ;; paste_properties",
    "div18 ;; rg_stats      ;; VALUES        ;; paste_stats_log",
    "div19 ;; rg_graphics   ;; BOOLPLOT      ;; paste_booleplot"  )



