x <- "div3 ;; vtype   ;; DATA TYPE"

flev <- 
'[ 
  {  "f_level" :  "M"  ,  "label" :  "Mutual"  }, 
  {  "f_level" :  "O"  ,  "label" :  "Operating"  }, 
  {  "f_level" :  "S"  ,  "label" :  "Support"  }
]'


ls <- list( vtype="factor", scope="PZ", flevel=flev,
        desc="some description", loc="LOCATION-CODE-01" )

design <- 
 c( "div2 ;; vlabel  ;; LABEL",
    "div3 ;; vtype   ;; DATA TYPE",
    "div3 ;; scope   ;; SCOPE",
    "div4 ;; desc    ;; DESCRIPTION",
    "div4 ;; flevel  ;; LEVELS",
    "div4 ;; loc     ;; LOCATION CODE" )


grep( "^div3", design, value=T )


build_div3 <- function( design, ls )
{
  div3 <- grep( "^div3", design, value=T )
  purrr::walk( .x=div3, .f=get_txt, ls ) 
}

build_div4 <- function( design, ls )
{
  div4 <- grep( "^div4", design, value=T )
  purrr::walk( .x=div4, .f=get_txt, ls ) 
}

build_div3( design, ls )

build_div4( design, ls )


get_txt( div4[2], ls )



create_div <- function( div, design, ls )
{
  divx <- grep( paste0("^",div), design, value=T )
  purrr::walk( .x=divx, .f=get_txt, ls ) 
}

create_div( div="div3", design, ls )





get_txt <- function( x, ls ) 
{
  x <- 
   x %>% 
   strsplit( ";;" ) %>% 
   unlist() %>%
   trimws()
  
  # x[2] = field name
  # x[3] = field label 

  x.val <- get_field( x[2], ls )
  x.lab <- x[3]

  x_to_txt( x=x.val, x.lab=x.lab )
}

get_txt( x, ls )


string_to_txt <- function( 
    x, x.lab=NULL ) 
{
  txt <- paste0( "**", x.lab, "**", 
                 ": ", x, "\n\n"  )
  cat( txt )
}


purrr::walk( .x=div3, .f=get_txt, ls ) 

vv <- "flevel"


get_field <- function( field, ls ) 
{
  fd <- ls[[field]]

  if( is.null(fd) )
  { return(NULL) }

  if( jsonlite::validate( fd ) )
  {
    x <- jsonlite::fromJSON( fd )
  } else {
    x <- ls[[field]] |> as.character()
  }
  return( x )
}

x <- get_field( "flevel", ls )
get_field( "vtype", ls )

 

x_to_txt <- function( x, x.lab ) 
{

  if( class(x) == "character" ) 
  { 
    string_to_txt( x, x.lab ) 
  }

  if( class(x) == "data.frame" ) 
  {    
    f_to_txt( f=x, f.lab=x.lab ) 
  }
  
}

f_to_txt( f=x, f.lab="FACTOR LEVELS" )

f_to_txt <- function( f, f.lab ) {
  fkable <- knitr::kable(f)
  cat( paste0( "##### ", f.lab, "\n\n" ) )
  cat( paste0( fkable, " \n" ), sep="" )
  cat( "\n\n" )
}




f <- function( x, y="3", ... )
{
  # args <- list(...)
  ug <- as.list(environment())
  # argg <- c( as.list(environment()), list(...) )
  print( ug )
}

f( x=1:3, y="3", a="cat", b=TRUE, c=c(1,0,1) )


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



