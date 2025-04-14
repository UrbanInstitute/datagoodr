f_to_txt <- function( x, x.lab=NULL )
{
  cat( paste0( "##### ", x.lab, "\n\n" ) )
  cat( paste0( x, " \n" ), sep="" )
  cat( "\n\n" )
}



v_to_txt <- function( VNAME, LABEL )
{
  value  <- xx[VNAME]
  txt <- paste0( "**", LABEL, "**", ": ",  value, "\n\n" )
  cat( txt )
}
