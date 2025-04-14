

# df, 
# vtypes=NULL, 
# use.df.types=FALSE, 
# guess.factors=TRUE,
# dd=NULL, 
# vname=NULL, 
# vlabel=NULL, 
# vdesc=NULL, 
# vtype=NULL, 
# keep.dd.cols=NULL, 
# preview_dd=F, 
# preview_dp=F
                        
                     
#' @title create DGF file
#'
#' @description some description text  
#'
#' @details some additional details 
#'
#' @export
create_dgf <- function( df, 
                        vtypes=NULL, use.df.types=FALSE, 
                        guess.factors=TRUE,
                        guess.dates=FALSE,
                        dd=NULL, vname=NULL, vlabel=NULL, 
                        vdesc=NULL, vtype=NULL, 
                        keep.dd.cols=NULL, 
                        preview_dd=F, preview_dp=F )
{
  df.class <- class(df)

  is.filename <- 
    ifelse( 
      length( df.class ) == 1 & 
      "character" %in% df.class,
      TRUE,
      FALSE )
  
  is.df <- "data.frame" %in% df.class
  
  if( is.df & ! use.df.types )
  { 
    tfile <- tempfile( "temp", fileext = ".csv" )
    readr::write_csv(df, tfile)
    df <- suppressMessages( readr::read_csv( tfile ) )
  }
  
  if( is.filename )
  { df <- suppressMessages( readr::read_csv( df ) ) }

  cat( paste0( "\nThere are ", nrow(df), " rows and ", ncol(df), " columns in the dataset.\n\n" ) )

  if( guess.factors )
  { df <- recast_factors( df ) }
  
  vt <- table( sapply( df, class ) )
  cat( "Data type summary:\n" )
  print( knitr::kable( vt ) )

  # dates <- find_dates(df)
  # if( guess.dates )
  # { df <- recast_dates( df ) }
  
  N <- ncol(df)
  
  ## VAR NAMES AND LABELS 
  
  dgf_vname  <- names(df)
  dgf_vlabel <- names(df)
  dgf_vdesc  <- rep( "", N )
  dgf_vname_alias <- rep( "", N )
  
  ## VARIABLE TYPES

  dgf_first5_raw      <- sapply( df, first_n ) %>% as.character()  
  dgf_raw_type     <- sapply( df, class ) %>% as.character()
  dgf_raw_convert  <- rep( "", N )
  dgf_type         <- sapply( df, class ) %>% as.character()
  dgf_type_class   <- rep( "", N )
  dgf_format_out   <- rep( "", N )

  ## PREVIEW DATA
  
  dgf_first5          <- dgf_first5_raw
  dgf_values          <- get_values(df)
  
  ## FACTOR LABELS
  
  is.factor <- dgf_type == "factor"
  factor.names <- dgf_vname[ is.factor ]

  dgf_f_levels        <- rep( "", N )
  dgf_f_levels[ is.factor ] <- sapply( df[ factor.names ], jsonify_f ) %>% as.character()

  dgf_f_order         <- rep( "", N ) 
  dgf_f_order[ is.factor ] <- sapply( df[ factor.names ], get_levels ) %>% as.character()
  
  ## RULES
  
  dgf_standardize  <- rep( "", N )
  dgf_validate   <- rep( "", N )
  
  ## HASH VALUES OF COLUMNS
  
  dgf_duplicated <- get_dupes( df )
  
  ## CREATE FILE
  
  dgf <- data.frame( dgf_vname, dgf_vlabel, dgf_vdesc, 
                     dgf_vname_alias, dgf_duplicated,  
                     dgf_first5_raw, dgf_raw_type, dgf_raw_convert,
                     dgf_type, dgf_type_class, dgf_format_out, 
                     dgf_first5, dgf_values,
                     dgf_f_levels, dgf_f_order, 
                     dgf_standardize, dgf_validate )
                     
  # write.csv( dgf, "DGF-TEST.csv", row.names=F ) 

  save_to_excel( dgf )
  
  vt <- data.frame( VNAME=dgf_vname, TYPE=dgf_type )
  cat( "\nAssigned variable types:" )
  print( knitr::kable( vt ) )
  
  write_rules()

  return(dgf)  
}





# dgf <- create_dgf( bb )


