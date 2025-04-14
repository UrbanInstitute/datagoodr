
booleplot <- function( f ) {

  if( is.factor(f) | is.logical(f) )
  { f <- as.character(f) }

  if( is.table(f) )
  { t <- f }
  
  if( ! is.table(f) )
  { f[ is.na(f) ] <- "NA"
    t <- table( f )  }
  
  max.t <- max(t)

  lines.at <- seq( max.t/4, max.t, length.out=4 )
  n.scale <- nchar(round(max.t,0)) - 2 
  lines.at <- round( lines.at, - n.scale )

  par( mar=c(5.1,5.1,4.1,2.1) )
  barplot( 
    rev(t), horiz=TRUE, 
    axes=F, las=2, 
    col="steelblue", 
    border="gray",
    xlim=c( 0, max(lines.at) ), 
    col.axis="gray", 
    cex.names=1.5 )

  abline( v=lines.at, lty=2, col="gray" )

  labz <- format( lines.at, big.mark="," )

  axis( side=1, at=lines.at, labels=labz, 
        col.axis="gray", cex.axis=1.5,
        tick=F  )

}

  
f <- sample( c(0,1,1,1), 10000, replace=T )
f[ c(F,F,F,T,F,F,T,F,T) ] <- NA
f[ is.na(f) ] <- "NA"
t <- table( f )


f <- sample( c(0,1,1,1), 10000, replace=T )
f[ c(F,F,F,T,F,F,F,F,T) ] <- NA
f[ c(F,F,F,F,F,F,T,F,F) ] <- ""
booleplot( f )

