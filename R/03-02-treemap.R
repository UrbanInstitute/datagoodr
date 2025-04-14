

###########################################
### Paste Graphics - Factor
###########################################

### Paste Treemap (logical) -------------------
#' Print Graphics of a Factor Variable into RG
#'
#' Read rg_graphics column of DGF and print treemap in the RG
#'
#' @param VNAME A character string specifying the name of the variable whose properties are to be displayed.
#' @param LABEL A character string (from layout.TYPE object) for the section title. Defaults to `"MOST COMMON VALUES"`.
#'
#' @return This function does not return a value; it prints the formatted treemap to the RG
#'
#' @details
#' The function is an internal function of `create_div` in R/03-01-create-sections.R.
#'
#' @import treemap
#' @export
paste_treemap <- function(VNAME, LABEL = "MOST COMMON VALUES"){

  # for testing VNAME <- div.fxs$VNAME
  info <- xx[[VNAME]]
  v <- json_to_df(info)
  v$x <- as.character(v$x)


  v$Freq[4] <- 19

  total <- sum(v$Freq)
  v$PER <- v$Freq / total * 100
  min.per <- min(v$PER)


  tab.keep <- v[v$PER >= 2, ]

  #groups with less than 2% get thrown into "other" group
  if(min.per < 2){
    is.l2 <- v$PER <=2
    tab <- v[is.l2 | v$x == "other", ]
    other.total <- sum(tab$Freq)
    other.perc <- sum(tab$PER)

    is.other <- tab.keep$x == "other"
    tab.keep <- tab.keep[!is.other , ]
    tab.keep[nrow(tab.keep) +1 , ] <- c("other", other.total, other.perc)
    tab.keep$Freq <- as.numeric(tab.keep$Freq)
    tab.keep$PER <- as.numeric(tab.keep$PER)


  }


  # raw_html <- as.character(tmap_plotly)

  txt <- paste0( "**", LABEL, "**", ": ", "\n\n" )
  cat( txt )
  treemap::treemap(tab.keep,
          index="x",
          vSize="Freq",
          type="index",
          draw = TRUE)
  cat( "\n\n" )

}



