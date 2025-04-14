# LAYOUTS WILL BE SAVED AS DATA OBJECTS

# FIRST COLUMN: divider to use
# SECOND COLUMN: which column of DGF to use for source
# THIRD COLUMN: title to add to the section
# FOURTH COLUMN: function to use

layout.numeric <-
 c( "div2 ;; dd_label     ;; LABEL         ;; v_to_txt",
    "div3 ;; data_type    ;; DATA TYPE     ;; v_to_txt",
    "div4 ;; dd_desc      ;; DESCRIPTION   ;; v_to_txt",
    "div5 ;; vname        ;; PROPERTIES    ;; get_properties",
    "div6 ;; vname        ;; QUANTILES     ;; get_quantiles",
    "div7 ;; vname        ;; STATS         ;; get_stats_num",
    "div8 ;; vname        ;; HIST          ;; get_histogram",
    "div9 ;; vname        ;; DATA PREVIEW  ;; get_num_preview"   )

layout.character <-
 c( "div2  ;; dd_label     ;; LABEL         ;; v_to_txt",
    "div3  ;; data_type    ;; DATA TYPE     ;; v_to_txt",
    "div4  ;; dd_desc      ;; DESCRIPTION   ;; v_to_txt",
    "div8  ;; vname        ;; PROPERTIES    ;; get_properties",
    "div9  ;; vname        ;; PREVIEW       ;; get_examples_chr",
    "div10 ;; vname        ;; STATS         ;; get_stats_chr",
    "div11 ;; vname        ;; ''            ;; get_wordcloud"  )

layout.factor <-
 c( "div2  ;; dd_label     ;; LABEL         ;; v_to_txt",
    "div3  ;; data_type    ;; DATA TYPE     ;; v_to_txt",
    "div4  ;; dd_desc      ;; DESCRIPTION   ;; v_to_txt",
    "div4  ;; dd_f_levels  ;; LEVELS        ;; f_to_tbl",
    "div12 ;; vname        ;; PROPERTIES    ;; get_properties",
    "div13 ;; vname        ;; STATS         ;; get_stats_fact",
    "div14 ;; vname        ;; ''            ;; get_treemap"  )

# add layout.logical
# add layout.date


#############
#############       LAYOUT KEY
#############


#    LAYOUTS
#   ---------
#    "a a a"
#    "b b b"
#    "c d d"
#    "e f g"
#    "h i i"
#    "j k k"
#    "m m m"
#    "n p p"
#    "o p p"
#
#    a = div1
#    b = div2
#    c = div3
#    d = div4
#    e = div5
#    f = div6
#    g = div7
#    h = div8
#    i = div9
#    j = div10
#    k = div11
#    m = div12
#    n = div13
#    o = div14
#    p = div15


### CSS ELEMENTS

# .parent {
#   display: grid;
#   grid-template-columns: repeat(3, 1fr);
#   grid-template-rows: auto;  /* repeat(2, 0.2fr) 1fr 1fr; */
#     grid-column-gap: 20px;
#   grid-row-gap: 10px;
#   grid-template-areas:
#     "a a a"
#   "b b b"
#   "c d d"
#   "e f g"
#   "h i i"
#   "j k k"
#   "m m m"
#   "n p p"
#   "o p p";
# }
#
#  In the CSS section:
#
# .div1 { grid-area: a; }
#
# .div2 { grid-area: b; }





#############
#############       FUNCTIONS KEY
#############


# v_to_txt:  glue( label: text )
# f_to_tbl:  print factor table (flevels, flabels)






#############
#############       NUMERIC
#############

#   num layout
#   ----------
#    "a a a"
#    "b b b"
#    "c d d"
#    "e f g"
#    "h i i"
#
#    a = div1
#    b = div2
#    c = div3
#    d = div4
#    e = div5
#    f = div6
#    g = div7
#    h = div8
#    i = div9

# FIRST COLUMN: divider to use
# SECOND COLUMN: which column of DGF to use for source
# THIRD COLUMN: title to add to the section
# FOURTH COLUMN: function to use

layout.num <-
 c( "div2 ;;  dd_label      ;;  LABEL           ;;  v_to_txt",
    "div3 ;;  data_type     ;;  DATA TYPE       ;;  v_to_txt",
    "div4 ;;  dd_desc       ;;  DESCRIPTION     ;;  v_to_txt",
    "div5 ;;  rg_stats      ;;  PROPERTIES      ;;  get_properties",
    "div6 ;;  rg_stats      ;;  QUANTILES       ;;  get_quantiles",
    "div7 ;;  rg_stats      ;;  STATISTICS      ;;  get_statistics",
    "div8 ;;  rg_graphics   ;;  HISTOGRAM       ;;  get_hist",
    "div9 ;;  rg_sample     ;;  EXAMPLE VALUES  ;;  get_examples"  )



#############
#############       CHARACTER
#############

#   chr layout
#   ----------
#    "a a a"
#    "b b b"
#    "c d d"
#    "h i i"
#    "j k k"
#
#    a = div1
#    b = div2
#    c = div3
#    d = div4
#    g = div7
#    h = div8
#    i = div9
#    j = div10
#    k = div11


layout.chr <-
 c( "div2 ;; vlabel   ;; LABEL         ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE     ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE         ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION   ;; v_to_txt",
    "div5 ;; v        ;; LABEL         ;; get_properties"  )





#############
#############       FACTOR
#############

#   fct layout
#   ----------
#    "a a a"
#    "b b b"
#    "c d d"
#    "n p p"
#    "o p p"
#
#    a = div1
#    b = div2
#    c = div3
#    d = div4
#    n = div13
#    o = div14
#    p = div15

layout.fct <-
 c( "div2 ;; vlabel   ;; LABEL        ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE    ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE        ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION  ;; v_to_txt",
    "div4 ;; f_levels ;; LEVELS       ;; f_to_txt",
    "div4 ;; glevels  ;; ''           ;; v_to_txt",
    "div4 ;; loc      ;; LOCATION CODE ;; v_to_txt",
    "div5 ;; v        ;; LABEL        ;; get_properties"  )




#############
#############       LOGICAL
#############

#   lgl layout
#   ----------
#    "a a a"
#    "b b b"
#    "c d d"
#    "e f g"
#
#    a = div1
#    b = div2
#    c = div3
#    d = div4
#    e = div5
#    f = div6
#    g = div7


layout.lgl <-
 c( "div2 ;; vlabel   ;; LABEL         ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE     ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE         ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION   ;; v_to_txt",
    "div4 ;; f_levels ;; LEVELS        ;; f_to_txt",
    "div4 ;; glevels  ;; ''            ;; v_to_txt",
    "div4 ;; loc      ;; LOCATION CODE ;; v_to_txt",
    "div5 ;; v        ;; LABEL         ;; get_properties"  )






#############
#############       DATE
#############

#   dte layout
#   ----------
#    "a a a"
#    "b b b"
#    "c d d"
#    "h i i"
#    "j k k"
#
#    a = div1
#    b = div2
#    c = div3
#    d = div4
#    h = div8
#    i = div9
#    j = div10
#    k = div11


layout.dte <-
 c( "div2 ;; vlabel   ;; LABEL        ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE    ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE        ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION  ;; v_to_txt",
    "div4 ;; f_levels ;; LEVELS       ;; f_to_txt",
    "div4 ;; glevels  ;; ''           ;; v_to_txt",
    "div4 ;; loc      ;; LOCATION CODE ;; v_to_txt",
    "div5 ;; v        ;; LABEL        ;; get_properties"  )





#############
#############       DATE TIME
#############


#   dtm layout
#   ----------
#    "a a a"
#    "b b b"
#    "c d d"
#    "h i i"
#    "j k k"
#
#    a = div1
#    b = div2
#    c = div3
#    d = div4
#    h = div8
#    i = div9
#    j = div10
#    k = div11


layout.dtm <-
 c( "div2 ;; vlabel   ;; LABEL        ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE    ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE        ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION  ;; v_to_txt",
    "div4 ;; f_levels ;; LEVELS       ;; f_to_txt",
    "div4 ;; glevels  ;; ''           ;; v_to_txt",
    "div4 ;; loc      ;; LOCATION CODE ;; v_to_txt",
    "div5 ;; v        ;; LABEL        ;; get_properties"  )
