

dgf_to_list <- function( dgf ) {

  m <- t(dgf)
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




# GET ALL LAYOUTS FROM ENV
# AND RETURN DESIGN MATRIX

get_design <- function() {

  #  ---------------------------------------------
  #  compile all layouts into a design df

     f <- function(x){
       lab <- gsub( "layout[.]", "", x )
       cbind( TYPE=lab, parse_design( get(x) ) ) }

  #  ----------------------------------------------

  layouts <- grep( "layout[.]", ls( envir=.GlobalEnv ), value=T )
  design.df <- purrr::map( layouts, f ) |> dplyr::bind_rows()
  return( design.df )
}


#  get_design() |> knitr::kable()
#
#  |TYPE      |DIV   |VNAME    |LABEL       |FUNCTION         |
#  |:---------|:-----|:--------|:-----------|:----------------|
#  |character |div2  |vlabel   |LABEL       |v_to_txt         |
#  |character |div3  |vtype    |DATA TYPE   |v_to_txt         |
#  |character |div4  |desc     |DESCRIPTION |v_to_txt         |
#  |character |div8  |v        |PROPERTIES  |get_properties   |
#  |character |div9  |v        |PREVIEW     |get_examples_chr |
#  |character |div10 |v        |STATS       |get_stats_chr    |
#  |character |div11 |v        |''          |get_wordcloud    |
#  |factor    |div2  |vlabel   |LABEL       |v_to_txt         |
#  |factor    |div3  |vtype    |DATA TYPE   |v_to_txt         |
#  |factor    |div4  |desc     |DESCRIPTION |v_to_txt         |
#  |factor    |div4  |f_levels |LEVELS      |f_to_tbl         |
#  |factor    |div12 |v        |PROPERTIES  |get_properties   |
#  |factor    |div13 |v        |STATS       |get_stats_fact   |
#  |factor    |div14 |v        |''          |get_treemap      |
#  |numeric   |div2  |vlabel   |LABEL       |v_to_txt         |
#  |numeric   |div3  |vtype    |DATA TYPE   |v_to_txt         |
#  |numeric   |div4  |desc     |DESCRIPTION |v_to_txt         |
#  |numeric   |div5  |v        |PROPERTIES  |get_properties   |
#  |numeric   |div6  |v        |QUANTILES   |get_quantiles    |
#  |numeric   |div7  |v        |STATS       |get_stats_num    |
#  |numeric   |div8  |v        |HIST        |get_histogram    |
#  |numeric   |div9  |v        |PREVIEW     |get_examples_num |




## div - section to create
##  dd - design matrix
##  xx - named vector of variables

## do we need to pass the actual data ever ?
## or can we retrieve at the higher level?


create_div1 <- function( x="vname" )
{
  cat( "::: {.div1} \n\n" )
  cat( paste0( "#### ", x, "\n\n" ) )
  cat( "::: \n\n" )
}



create_div <- function( div.num="div2", all.layouts, xx ) {

  DATA_TYPE <- xx[["vtype_class"]] # change data_type to vtype_class
  layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )

  # skip div if not included in design
  if( ! any( div.num %in% layout.type$DIV ) ) #there is not column in dd called $DIV, is this supposed to be layouttype?
  { return( NULL ) }

  div.fxs <-
    layout.type %>%
    dplyr::filter( DIV == div.num ) %>%
    select( FUNCTION, VNAME, LABEL )

  cat( paste0( "::: {.", div.num, "} \n\n" ) )

  pwalk( div.fxs,
     function( FUNCTION, ... ) {
       args <- list(...)
       txt <- do.call( FUNCTION, args )
       cat( txt, sep="\n" )
     } )

  cat( "\n\n::: \n\n" )
}





create_section <- function( VNAME="EIN", all.layouts, L ) {

  xx <<- L[[ VNAME ]] #make this a global variable?
  xx[["VNAME"]] <- VNAME
  DATA_TYPE <- xx[["vtype_class"]] #change data_type to vtype_class
  layout.type <- dplyr::filter( all.layouts, TYPE == DATA_TYPE )
  all.divs <- unique( layout.type$DIV )
  all.divs <- all.divs[ ! all.divs == "div1" ]

  cat( "{{< pagebreak >}} \n\n")
  cat( "::::: {.parent} \n\n" )

  create_div1( VNAME )
  # create_div( div="div2", layout.type, xx )
  # create_div( div="div3", layout.type, xx )
  walk( all.divs, create_div, layout.type, xx )
  cat( ":::::  \n\n\n\n\n\n" )

}


create_all_sections <- function( dgf ) {

  all.layouts <- get_design()

  #for testing purposes - remove later
  # only run working divs for numeric
  # all.layouts <- all.layouts %>%
  #   filter(DIV %in% c("div2", "div3", "div4", "div5", "div6", "div7", "div8" ))

  #  --------------------------------
  #  DGF AS A LIST OF VARIABLES
  #  --------------------------

     dgf.content <- dgf_to_list( dgf )

  #  --------------------------------
  #  BUILD A REPORT SECTION FOR EACH
  #  VARIABLE IN THE DATASET
  #  --------------------------------

     all.vars <- names( dgf.content )
     walk( all.vars, create_section, all.layouts, dgf.content )

}




