# COPY TEMPLATE TO LOCAL DIRECTORY TO CUSTOMIZE
# template: rg.qmd, dd.qmd, vr.qmd

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