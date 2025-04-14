library( tidyverse )



load_dgf <- function( filename="DGF.xlsx" ) {
  dgf <- openxlsx::read.xlsx( xlsxFile=filename, sheet="DGF" )
  return(dgf)
}

path <- "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/datagood"
fn <- "DGF-CORE-CO-2019.xlsx"
setwd( path )

dgf <- load_dgf( fn )
names(dgf) <- gsub( "dgf_", "", names(dgf) )



#########
#########    CONVERT DGF TO ROW LISTS (BY VARIABLE)
#########


dgf_to_list <- function( dgf ) {

  wb <- dgf 

  m <- t(wb)
  d <- as.data.frame(m)
  names(d) <- d[1,]

  L <- as.list(d)

  rn_to_nm <- function( x, rn=rownames(d) ) {
    names(x) <- rn
    return(x)
  }

  L2 <- lapply( L, rn_to_nm )
  return(L2)
}



L <- dgf_to_list( dgf )

L <- head(dgf) %>% dgf_to_list()

xx <- L[["BMF_ACTIV3"]]

xx <- 
c(vname = "BMF_ACTIV3", vlabel = "ACTIV3", vdesc = "IRS Activity Code 3", 
vname_alias = "ACTIV3", first5_raw = "0 ;; \n403 ;; \n319 ;; \n279 ;; \n317", 
raw_type = "numeric", raw_convert = "as.factor()", type = "factor", 
type_class = NA, format_out = NA, first5 = "0 ;; \n403 ;; \n319 ;; \n279 ;; \n317", 
values = "[ \n  { \"stat\" : \"n_missing\",  \"ACTIV3\" : \"10993\" }, \n  { \"stat\" : \"complete_rate\",  \"ACTIV3\" : \"0.9237137583\" }, \n  { \"stat\" : \"mean\",  \"ACTIV3\" : \"5.930141e+01\" }, \n  { \"stat\" : \"sd\",  \"ACTIV3\" : \"1.441357e+02\" }, \n  { \"stat\" : \"p0\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p25\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p50\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p75\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p100\",  \"ACTIV3\" : \"9.950000e+02\" }, \n  { \"stat\" : \"hist\",  \"ACTIV3\" : \"?????\"}\n]", 
f_levels = NA, f_order = NA, standardize = NA, validate = NA)


xx["vname"]
#        vname 
# "BMF_ACTIV3"
 
xx["vlabel"]
#   vlabel 
# "ACTIV3"



#########
#########    CONVERT DESIGN MATRIX TO DF
#########

design <- 
 c( "div2 ;; vlabel   ;; LABEL        ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE    ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE        ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION  ;; v_to_txt",
    "div4 ;; f_levels ;; LEVELS       ;; f_to_txt",
    "div4 ;; glevels  ;; ''           ;; v_to_txt",
    "div4 ;; loc      ;; LOCATION CODE ;; v_to_txt",
    "div5 ;; v        ;; LABEL        ;; get_properties"  )

parse_design <- function( x ) {
  x <- gsub( ";;$", ";; ", x )
  L <- strsplit( x, ";;" ) 
  L <- lapply( L, trimws )
  L <- lapply( L, check_length )
  d <- dplyr::bind_rows( L )
  return( d ) 
}

check_length <- function(x) {
  # add empty element if no label is provided
  if( length(x) == 3 )
  { x <- c( x, "" ) }
  # check for malformed design
  if( length(x) != 4 )
  { stop("malformed design argument") }
  names(x) <- c("DIV","VNAME","LABEL","FUNCTION")
  return(x) 
}


#########
#########    CONVERT DESIGN DF TO LIST
#########

dd <- parse_design( design )

# unnamed list
dL <- dd %>% group_by(DIV) %>% group_split( .keep=T )
d3 <- dL[[3]]

# returns named list
dL <- split( dd, ~ DIV )
dL["div4"] %>% knitr::kable()



################
################   CONVERT CELL VALUE TO DD TEXT 
################


v_to_txt <- function( VNAME, LABEL )
{
  value  <- xx[VNAME]
  txt <- paste0( "**", LABEL, "**", ": ",  value, "\n\n" )
  cat( txt )
}

v_to_txt( VNAME="type", LABEL="DATA TYPE" )
# **DATA TYPE**: factor

v_to_txt( VNAME="vlabel", LABEL="LABEL" )
# **LABEL**: ACTIV3

v_to_txt( VNAME="vdesc", LABEL="DESCRIPTION" )
# **DESCRIPTION**: IRS Activity Code 3


################
################   CREATE SINGLE DIV 
################


## div - section to create
##  dd - design matrix 
##  xx - named vector of variables

## do we need to pass the actual data ever ? 
## or can we retrieve at the higher level? 

create_div <- function( div="div2", dd, xx ) {

  # skip div if not included in design
  if( ! any( div %in% dd$DIV ) )
  { return( NULL ) }

  dd.sub <- 
    dd %>% 
    dplyr::filter( DIV == div ) %>% 
    select( FUNCTION, VNAME, LABEL )

  cat( paste0( "::: {.", div, "} \n\n" ) )

  pwalk( dd.sub, 
     function( FUNCTION, ... ) {
       args <- list(...)
       txt <- do.call( FUNCTION, args )
       cat( txt )
     } )

  cat( "::: \n\n" )
}


design <- 
 c( "div2 ;; vlabel  ;; LABEL         ;; v_to_txt",
    "div2 ;; type    ;; DATA TYPE     ;; v_to_txt",
    "div2 ;; vdesc   ;; DESCRIPTION   ;; v_to_txt" )

dd2 <- parse_design( design )

create_div( div="div2", dd=dd2, xx=xx )

# ::: {.div2} 
# 
# **LABEL**: ACTIV3
# 
# **DATA TYPE**: factor
# 
# **DESCRIPTION**: IRS Activity Code 3
# 
# ::: 


design <- 
 c( "div1 ;; vname    ;; ''            ;; v_to_h4",
    "div2 ;; vlabel   ;; LABEL         ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE     ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE         ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION   ;; v_to_txt",
    "div4 ;; f_levels ;; FACTOR LEVELS ;; v_to_txt" )

dd2 <- parse_design( design )

create_div( div="div2", dd=dd2, xx=xx )

# ::: {.div2} 
# 
# **LABEL**: ACTIV3
# 
# ::: 




## IGNORE THIS VERSION? 

create_div1 <- function( vname ) {
  cat( "::: {.div1} \n\n" )
  cat( paste0( "#### ", vname, " \n\n" ) )
  cat( "::: \n\n" )
}

create_div1( vname="EIN" )

#   ::: {.div1} 
#   
#   #### EIN 
#   
#   ::: 


## USE THIS VERSION? 

v_to_h4 <- function( VNAME="vname", LABEL=NULL )
{
  value  <- xx["vname"]
  txt <- paste0( "#### ",  value, " \n\n" )
  cat( txt )
}

create_div( div="div1", dd=dd2, xx=xx )

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

L <- dgf_to_list( dgf )

create_section <- function( v="EIN", dd, L ) {

  xx <- L[[ v ]]
  
  cat( "{{< pagebreak >}} \n\n") 
  cat( "::::: {.parent} \n\n" )
  
  create_div( div="div1", dd=dd, xx )
  create_div( div="div2", dd=dd, xx )
  create_div( div="div3", dd=dd, xx )
  # create_div4( dd, xx )
  # create_div5( dd, xx )

  cat( ":::::  \n\n\n\n\n\n" )

}



create_section( v="EIN", dd, L )


design <- 
 c( "div1 ;; vname   ;; ''            ;; v_to_h4",
    "div2 ;; vlabel  ;; LABEL         ;; v_to_txt",
    "div3 ;; vtype   ;; DATA TYPE     ;; v_to_txt",
    "div3 ;; scope   ;; SCOPE         ;; v_to_txt",
    "div4 ;; desc    ;; DESCRIPTION   ;; v_to_txt",
    "div4 ;; flevels ;; FACTOR LEVELS ;; v_to_txt" )

dd2 <- parse_design( design )


################
################   CREATE ALL SECTIONS (BUILD DD) 
################

create_all_sections <- function( dgf, design=NULL ) {

  if( is.null(design) )
  { dd <- data(design.df) }

  # design matrix as data frame
  dd <- parse_design( design )

  # DGF as a list of vnames
  L <- dgf_to_list( dgf )

  vars <- names(L)
  walk( vars, create_section, dd, L )

} 


create_all_sections( dgf, design )






