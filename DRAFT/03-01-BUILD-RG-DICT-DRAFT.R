# install.packages(c("Rcpp", "remotes"), dependencies = TRUE)
# remotes::install_github("ycphs/openxlsx")
#
# library( tidyverse )
# library( jsonlite )
# library( dplyr )
# library( knitr )

# path <- "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/00-GITHUB/datagood2/R"
# setwd( path )

# source( "00-utils.R" )
# source( "01-03-get-stats.R" )
# source( "03-00-utils.R" )
# source( "03-01-layouts.R" )
# source( "03-01-create-sections.R" )
# source( "03-02-treemap.R" )
# source( "03-03-booleplot.R" )
# source( "03-04-wordcloud.R" )
# source( "03-05-tables.R" )
# source( "03-06-barplot.R" )
# source( "03-07-booleplot.R" )



#
# fn.dgf <- "../data-dev/DGF-CORE-CO-2019-V1.xlsx"
# dgf <- load_dgf( fn.dgf )

#  [1] "vname"             "vname_alias"       "dd_label"          "dd_desc"           "dd_f_levels"       "dd_f_order"
#  [7] "first5_raw"        "data_type_raw"     "data_type_convert" "data_type"         "data_type_class"   "data_format_out"
# [13] "first5"            "rg_stats"          "rg_graphics"       "data_standardize"  "data_validate"

# fn.df <- "../data-dev/DEMO-DATA-SMALL.csv"
# df <-  read.csv( fn.df  )

#  [1] "F9_00_ORG_NAME_L1"              "F0_00_ORG_CONTACT"              "F9_00_ORG_ADDR_L1"
#  [4] "F9_00_ORG_ADDR_CITY"            "EIN"                            "SUBSECCD"
#  [7] "BMF_ACTIV1"                     "NTMAJ12"                        "NTEE1"
# [10] "NTEEFINAL"                      "NTEESRC"                        "DEDUCTCD"
# [13] "OUTREAS"                        "F9_05_UBIZ_IMCOME_OVER_LIMIT_X" "OUTNCCS"
# [16] "COUNTY_FIPS"                    "CEO_CENSUSTRACT"                "F9_00_TAX_PERIOD_END_DATE"
# [19] "F9_00_TAX_PERIOD_END_DATE_PY"   "F9_00_TAX_PERIOD_BEGIN_DATE"    "F9_00_TAX_ACCPER"
# [22] "F9_08_REV_TOT_TOT"              "F9_10_ASSET_TOT_BOY"            "F9_10_ASSET_TOT_EOY"
# [25] "F9_10_NAFB_TOT_BOY"             "F9_09_EXP_TOT_TOT"              "F9_01_EXP_TOT_PY"






################
################   CONVERT CELL VALUE TO DD MARKDOWN TEXT
################


v_to_txt <- function( VNAME, LABEL )
{
  value  <- xx[[VNAME]]
  txt <- paste0( "**", LABEL, "**", ": ",  value, "\n\n" )
  cat( txt )
}

# v_to_txt( VNAME="type", LABEL="DATA TYPE" )
# # **DATA TYPE**: factor
#
# v_to_txt( VNAME="vlabel", LABEL="LABEL" )
# # **LABEL**: ACTIV3
#
# v_to_txt( VNAME="vdesc", LABEL="DESCRIPTION" )
# # **DESCRIPTION**: IRS Activity Code 3

#
# get_flevels <- function( VNAME, dgf ) {
#
#   # vname <- "LEVEL3"
#
#   x <- dgf$dd_f_levels[ dgf$vname == VNAME ]
#   f <- jsonlite::fromJSON( x )
#
#   y <- dgf$dd_f_order[ dgf$vname == VNAME ]
#   y <- parse_semicolons( y )
#
#   same.levels <- setequal( f$f_level, y )
#   if( ! same.levels )
#   {
#     # warning
#     return(f)
#   }
#
#   # reorder factor levels
#   # eg MON TUE WED
#   f <- f[ match( y, f$f_level ), ]
#
#   return(f)
# }
#
#
#
# get_flevels <- function( VNAME, LABEL=NULL, dgf=NULL ) {
#
#   # vname <- "LEVEL3"
#
#   if( ! is.null(dgf) )
#   { xx <- L[[ VNAME ]] }
#
#   x <- xx[[ "dd_f_levels" ]]
#
#   f <- jsonlite::fromJSON( x )
#
#   y <- xx[[ "dd_f_order" ]]
#   y <- parse_semicolons( y )
#
#   same.levels <- setequal( f$f_level, y )
#   if( ! same.levels )
#   {
#     # warning
#     return(f)
#   }
#
#   # reorder factor levels
#   # eg MON TUE WED
#   f <- f[ match( y, f$f_level ), ]
#
#   return(f)
# }
#
#
# f_to_tbl <- function( VNAME, LABEL="FACTOR LEVELS" ) {
#   ftble <- get_flevels( VNAME )
#   k <- knitr::kable( ftble )
#   k <- c( paste0("**", LABEL, "**:"), "\n", k )
#   return(k)
# }


# f_to_tbl( VNAME="NTMAJ12", LABEL="CATEGORIES" )
#
# |f_level |label |
# |:-------|:-----|
# |AR      |AR    |
# |BH      |BH    |
# |ED      |ED    |
# |EH      |EH    |
# |EN      |EN    |
# |HE      |HE    |
# |HU      |HU    |
# |IN      |IN    |
# |MU      |MU    |
# |PU      |PU    |
# |RE      |RE    |
# |UN      |UN    |



#########
#########    TEST FUNCTIONS
#########

# layout.f <-
#  c( "div2  ;; dd_label     ;; LABEL         ;; v_to_txt",
#     "div3  ;; data_type    ;; DATA TYPE     ;; v_to_txt",
#     "div4  ;; dd_desc      ;; DESCRIPTION   ;; v_to_txt",
#     "div4  ;; dd_f_levels  ;; LEVELS        ;; f_to_tbl"  )
#

#
# dd <- parse_design( layout.f )
# dd$TYPE <- "factor"
#
# L <- dgf_to_list( dgf )
# xx <- L[["NTMAJ12"]]
#
# create_div( div.num="div2", all.layouts=dd, xx )
# create_div( div.num="div3", all.layouts=dd, xx )
# create_div( div.num="div4", all.layouts=dd, xx )
#
#
# create_section( VNAME="NTMAJ12", all.layouts, L )
#
#
#
# {{< pagebreak >}}
#
# ::::: {.parent}
#
# ::: {.div1}
#
# #### NTMAJ12
#
# :::
#
# ::: {.div2}
#
# **LABEL**: NTMAJ12
#
#
#
#
# :::
#
# ::: {.div3}
#
# **DATA TYPE**: factor
#
#
#
#
# :::
#
# ::: {.div4}
#
# **DESCRIPTION**: NTEE major group (12)
#
#
# |f_level |label |
# |:-------|:-----|
# |AR      |AR    |
# |BH      |BH    |
# |ED      |ED    |
# |EH      |EH    |
# |EN      |EN    |
# |HE      |HE    |
# |HU      |HU    |
# |IN      |IN    |
# |MU      |MU    |
# |PU      |PU    |
# |RE      |RE    |
# |UN      |UN    |
#
#
# :::
#
# :::::
#
#
#
#
#
#
#
#
#
#
#
#
#

### GROUP BY DIV SECTIONS
#
# dd <- parse_design( layout.numeric )
#
# # unnamed list
# dL <- dd %>% group_by(DIV) %>% group_split( .keep=T )
# d3 <- dL[[3]]
#
# # returns named list
# dL <- split( dd, ~ DIV )
# dL["div4"] %>% knitr::kable()
#
#
#
#
#
#


#########
#########    CONVERT DGF TO ROW LISTS (BY VARIABLE)
#########

#
# dgf_to_list <- function( dgf ) {
#
#   wb <- dgf
#
#   m <- t(wb)
#   d <- as.data.frame(m)
#   names(d) <- d[1,]
#
#   L <- as.list(d)
#
#   rn_to_nm <- function( x, rn=rownames(d) ) {
#     names(x) <- rn
#     return(x)
#   }
#
#   L2 <- lapply( L, rn_to_nm )
#   return(L2)
# }

#
#
# L <- dgf_to_list( dgf )
# L[["BMF_ACTIV1"]] |> knitr::kable()
#
# |                  |x                     |
# |:-----------------|:---------------------|
# |vname             |BMF_ACTIV1            |
# |vname_alias       |ACTIV1                |
# |dd_label          |ACTIV1                |
# |dd_desc           |IRS Activity Code 1   |
# |dd_f_levels       |NA                    |
# |dd_f_order        |NA                             |
# |first5_raw        |907 ;; 260 ;; 205 ;; 280 ;; 200              |
# |data_type_raw     |numeric                        |
# |data_type_convert |as.factor()                |
# |data_type         |factor                 |
# |data_type_class   |NA                    |
# |data_format_out   |NA                    |                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
# |first5            |907 ;; 260 ;; 205 ;; 280 ;; 200 |
# |rg_stats          |[
#                       { "stat" : "n_missing",  "ACTIV1" : "10993" },
#                       { "stat" : "complete_rate",  "ACTIV1" : "0.9237137583" },
#                       { "stat" : "mean",  "ACTIV1" : "2.669367e+02" },
#                       { "stat" : "sd",  "ACTIV1" : "2.821882e+02" },
#                       { "stat" : "p0",  "ACTIV1" : "0.000000e+00" },
#                       { "stat" : "p25",  "ACTIV1" : "3.000000e+01" },
#                       { "stat" : "p50",  "ACTIV1" : "2.290000e+02" },
#                       { "stat" : "p75",  "ACTIV1" : "3.180000e+02" },
#                       { "stat" : "p100",  "ACTIV1" : "9.990000e+02" },
#                       { "stat" : "hist",  "ACTIV1" : "?????"}
#                     ] |
# |rg_graphics       |NA              |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
# |data_standardize  |NA              |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
# |data_validate     |NA              |
#
#
#
# L <- head(dgf) %>% dgf_to_list()
#
# xx <- L[["BMF_ACTIV1"]]
#
# xx <-
# c(vname = "BMF_ACTIV1", vlabel = "ACTIV1", vdesc = "IRS Activity Code 3",
# vname_alias = "ACTIV3", first5_raw = "0 ;; \n403 ;; \n319 ;; \n279 ;; \n317",
# raw_type = "numeric", raw_convert = "as.factor()", type = "factor",
# type_class = NA, format_out = NA, first5 = "0 ;; \n403 ;; \n319 ;; \n279 ;; \n317",
# values = "[ \n  { \"stat\" : \"n_missing\",  \"ACTIV3\" : \"10993\" }, \n  { \"stat\" : \"complete_rate\",  \"ACTIV3\" : \"0.9237137583\" }, \n  { \"stat\" : \"mean\",  \"ACTIV3\" : \"5.930141e+01\" }, \n  { \"stat\" : \"sd\",  \"ACTIV3\" : \"1.441357e+02\" }, \n  { \"stat\" : \"p0\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p25\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p50\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p75\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p100\",  \"ACTIV3\" : \"9.950000e+02\" }, \n  { \"stat\" : \"hist\",  \"ACTIV3\" : \"?????\"}\n]",
# f_levels = NA, f_order = NA, standardize = NA, validate = NA)
#
#
# xx["vname"]
# #        vname
# # "BMF_ACTIV3"
#
# xx["vlabel"]
# #   vlabel
# # "ACTIV3"
#


#########
#########    CONVERT DESIGN MATRIX TO DF
#########

# design <-
#  c( "div2 ;; vlabel   ;; LABEL        ;; v_to_txt",
#     "div3 ;; vtype    ;; DATA TYPE    ;; v_to_txt",
#     "div3 ;; scope    ;; SCOPE        ;; v_to_txt",
#     "div4 ;; desc     ;; DESCRIPTION  ;; v_to_txt",
#     "div4 ;; f_levels ;; LEVELS       ;; f_to_txt",
#     "div4 ;; glevels  ;; ''           ;; v_to_txt",
#     "div4 ;; loc      ;; LOCATION CODE ;; v_to_txt",
#     "div5 ;; v        ;; LABEL        ;; get_properties"  )
#
# parse_design <- function( x ) {
#   x <- gsub( ";;$", ";; ", x )
#   L <- strsplit( x, ";;" )
#   L <- lapply( L, trimws )
#   L <- lapply( L, check_length )
#   d <- dplyr::bind_rows( L )
#   return( d )
# }
#
# check_length <- function(x) {
#   # add empty element if no label is provided
#   if( length(x) == 3 )
#   { x <- c( x, "" ) }
#   # check for malformed design
#   if( length(x) != 4 )
#   { stop("malformed design argument") }
#   names(x) <- c("DIV","VNAME","LABEL","FUNCTION")
#   return(x)
# }
#

#########
#########    CONVERT DESIGN DF TO LIST
#########
#
# dd <- parse_design( design )
#
# # unnamed list
# dL <- dd %>% group_by(DIV) %>% group_split( .keep=T )
# d3 <- dL[[3]]
#
# # returns named list
# dL <- split( dd, ~ DIV )
# dL["div4"] %>% knitr::kable()
#
#
#
#

################
################   CREATE SINGLE DIV
################


## div - section to create
##  dd - design matrix
##  xx - named vector of variables

## do we need to pass the actual data ever ?
## or can we retrieve at the higher level?
#
# create_div <- function( div="div2", dd, xx ) {
#
#   # skip div if not included in design
#   if( ! any( div %in% dd$DIV ) )
#   { return( NULL ) }
#
#   dd.sub <-
#     dd %>%
#     dplyr::filter( DIV == div ) %>%
#     select( FUNCTION, VNAME, LABEL )
#
#   cat( paste0( "::: {.", div, "} \n\n" ) )
#
#   pwalk( dd.sub,
#      function( FUNCTION, ... ) {
#        args <- list(...)
#        txt <- do.call( FUNCTION, args )
#        cat( txt )
#      } )
#
#   cat( "::: \n\n" )
# }

#
# design <-
#  c( "div2 ;; vlabel  ;; LABEL         ;; v_to_txt",
#     "div2 ;; type    ;; DATA TYPE     ;; v_to_txt",
#     "div2 ;; vdesc   ;; DESCRIPTION   ;; v_to_txt" )

# dd2 <- parse_design( design )
#
# create_div( div="div2", dd=dd2, xx=xx )

# ::: {.div2}
#
# **LABEL**: ACTIV3
#
# **DATA TYPE**: factor
#
# **DESCRIPTION**: IRS Activity Code 3
#
# :::


# design <-
#  c( "div1 ;; vname    ;; ''            ;; v_to_h4",
#     "div2 ;; vlabel   ;; LABEL         ;; v_to_txt",
#     "div3 ;; vtype    ;; DATA TYPE     ;; v_to_txt",
#     "div3 ;; scope    ;; SCOPE         ;; v_to_txt",
#     "div4 ;; desc     ;; DESCRIPTION   ;; v_to_txt",
#     "div4 ;; f_levels ;; FACTOR LEVELS ;; v_to_txt" )
#
# dd2 <- parse_design( design )
#
# create_div( div="div2", dd=dd2, xx=xx )

# ::: {.div2}
#
# **LABEL**: ACTIV3
#
# :::




## IGNORE THIS VERSION?
#
# create_div1 <- function( vname ) {
#   cat( "::: {.div1} \n\n" )
#   cat( paste0( "#### ", vname, " \n\n" ) )
#   cat( "::: \n\n" )
# }

# create_div1( vname="EIN" )

#   ::: {.div1}
#
#   #### EIN
#
#   :::


## USE THIS VERSION?
#
# v_to_h4 <- function( VNAME="vname", LABEL=NULL )
# {
#   value  <- xx["vname"]
#   txt <- paste0( "#### ",  value, " \n\n" )
#   cat( txt )
# }

# create_div( div="div1", dd=dd2, xx=xx )

#   ::: {.div1}
#
#   #### BMF_ACTIV3
#
#   :::



################
################   CREATE VAR SECTION (DIV1-DIV9)
################


# v = variable section
# dd = design matrix
# L = dgf as a named list
#
# L <- dgf_to_list( dgf )
#
# create_section <- function( v="EIN", dd, L ) {
#
#   xx <- L[[ v ]]
#
#   cat( "{{< pagebreak >}} \n\n")
#   cat( "::::: {.parent} \n\n" )
#
#   create_div( div="div1", dd=dd, xx )
#   create_div( div="div2", dd=dd, xx )
#   create_div( div="div3", dd=dd, xx )
#   # create_div4( dd, xx )
#   # create_div5( dd, xx )
#
#   cat( ":::::  \n\n\n\n\n\n" )
#
# }
#
#
#
# create_section( v="EIN", dd, L )
#
#
# design <-
#  c( "div1 ;; vname   ;; ''            ;; v_to_h4",
#     "div2 ;; vlabel  ;; LABEL         ;; v_to_txt",
#     "div3 ;; vtype   ;; DATA TYPE     ;; v_to_txt",
#     "div3 ;; scope   ;; SCOPE         ;; v_to_txt",
#     "div4 ;; desc    ;; DESCRIPTION   ;; v_to_txt",
#     "div4 ;; flevels ;; FACTOR LEVELS ;; v_to_txt" )
#
# dd2 <- parse_design( design )


################
################   CREATE ALL SECTIONS (BUILD DD)
################
#
# create_all_sections <- function( dgf, design=NULL ) {
#
#   if( is.null(design) )
#   { dd <- data(design.df) }
#
#   # design matrix as data frame
#   dd <- parse_design( design )
#
#   # DGF as a list of vnames
#   L <- dgf_to_list( dgf )
#
#   vars <- names(L)
#   walk( vars, create_section, dd, L )
#
# }


# create_all_sections( dgf, design )






