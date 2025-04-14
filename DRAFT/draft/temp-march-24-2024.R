layout.num <- 
 c( "div2 ;; vlabel   ;; LABEL         ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE     ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE         ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION   ;; v_to_txt",
    "div4 ;; f_levels ;; LEVELS        ;; f_to_txt",
    "div4 ;; glevels  ;; ''            ;; v_to_txt",
    "div4 ;; loc      ;; LOCATION CODE ;; v_to_txt",
    "div5 ;; v        ;; LABEL         ;; get_properties"  )

layout.chr <- 
 c( "div2 ;; vlabel   ;; LABEL         ;; v_to_txt",
    "div3 ;; vtype    ;; DATA TYPE     ;; v_to_txt",
    "div3 ;; scope    ;; SCOPE         ;; v_to_txt",
    "div4 ;; desc     ;; DESCRIPTION   ;; v_to_txt",
    "div4 ;; f_levels ;; LEVELS        ;; f_to_txt",
    "div4 ;; glevels  ;; ''            ;; v_to_txt",
    "div4 ;; loc      ;; LOCATION CODE ;; v_to_txt",
    "div5 ;; v        ;; LABEL         ;; get_properties"  )
    
    

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



create_all_sections <- function( dgf ) {

  layouts <- get_design()

  #  --------------------------------
  #  DGF AS A LIST OF VARIABLES
  #  --------------------------
     
     dgf.content <- dgf_to_list( dgf )

  #  --------------------------------
  #  BUILD A REPORT SECTION FOR EACH 
  #  VARIABLE IN THE DATASET 
  #  --------------------------------

     all.vars <- names( dgf.content )
     walk( all.vars, create_section, layouts, dgf.content )

} 







