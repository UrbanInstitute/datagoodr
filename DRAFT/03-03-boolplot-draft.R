



hg_plot <- function(t){

  # par( mar=c(0,0,0,0) )
  # barplot(
  #   t, col="steelblue",
  #   axisnames = FALSE,
  #   names.arg = names(t))

  bin1 <- names(t)[1]
  bin2 <- names(t)[length(t)]
  min.x <- get_bin_min( bin1 ) |> make3()
  max.x <- get_bin_max( bin2 ) |> make3()

  if( max( t/sum(t) ) > 0.1 )
  { t <- log10( t + 1 ) }

  # x11( width=8, height=2 )
  par( mar=c(2,0,1,0) )
  b <- barplot( t, col="gray25", border="white",
                axes=F, axisnames=F, space=0.05 )

  axis( side=1, at=c(b[1],b[length(b)]),
        labels=c(min.x,max.x), cex.axis=1.3,
        line=-0.5, tick=F, font=2, col.axis="gray40" )
}


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
#
#
# f <- sample( c(0,1,1,1), 10000, replace=T )
# f[ c(F,F,F,T,F,F,T,F,T) ] <- NA
# f[ is.na(f) ] <- "NA"
# t <- table( f )
#
#
# f <- sample( c(0,1,1,1), 10000, replace=T )
# f[ c(F,F,F,T,F,F,F,F,T) ] <- NA
# f[ c(F,F,F,F,F,F,T,F,F) ] <- ""
# booleplot( f )
#
# f <- sample( c(F,T,T,T,T), 10000, replace=T )
# f[ c(F,F,F,T,F,F,T,F,T) ] <- NA
# booleplot( f )
#
# f <- sample( c("no","yes","yes","yes"), 10000, replace=T )
# f[ c(F,F,F,T,F,F,T,F,T) ] <- NA
# booleplot( f )
#
#
# t <-
# structure(c(8633L, A = 3514L, B = 8988L, C = 1865L, D = 1041L,
# E = 3221L, F = 553L, G = 2287L, H = 91L, I = 3251L, J = 11336L,
# K = 3577L, L = 3870L, M = 4755L, N = 17366L, O = 419L, P = 1241L,
# Q = 546L, R = 944L, S = 33642L, T = 859L, U = 955L, V = 51L,
# W = 16145L, X = 460L, Y = 14334L, Z = 158L), dim = 27L, dimnames = list(
#     f = c("", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
#     "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
#     "W", "X", "Y", "Z")), class = "table")
#
#
# f <- rep( tt$Var1, times=tt$Freq ) |> as.factor()
#
# booleplot( f )










