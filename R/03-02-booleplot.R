

###########################################
### Paste Graphics - Logical
###########################################

### Paste Booleplot (logical) -------------------
#' Print the bar plot of a logical variable into the RG
#'
#' Reads the `rg_graphics` column of the DGF and draws a horizontal bar plot of
#' the value counts. Instead of an axis, each bar is labelled to its right with
#' its count and share (`22.6K (90%)`), using [abbrev_num()] so large counts
#' stay compact and never crop. Since a logical has only a few categories, this
#' carries the count table inside the plot.
#'
#' @param VNAME A character string naming the DGF column to read (the layout
#'   passes `"rg_graphics"`).
#' @param LABEL A character string for the section title. Defaults to
#'   `"VALUES"`.
#'
#' @return No return value; draws the bar plot into the RG.
#' @details Internal to `create_div` in R/03-01-create-sections.R.
#' @export
paste_booleplot <- function( VNAME, LABEL = "VALUES" ) {

  info <- get_xx()[[VNAME]]
  v <- json_to_df(info)
  v[ is.na(v) ] <- "NA"
  v$Freq <- as.numeric( as.character( v$Freq ) )

  pct <- round( v$Freq / sum(v$Freq) * 100, 0 )
  lab <- paste0( abbrev_num(v$Freq), "  (", pct, "%)" )

  cat( paste0( "**", LABEL, "**", ": ", "\n\n" ) )

  # left margin holds the category names; right headroom holds the labels
  par( mar = c(1, 4.5, 1, 0.5), xpd = NA )
  bp <- barplot(
    v$Freq, horiz = TRUE, axes = FALSE, las = 1,
    names.arg = v$f, col = "steelblue", border = "white",
    xlim = c( 0, max(v$Freq) * 1.35 ), cex.names = 1.3, col.axis = "gray30" )

  text( v$Freq, bp, labels = lab, adj = c(-0.12, 0.5),
        cex = 1.2, font = 2, col = "gray30" )

  cat( "\n\n" )
}



