# COPY TEMPLATE TO LOCAL DIRECTORY TO CUSTOMIZE
# template: rg.qmd, dd.qmd, vr.qmd

#' Copy and open a Quarto template for customization (internal)
#'
#' Copies a Quarto template from the package to a specified working directory
#' and opens it for editing.
#'
#' @param template Character string specifying the template file name. Defaults
#'   to `"rg.qmd"`.
#' @param wd Character string specifying the working directory to copy the
#'   template to. Defaults to the current working directory.
#'
#' @return Invisibly returns `NULL`.
#'
#' @keywords internal
#' @noRd
customize_template <- function( template="rg.qmd", wd=NULL ) {

  # lib.path <- (.libPaths())[1]
  # pkg.path <- paste0( lib.path, "/", "datagood" )

  # online template?
  # download.file(
  #   url = URL,
  #   destfile = "./custom.qmd" )

  if( is.null(wd) ){ wd <- getwd() }
  qmd.path <- system.file( "qmd", template, package = "datagood" )
  file.copy( from=qmd.path, to=wd, overwrite=FALSE )

  filepath <- paste0( wd, "/", template )
  shell( filepath )
}


# RESEARCH GUIDE
#   data dictionary +
#   data profiles
#' Build a validation report from a data guide file (internal)
#'
#' Renders a Quarto report using a DGF Excel file and a specified template.
#'
#' @param dgfile Character string specifying the path to the data guide file
#'   (Excel). Defaults to `"DGF.xlsx"`.
#' @param template Character string specifying the Quarto template to use. If
#'   `"default"`, uses the package's built-in template.
#' @param output.file Character string specifying the output HTML file name.
#'   Defaults to `"validation-report.HTML"`.
#' @param preview Logical, whether to open the rendered HTML file after
#'   rendering. Defaults to `TRUE`.
#'
#' @return The file path of the rendered HTML report.
#'
#' @details
#' This function will eventually move from internal to exported, but step 5 is not operational yet so we leave it internal for now.
#'
#'
#' @keywords internal
#' @noRd
build_rg <-
    function( dgfile="DGF.xlsx",
              template="default",
              output.file="validation-report.HTML",
              preview=TRUE ) {

  wd <- getwd()
  filepath <- paste0( wd, "/", output.file )

  if( template == "default" )
  { qmd.path <- system.file( "qmd", "rg.qmd", package = "datagood" ) }
  if( ! template == "default" )
  { qmd.path <- template }

  quarto::quarto_render(
    input = qmd.path,
    output_file = filepath,
    execute_params = list( dgf=dgfile ) )

  # preview file
  if( preview ){ shell( filepath ) }

  return( filepath )
}




# DATA DICTIONARY
#' Build a data dictionary report from a DGF (internal)
#'
#' Renders a Quarto report generating a data dictionary using a DGF Excel file
#' and a specified template.
#'
#' @param dgfile Character string specifying the path to the data guide file
#'   (Excel). Defaults to `"DGF.xlsx"`.
#' @param template Character string specifying the Quarto template to use. If
#'   `"default"`, uses the package's built-in template.
#' @param output.file Character string specifying the output HTML file name.
#'   Defaults to `"validation-report.HTML"`.
#' @param preview Logical, whether to open the rendered HTML file after
#'   rendering. Defaults to `TRUE`.
#'
#' @return The file path of the rendered HTML report.
#'
#' @details
#' This function will eventually move from internal to exported, but step 5 is not operational yet so we leave it internal for now.
#'
#' @keywords internal
#' @noRd
build_dd <-
    function( dgfile="DGF.xlsx",
              template="default",
              output.file="validation-report.HTML",
              preview=TRUE ) {

  wd <- getwd()
  filepath <- paste0( wd, "/", output.file )

  if( template == "default" )
  { qmd.path <- system.file( "qmd", "dd.qmd", package = "datagood" ) }
  if( ! template == "default" )
  { qmd.path <- template }

  quarto::quarto_render(
    input = qmd.path,
    output_file = filepath,
    execute_params = list( dgf=dgfile ) )

  # preview file
  if( preview ){ shell( filepath ) }

  return( filepath )
}




# VALIDATION REPORT
#' Build a validation report from a DGF (internal)
#'
#' Renders a Quarto report using a DGF Excel file and a specified template.
#'
#' @param dgfile Character string specifying the path to the data guide file
#'   (Excel). Defaults to `"DGF.xlsx"`.
#' @param template Character string specifying the Quarto template to use. If
#'   `"default"`, uses the package's built-in template.
#' @param output.file Character string specifying the output HTML file name.
#'   Defaults to `"validation-report.HTML"`.
#' @param preview Logical, whether to open the rendered HTML file after
#'   rendering. Defaults to `TRUE`.
#'
#' @return The file path of the rendered HTML report.
#'
#' @details
#' This function will eventually move from internal to exported, but step 5 is not operational yet so we leave it internal for now.
#'
#' @keywords internal
#' @noRd
build_vr <-
    function( dgfile="DGF.xlsx",
              template="default",
              output.file="validation-report.HTML",
              preview=TRUE ) {

  wd <- getwd()
  filepath <- paste0( wd, "/", output.file )

  if( template == "default" )
  { qmd.path <- system.file( "qmd", "vr.qmd", package = "datagood" ) }
  if( ! template == "default" )
  { qmd.path <- template }

  quarto::quarto_render(
    input = qmd.path,
    output_file = filepath,
    execute_params = list( dgf=dgfile ) )

  # preview file
  if( preview ){ shell( filepath ) }

  return( filepath )
}
