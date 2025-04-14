# do.call( function, list )

# f( x, a, b, c ) 
f <- function(x, ...) 
{
  args <- list(...)     # unpack, contains a='foo'
  args$a <- "bar"       # change argument "a"
  y <- do.call( g, c( x, args ) ) # repack arguments for call to g()
  return(y)
}




x <- c( A="a", B="b", C="c" )
x

y <- c( one=1, two=2, three=3 )

l <- list( div1=x, div2=y )
l

b <- 10

test_args <- function( x )
{
  d1 <- x$div1
  print( d1 )
  d2 <- x$div2
  print( d2 )

  print( names(d1) ) 

  print( get(d1["B"]) )

}

test_args( x=l )


div1 <- c( name        = "dgf_vname" )
div2 <- c( label       = "dgf_vlabel" )
div3 <- c( data_type   = "dgf_type"  )
div4 <- c( description = "dgf_vdesc",
           factor_levels = "dgf_flevel" )

layout <- list( div1, div2, div3, div4 )



# alternatively

div <- c( "div1","div2","div3","div4","div4" )
variable <- c( "dgf_vname","dgf_vlabel","dgf_type","dgf_vdesc","dgf_flevel" )
label <- c( "name", "label", "data_type", "description", "factor_levels" )

layout <- data.frame( div, variable, label )
layout %>% knitr::kable()



show_layout <- function( vtype="numeric" )
{
  cat( '\ndiv1 <- c( name        = "dgf_vname" )' )
  cat( '\ndiv2 <- c( label       = "dgf_vlabel )' )
  cat( '\n\n' )
}


show_layout()





