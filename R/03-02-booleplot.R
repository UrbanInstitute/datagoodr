

###########################################
### Paste Graphics - Logical
###########################################

### Paste Booleplot (logical) -------------------
#' Print Graphics of a Logical Variable into RG
#'
#' Read rg_graphics column of DGF and print Booleplot in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"BAR PLOT"`.
#'
#' @return This function does not return a value; it prints the formatted Booleplot to the RG
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#'
#' @keywords internal
#' @noRd
paste_booleplot <- function( VNAME, LABEL = "BAR PLOT" ) {

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  v <- json_to_df(info)

  v[ is.na(v) ] <- "NA"

  max.t <- max(v$Freq)

  lines.at <- seq( max.t/4, max.t, length.out=4 )
  n.scale <- nchar(round(max.t,0)) - 2
  lines.at <- round( lines.at, - n.scale )


  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )

  barplot(
    v$Freq, horiz=TRUE,
    axes=F, las=2,
    names.arg = v$f,
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


  cat( "\n\n" )

}



