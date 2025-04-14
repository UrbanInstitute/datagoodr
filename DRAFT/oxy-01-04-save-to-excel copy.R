#  1 dgf_vname, 
#  --- G1  # BLUES
#  2 dgf_vlabel, 
#  3 dgf_vdesc, 
#  4 dgf_vname_alias,

### dgf_duplicated, 

#  --- G2  # BROWNS
#  5 dgf_first5_raw,
#  6 dgf_raw_type, 
#  7 dgf_raw_convert,
#  8 dgf_type, 
#  9 dgf_type_class, 
#  10 dgf_format_out,
#  --- G3  # BROWNS
#  11 dgf_first5, 
#  12 dgf_values,
#  13 dgf_f_levels, 
#  14 dgf_f_order, 
#  --- G4  # BLUES
#  15 dgf_standardize, 
#  16 dgf_validate 

# darkblue  headers: #44546A  cells: #E3E7ED
# darkbrown headers: #833C0C  cells: #FEF2EC

# wb <- loadWorkbook( "DGF2.xlsx" )
# wb <- openxlsx( "DGF3.xlsx" )
# wb <- read.xlsx( "DGF3.xlsx" )





#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param df PARAM_DESCRIPTION
#' @param filename PARAM_DESCRIPTION, Default: 'DGF.xlsx'
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso 
#'  \code{\link[openxlsx]{createWorkbook}}, \code{\link[openxlsx]{addWorksheet}}, \code{\link[openxlsx]{writeData}}, \code{\link[openxlsx]{setRowHeights}}, \code{\link[openxlsx]{setColWidths}}, \code{\link[openxlsx]{modifyBaseFont}}, \code{\link[openxlsx]{createStyle}}, \code{\link[openxlsx]{addStyle}}, \code{\link[openxlsx]{freezePane}}, \code{\link[openxlsx]{saveWorkbook}}, \code{\link[openxlsx]{openXL}}
#' @rdname save_to_excel
#' @export 
#' @importFrom openxlsx createWorkbook addWorksheet writeData setRowHeights setColWidths modifyBaseFont createStyle addStyle freezePane saveWorkbook openXL
save_to_excel <- function( df, filename="DGF.xlsx" )
{

  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet( wb, "DGF" )
  openxlsx::writeData( wb, sheet="DGF", x=df )

  nrow <- nrow(df) + 1
  ncol <- ncol(df)

  g1 <- 2:5
  g2 <- 6:11
  g2.2 <- 8:10
  g3 <- 12:15
  g3.2 <- 13:16
  g4 <- 16:17

  openxlsx::setRowHeights( wb, sheet=1, rows=1:nrow, heights=25  )
  openxlsx::setColWidths(  wb, sheet=1, cols=1:ncol,  widths =20 )

  openxlsx::modifyBaseFont( wb, fontSize=11, fontName='Calibri Light' )

  # valign <- openxlsx::createStyle( valign = "center" )
  # openxlsx::addStyle( wb, sheet=1, style=valign, 
  #           rows=1:nrow, cols=1:ncol, 
  #           gridExpand=TRUE, stack=TRUE )

  headerStyle <- 
    openxlsx::createStyle(
      fontName = 'Segoe UI Black', 
      fontSize = 12, 
      fontColour = "#FFFFFF", 
      textDecoration="bold", 
      halign = "left", 
      valign = "center", 
      fgFill = "#404040"  )
      
  openxlsx::addStyle( wb, sheet=1, 
    headerStyle, rows=1, cols=1:ncol )


  vname <- 
    openxlsx::createStyle(
      fontName = 'Segoe UI Black', 
      fontSize = 12, 
      fontColour = "#FFFFFF", 
      fgFill = "#404040",
      halign = "left", 
      valign = "center" )
    
  openxlsx::addStyle( wb, sheet=1, vname, rows=2:nrow, cols=1 )

  vname.blue <- openxlsx::createStyle(
    fgFill = "#44546A" )
  openxlsx::addStyle( wb, sheet=1, vname.blue, 
    rows=1, cols=c(g1,g3), stack=T )

  vname.brown <- openxlsx::createStyle(
    fgFill = "#833C0C" )
  openxlsx::addStyle( wb, sheet=1, vname.brown, 
    rows=1, cols=c(g2,g4), stack=T )

  blues <- openxlsx::createStyle(
    fgFill = "#E3E7ED" )
  openxlsx::addStyle( wb, sheet=1, blues, 
    rows=2:nrow, cols=g1, gridExpand=TRUE, stack=T  )
  openxlsx::addStyle( wb, sheet=1, blues, 
    rows=2:nrow, cols=g3, gridExpand=TRUE, stack=T  )

  browns <- openxlsx::createStyle(
    fgFill = "#FEF2EC" )
  openxlsx::addStyle( wb, sheet=1, browns, 
    rows=2:nrow, cols=g2, gridExpand=TRUE, stack=T  )
  openxlsx::addStyle( wb, sheet=1, browns, 
    rows=2:nrow, cols=g4, gridExpand=TRUE, stack=T  )

  # first3 <- openxlsx::createStyle( valign = "top" )
  # openxlsx::addStyle( wb, sheet=1, first3, 
  #   rows=2:20, cols=5, stack=T )

  indentAll <- openxlsx::createStyle(
    indent = 1 )

  openxlsx::addStyle( wb, sheet=1, indentAll, 
    rows=1:nrow, cols=1:ncol,  
    gridExpand=TRUE, stack=TRUE  )

  monospace <- openxlsx::createStyle(
    fontName = 'Lucida Console', 
    fontSize = 10,
    halign = "left", 
    valign = "center" )

  openxlsx::addStyle( wb, sheet=1, monospace, 
    rows=2:nrow, cols=c(g2.2,g3.2), gridExpand=TRUE, stack=T )

  ninePoint <- openxlsx::createStyle(
    fontName = 'Calibri Light', 
    fontSize = 9 )

  openxlsx::addStyle( wb, sheet=1, ninePoint, 
    rows=2:nrow, cols=6:7, gridExpand=TRUE, stack=T  )
  openxlsx::addStyle( wb, sheet=1, ninePoint, 
    rows=2:nrow, cols=12:13, gridExpand=TRUE, stack=T  )
    
  openxlsx::freezePane( wb, sheet=1, firstActiveRow=2, firstActiveCol=2 )

  # unlocked <- openxlsx::createStyle( locked = FALSE )
  # openxlsx::addStyle( wb, sheet=1, unlocked, 
  #   rows=2:nrow, cols=2:4, gridExpand=TRUE, stack=T  )
  # openxlsx::addStyle( wb, sheet=1, unlocked, 
  #   rows=2:nrow, cols=7:ncol, gridExpand=TRUE, stack=T  ) 
  # openxlsx::addStyle( wb, sheet=1, unlocked, 
  #   rows=1:nrow, cols=1, stack=T  ) 
  # openxlsx::addStyle( wb, sheet=1, unlocked, 
  #   rows=1, cols=1:ncol, stack=T  ) 
  # openxlsx::protectWorksheet( wb, "DGF", protect = TRUE )
  
  openxlsx::saveWorkbook( wb, filename, overwrite = TRUE )
  openxlsx::openXL( filename )
  return(invisible(NULL))
}





# save_to_excel( dgf )

