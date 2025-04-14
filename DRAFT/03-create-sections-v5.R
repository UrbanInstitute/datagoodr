layout.numeric <- 
 c( "div2 ;; vlabel   ;; LABEL         ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE     ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE         ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION   ;; v_to_txt",
    "div4 ;; f_levels ;; LEVELS        ;; f_to_tbl",
    "div4 ;; glevels  ;; ''            ;; v_to_txt",
    "div4 ;; loc      ;; LOCATION CODE ;; v_to_txt",
    "div5 ;; v        ;; LABEL         ;; get_properties"  )

layout.character <- 
 c( "div2 ;; vlabel   ;; LABEL         ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE     ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE         ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION   ;; v_to_txt",
    "div4 ;; f_levels ;; LEVELS        ;; f_to_tbl",
    "div4 ;; glevels  ;; ''            ;; v_to_txt",
    "div4 ;; loc      ;; LOCATION CODE ;; v_to_txt",
    "div5 ;; v        ;; LABEL         ;; get_properties"  )
    
    
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

  layouts <- grep( "layout[.]", ls(), value=T )
  design <- purrr::map( layouts, f ) |> dplyr::bind_rows()
  return( design )
}



create_div1 <- function( x="vname" )
{
  cat( "::: {.div1} \n\n" )
  cat( paste0( "#### ", x, "\n\n" ) )
  cat( "::: \n\n" )
}

## div - section to create
##  dd - design matrix 
##  xx - named vector of variables

## do we need to pass the actual data ever ? 
## or can we retrieve at the higher level? 

create_div <- function( div.num="div2", all.layouts, xx ) {

  # vtype <- xx[["type"]]
  # layout.type <- dplyr::filter( all.layouts, TYPE == vtype )
  
  # skip div if not included in design
  if( ! any( div.num %in% dd$DIV ) )
  { return( NULL ) }

  div.fxs <- 
    layout.type %>% 
    dplyr::filter( DIV == div.num ) %>% 
    select( FUNCTION, VNAME, LABEL )

  cat( paste0( "::: {.", div, "} \n\n" ) )

  pwalk( div.fxs, 
     function( FUNCTION, ... ) {
       args <- list(...)
       txt <- do.call( FUNCTION, args )
       cat( txt )
     } )

  cat( "::: \n\n" )
}


create_section <- function( v="EIN", all.layouts, L ) {

  xx <- L[[ v ]]
  vtype <- xx[["type"]]
  layout.type <- dplyr::filter( all.layouts, TYPE == vtype )
  all.divs <- unique( layout.type$DIV )
  all.divs <- all.divs[ ! all.divs == "div1" ]
  
  cat( "{{< pagebreak >}} \n\n") 
  cat( "::::: {.parent} \n\n" )
  
  create_div1( v )
  # create_div( div="div2", layout.type, xx )
  # create_div( div="div3", layout.type, xx )
  walk( all.divs, create_div, layout.type, xx )
  cat( ":::::  \n\n\n\n\n\n" )

}


create_all_sections <- function( dgf ) {

  all.layouts <- get_design()

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




