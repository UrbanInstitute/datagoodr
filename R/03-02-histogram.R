

###########################################
### Paste Graphics - Numeric
###########################################

### Paste Histogram (Numeric) -------------------
#' Print Graphics of a Numeric Variable into RG
#'
#' Read rg_graphics column of DGF and print histogram in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"HISTOGRAM"`.
#'
#' @return This function does not return a value; it prints the formatted histogram to the RG
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @export
paste_histogram <- function( VNAME, LABEL = "HISTOGRAM" ){

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  x.info <- json_to_list(info)

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  par( mar=c(2,0,1,0) )
  plot( x.info$mids, x.info$d,
        type="h", bty="n", lwd=4, axes=F, col="gray30" )

  x1 <- unlist(x.info$mids[1])
  x2 <- unlist(x.info$mids[length(x.info$mids)])
  min.x <- x1 |> make3()
  max.x <- x2 |> make3()

  axis( side=1, at=c(x1,x2),
        labels=c(x.info$min, x.info$max), cex.axis=1.3,
        line=-0.5, tick=F, font=2, col.axis="gray40" )

  avex <- unlist(x.info$mean)
  medx <- unlist(x.info$median)

  abline( v=avex, lty=3, lwd=2, col="firebrick" )
  abline( v=medx, lty=3, lwd=2, col="steelblue" )
  axis( side=1, at=medx, label="median", font=2,
        col.axis="steelblue", tick=F, line=-1 )
  axis( side=1, at=avex, label="mean", font=2,
        col.axis="firebrick", tick=F, line=-0.5 )

  cat( "\n\n" )

}

# FORMAT NUMBER LABELS
# SO THEY ARE ALWAYS A
# UNIFORM WIDTH FOR GRAPHS

make3 <- function(x){
  # need to fix for
  # large negative nums
  if( x < 0 ){
    x <- paste0( round(x,3) )
    return(x)
  }
  if( x >= 0 & x < 10 ){
    x <- paste0( round(x,2)  )
    return(x)
  }
  if( x >= 10 & x < 100 ){
    x <- paste0( round(x,1)  )
    return(x)
  }
  if( x > 10^2 & x < 10^6 ){
    x <- paste0( round(x/(10^3),0), "K" )
    return(x)
  }
  if( x >= 10^6 & x < 10^9 ){
    x <- paste0( round(x/(10^6),0), "M" )
    return(x)
  }
  if( x >= 10^9 & x < 10^12 ){
    x <- paste0( round(x/(10^9),0), "B" )
    return(x)
  }
  if( x >= 10^12 & x < 10^15 ){
    x <- paste0( round(x/(10^12),0), "T" )
    return(x)
  }
  if( x >= 10^15 ){
    x <- "BFN"
    return(x)
  }
}

