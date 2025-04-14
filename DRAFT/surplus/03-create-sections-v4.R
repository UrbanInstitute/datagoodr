dgf_to_list <- function( dgf ) {
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



L$BMF_ACTIV3 %>% dput()

x <- L[[ "BMF_ACTIV3" ]]
dput(x)

x["vname"]
#        vname 
# "BMF_ACTIV3"
 
x["vlabel"]
#   vlabel 
# "ACTIV3"


# CHANGE VNAME TO FIELD 

design <- 
 c( "div2 ;; vlabel  ;; v_to_txt  ;; LABEL",
    "div2 ;; type    ;; v_to_txt  ;; DATA TYPE",
    "div2 ;; vdesc   ;; v_to_txt  ;; DESCRIPTION" )

dd2 <- parse_design( design )
dd2 <- select( dd2, FUNCTION, VNAME, LABEL )


f1 <- function( FUNCTION, ... )
{
  args <- list(...)
  do.call( FUNCTION, args )
}


f1 <- function( FUNCTION, ... ) {
  args <- list(...)
  txt <- do.call( FUNCTION, args )
  return( txt )
}

pwalk( dd2, f1 ) 

create_div1 <- function( x="vname" )
{
  cat( "::: {.div1} \n\n" )
  cat( paste0( "#### ", x, "\n\n" ) )
  cat( "::: \n\n" )
}


foo <- function(a, b){ a + b }
do.call( foo, list( a=1, b=2, c=3 ) )



to_txt_factor <- function( x, x.lab=NULL )
{
  cat( paste0( "##### ", x.lab, "\n\n" ) )
  cat( paste0( x, " \n" ), sep="" )
  cat( "\n\n" )
}



v_to_txt <- function( VNAME, LABEL )
{
  value  <- xx[VNAME]
  txt <- paste0( "**", LABEL, "**", ": ",  value, "\n\n" )
  cat( txt )
}

v_to_txt( VNAME="type", LABEL="DATA TYPE" )
v_to_txt( VNAME="vlabel", LABEL="LABEL" )
v_to_txt( VNAME="vdesc", LABEL="DESCRIPTION" )


L <- dgf_to_list( dgf )
xx <- L[["BMF_ACTIV3"]]

xx <- 
c(vname = "BMF_ACTIV3", vlabel = "ACTIV3", vdesc = "IRS Activity Code 3", 
vname_alias = "ACTIV3", first5_raw = "0 ;; \n403 ;; \n319 ;; \n279 ;; \n317", 
raw_type = "numeric", raw_convert = "as.factor()", type = "factor", 
type_class = NA, format_out = NA, first5 = "0 ;; \n403 ;; \n319 ;; \n279 ;; \n317", 
values = "[ \n  { \"stat\" : \"n_missing\",  \"ACTIV3\" : \"10993\" }, \n  { \"stat\" : \"complete_rate\",  \"ACTIV3\" : \"0.9237137583\" }, \n  { \"stat\" : \"mean\",  \"ACTIV3\" : \"5.930141e+01\" }, \n  { \"stat\" : \"sd\",  \"ACTIV3\" : \"1.441357e+02\" }, \n  { \"stat\" : \"p0\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p25\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p50\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p75\",  \"ACTIV3\" : \"0.000000e+00\" }, \n  { \"stat\" : \"p100\",  \"ACTIV3\" : \"9.950000e+02\" }, \n  { \"stat\" : \"hist\",  \"ACTIV3\" : \"▇▂▁▁▁\"}\n]", 
f_levels = NA, f_order = NA, standardize = NA, validate = NA)

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
 c( "div2 ;; vlabel  ;; v_to_txt  ;; LABEL",
    "div2 ;; type    ;; v_to_txt  ;; DATA TYPE",
    "div2 ;; vdesc   ;; v_to_txt  ;; DESCRIPTION" )

dd2 <- parse_design( design )

create_div( div="div2", dd=dd2, xx=xx )







create_section <- function( v="EIN", dd, L ) {

  xx <- L[[ v ]]
  
  cat( "{{< pagebreak >}} \n\n") 
  cat( "::::: {.parent} \n\n" )
  
  create_div1( v )
  create_div( div="div2", dd=dd, xx )
  create_div( div="div3", dd=dd, xx )
  # create_div4( dd, xx )
  # create_div5( dd, xx )

  cat( ":::::  \n\n\n\n\n\n" )

}



create_section( v="EIN", dd, L )



# design = list of all layouts
# 

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



