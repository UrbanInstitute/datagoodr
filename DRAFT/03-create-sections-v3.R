
# NUMERIC
design.n <- 
 c( "div2 ;; vlabel  ;; LABEL",
    "div3 ;; vtype   ;; DATA TYPE",
    "div3 ;; scope   ;; SCOPE",
    "div4 ;; desc    ;; DESCRIPTION",
    "div4 ;; flevels ;; LEVELS",
    "div4 ;; loc     ;; LOCATION CODE" )

# FACTOR    
design.f <- 
 c( "div2 ;; vlabel  ;; LABEL",
    "div3 ;; vtype   ;; DATA TYPE",
    "div3 ;; scope   ;; SCOPE",
    "div4 ;; desc    ;; DESCRIPTION",
    "div4 ;; flevels ;; LEVELS",
    "div4 ;; loc     ;; LOCATION CODE" )

# CHARACTER   
design.c <- 
 c( "div2 ;; vlabel  ;; LABEL",
    "div3 ;; vtype   ;; DATA TYPE",
    "div3 ;; scope   ;; SCOPE",
    "div4 ;; desc    ;; DESCRIPTION",
    "div4 ;; flevels ;; LEVELS",
    "div4 ;; loc     ;; LOCATION CODE" )

# DATE  
design.d <- 
 c( "div2 ;; vlabel  ;; LABEL",
    "div3 ;; vtype   ;; DATA TYPE",
    "div3 ;; scope   ;; SCOPE",
    "div4 ;; desc    ;; DESCRIPTION",
    "div4 ;; flevels ;; LEVELS",
    "div4 ;; loc     ;; LOCATION CODE" )

# BOOLEAN  
design.d <- 
 c( "div2 ;; vlabel  ;; LABEL",
    "div3 ;; vtype   ;; DATA TYPE",
    "div3 ;; scope   ;; SCOPE",
    "div4 ;; desc    ;; DESCRIPTION",
    "div4 ;; flevels ;; LEVELS",
    "div4 ;; loc     ;; LOCATION CODE" )


create_rg <- function()
# creates QMD file


######
######  RECURSIVE ARGUMENTS 
######

f1 <- function( a, b )
{
  args <- as.list( environment() )
  do.call( f2, args )
}

f2 <- function( a, b )
{
  2*a + 3*b
}

f1( a=2, b=1 )




######
######   research-guide.QMD 
######

design <- 
 c( "div2 ;; vlabel  ;; LABEL",
    "div3 ;; vtype   ;; DATA TYPE",
    "div3 ;; scope   ;; SCOPE",
    "div4 ;; desc    ;; DESCRIPTION",
    "div4 ;; flevels ;; LEVELS",
    "div4 ;; loc     ;; LOCATION CODE" )
    



create_section <- function( 
    dgf, 
    df, sample.n=FALSE,
    vname,
    properties = TRUE,
    quantiles  = TRUE,
    stats      = TRUE,
    histogram  = TRUE,
    values     = TRUE,
    design     = design ) {   

  row   <- get_row( vname, dgf )
  vtype <- row[["dgf_type"]]
  
  defined.types <- 
    c("numeric","character",
      "factor","date","boolean")
  
  type.inspect <- 
    vtype %in% c(
  
  args <- as.list(environment())
  
  if( vtype == "numeric" )
  { do.call( create_section_n, args ) }
  
  if( vtype == "numeric" )
  { do.call( create_section_n, args ) }
  
  if( vtype == "numeric" )
  { do.call( create_section_n, args ) }
  
  if( vtype == "numeric" )
  { do.call( create_section_n, args ) }
  
  if( vtype == "numeric" )
  { do.call( create_section_n, args ) }

}




create_section_n <- function( 
    dgf, 
    df, sample.n=FALSE,
    vname, row,
    properties = TRUE,
    quantiles  = TRUE,
    stats      = TRUE,
    histogram  = TRUE,
    values     = TRUE,
    design     = design  ) {

  
  vtype <- row[["dgf_type"]]
  
  if( sample.n == FALSE )
  { v <- df[[vname]] } else {
    df <- dplyr::sample_n( df, sample.n )
    v <- df[[vname]]
  }

  cat( "::::: {.parent} \n\n" )
  
  create_div1( vname )  
  
  create_div( div="div2", design, row )
  create_div( div="div3", design, row )
  create_div( div="div4", design, row )

  if( properties )
  { create_div5_n( v ) }

  if( quantiles )
  { create_div6_n( v ) }
  
  if( stats )
  { create_div7_n( v ) }
  
  if( histogram )
  { create_div8_n( v ) }
  
  if( values )
  { create_div9_n( v ) }
  
  cat( "::::: \n\n" )
  cat( "{{< pagebreak >}} \n\n")  
  
}





## VARIABLE NAME (div1) 

create_div1 <- function( x=vname ) {
  cat(  "::: {.div1} \n\n"  )
  cat( paste0(  "#### ",  x,  "\n\n"  ) )
  cat(  "::: \n\n"  )
}

create_div1( x=vname )


## VARIABLE LABEL (div2)

create_div2 <- function( 
    x=vlabel, 
    x.lab="LABEL" ) {

  cat( "::: {.div2} \n\n" )
  v_to_txt( x, x.lab )
  cat( "::: \n\n" )
}

create_div2( x2=vlabel )


## VARIABLE TYPE (div3)

create_div3 <- function( 
    x3=vtype, 
    x3.lab="DATA TYPE", 
    x4=vscope, 
    x4.lab="SCOPE" ) {

  cat( "::: {.div3} \n\n" )
  v_to_txt( x3, x3.lab )
  v_to_txt( x4, x4.lab )
  cat( "::: \n\n" )
}

create_div3( x3=vtype, x4=vscope )



## DESCRIPTION (div4)

create_div4 <- function( 
    x5=desc, x5.lab="DESCRIPTION", 
    x6=k,    x6.lab="LEVELS", 
    x7=loc,  x7.lab="LOCATION CODE" ) {
  cat( "::: {.div4} \n\n" )
  v_to_txt( x5, x5.lab )
  v_to_txt( x6, x6.lab )
  v_to_txt( x7, x7.lab )
  cat( "::: \n\n" )
}

create_div4( x5=desc, x6=k, x7=loc )


## PROPERTIES (div5)

create_div5_n <- function( x ) {
  cat( "::: {.div5} \n\n" )
  cat( "##### Properties \n\n" )
  build_proptable_numeric( x )
  cat( "::: \n\n" )
}

create_div5( v )


## QUANTILES (div6)

create_div6_n <- function( x ) {
  cat( "::: {.div6} \n\n" )
  cat( "##### Quantiles \n\n" )
  build_quanttable_numeric( x )
  cat( "::: \n\n" )
}

create_div6( v )


## SUMMARY STATS (div7)

create_div7_n <- function( x ) {
  cat( "::: {.div7} \n\n" )
  cat( "#### Summary Stats \n\n" )
  build_stattable_numeric( x )
  cat( "::: \n\n" )
}

create_div7( v )


## HISTOGRAM (div8)

create_div8_n <- function( x ) {
  cat( "::: {.div8} \n\n" )
  cat( "##### Histogram \n\n" )
  hg( x )
  cat( "\n::: \n\n" )
}

create_div8( v )


## EXAMPLE VALUES (div9)

create_div9_n <- function( x ) {
  cat( "::: {.div9} \n\n" )
  cat( "##### Example Values \n\n" )
  cat( paste0( build_table( x ), " \n\n"  ) )
  cat( "::: \n\n" )
}

create_div9( v )



