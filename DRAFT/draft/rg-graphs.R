
get_hist <- function(x)
{
  h <- hist( x )
  return(h)
}



plot_hist <- function(h)
{
  par( mar=c(1,1,0,0) )
  par(lwd=3)
  plot( h, axes=F, ann=FALSE, col="steelblue", border="lightgray" )
  axis( side=1, labels=F, tick=T, col="darkgray", lwd.ticks=0, lwd=2 )
  axis( side=2, labels=F, tick=T, col="darkgray", lwd.ticks=0, lwd=2 )
  # lines( h, lty=3, col="steelblue", border="lightgray" )
}



get_svg_hist <- function( h )
{
  s <- svglite::svgstring( width = 3, height = 2, standalone=F )
  # h <- hist( x )
  plot_hist( h )
  dev.off() 
  return( s() )
}



# x <- iris$Sepal.Length
# h <- get_hist( x )
# plot_hist( h )
# get_svg( h )


