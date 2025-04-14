library( yarrr )
library( treemap )

tt <- 
structure(list(Var1 = structure(1:27, levels = c("", "A", "B", 
"C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", 
"P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"), class = "factor"), 
    Freq = c(8633L, 3514L, 8988L, 1865L, 1041L, 3221L, 553L, 
    2287L, 91L, 3251L, 11336L, 3577L, 3870L, 4755L, 17366L, 419L, 
    1241L, 546L, 944L, 33642L, 859L, 955L, 51L, 16145L, 460L, 
    14334L, 158L), col = c("#FCEEB4FF", "#C7CEEDFF", "#B4BEE7FF", "#FFD2C0FF", 
    "#FFF7DAFF", "#F5BFB8FF", "#ECEEF9FF", "#E6F4CAFF", "#FFFFFFFF", 
    "#FEF2C7FF", "#FFB497FF", "#FFC3ABFF", "#DEF1B9FF", "#EFA9A1FF", 
    "#FAEAA1FF", "#F7FBEDFF", "#DADEF3FF", "#FFFBECFF", "#EFF8DCFF", 
    "#A1AFE0FF", "#FFE1D5FF", "#F9D4CFFF", "#FFFFFFFF", "#E8948BFF", 
    "#FDE9E7FF", "#D5EDA7FF", "#FFF0EAFF")), row.names = c(NA, 
-27L), class = "data.frame")



piratepal( palette = "all" )


fx( "evildead" )
fx( "up" )
fx( "info" )
fx( "ohbrother" )
fx( "appletv" )
fx( "brave" )
fx( "espresso" )
fx( "ipod" )
fx( "brave" )
fx( "decision" )
fx( "xmen" )
fx( "usualsuspects" )
fx( "basel" )
fx( "eternal" )
fx( "google" )
fx( "nemo" )


fx <- function( pal.type ) {

  nlevs    <- nlevels(f)
  pal      <- yarrr::piratepal( palette = pal.type )
  n.loops  <- ceiling( nlevs/length(pal) )
  step     <- 1 / n.loops 
  mix.w <- seq( from = 0.7, to = 1, length.out=(n.loops-1) )
  mix.w <- c( 0.5, mix.w )

  pal.yar <- NULL

  for( i in mix.w )
  {

    col.yar <- yarrr::piratepal( 
        palette = pal.type,
        mix.p = i )

     pal.yar <- c( pal.yar, col.yar )
  }

  tt <- dplyr::arrange( tt, -Freq )
  tt$col <- pal.yar[1:nlevs]
  tt <- dplyr::arrange( tt, Var1 )
  tt$id <- 1:nrow(tt)

  treemap( tt,
    index="Var1",
    vSize="Freq",
    vColor="id",
    type="manual",
    palette=tt$col,
    border.col="gray80",
    position.legend="none",
    title=pal.type,
    algorithm="pivotSize",
    sortID="id" )

}

fx( "up" )





