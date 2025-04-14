

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
create_dgf <- function(         # ----------------
  
    df, vtypes=NULL, 
    use.df.types=FALSE, 
    guess.factors=TRUE,
    guess.dates=FALSE,
    dd=NULL, vname=NULL, vlabel=NULL, 
    vdesc=NULL, vtype=NULL, 
    keep.dd.cols=NULL, 
    preview_dd=F, preview_dp=F ) 
    
 {  # ---------------------------------------------
 
 
  df.class <- class(df)
  
  is.df <- "data.frame" %in% df.class

  ## IF DF IS NOT A DATA FRAME THEN 
  ## LOAD FILE FROM MEMORY BY FILENAME
  
  is.filename <- ifelse( 
      length( df.class ) == 1 & 
      "character" %in% df.class,
      TRUE,
      FALSE )

  if( is.filename )
  { df <- suppressMessages( readr::read_csv( df ) ) }
  
  ## RELOAD DATA WITH READR TO RESET DATA TYPES? 
  
  if( is.df & ! use.df.types )
  { 
    tfile <- tempfile( "temp", fileext = ".csv" )
    readr::write_csv(df, tfile)
    df <- suppressMessages( readr::read_csv( tfile ) )
  }
  
  cat( paste0( 
    "\nThere are ", nrow(df), " rows and ", 
    ncol(df), " columns in the dataset.\n\n"  ) )

  ## TRY TO GUESS FACTORS 

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
  
  vname        <- names(df)
  vlabel       <- names(df)
  vdesc        <- rep( "", N )
  vname_alias  <- rep( "", N )

  ## HASH VALUES OF COLUMNS
  
  vhash <- sapply( df, rlang::hash )
  duplicates  <- get_dupes( df, vhash )
  names(vhash) <- NULL
  
  ## VARIABLE TYPES

  raw_first5    <- sapply( df, first_n ) %>% as.character()  
  raw_type      <- sapply( df, class ) %>% as.character()
  raw_convert   <- rep( "", N )
  vtype         <- sapply( df, class ) %>% as.character()
  vtype_class   <- rep( "", N )
  vformat_out   <- rep( "", N )

  ## PREVIEW DATA
  
  first5        <- dgf_first5_raw
  stats         <- get_values(df)
  
  ## CREATE FACTOR LABEL TABLES (JSON CELLS)
  
  is.factor    <- dgf_type == "factor"
  factor.names <- dgf_vname[ is.factor ]

  f_levels  <- rep( "", N )
  f_levels[ is.factor ] <- 
    sapply( df[ factor.names ], jsonify_f ) %>% 
    as.character()

  f_order  <- rep( "", N ) 
  f_order[ is.factor ] <- 
    sapply( df[ factor.names ], get_levels ) %>% 
    as.character()
  
  ## ADD BLANK RULE COLUMNS 
  
  dgf_standardize  <- rep( "", N )
  dgf_validate     <- rep( "", N )
  

  ## ADD COLUMN HASH VALUES 
  
  
  
  ## CREATE FILE
  
  dgf <- 
    data.frame( 
      vname, vlabel, vdesc, 
      vname_alias, duplicates,  
      raw_first5, raw_type, raw_convert,
      vtype, vtype_class, vformat_out, 
      first5, stats,
      f_levels, f_order, 
      dgf_standardize, dgf_validate, vhash )
                     
  # write.csv( dgf, "DGF-TEST.csv", row.names=F ) 

  save_to_excel( dgf )
  
  vt <- data.frame( VNAME=vname, TYPE=vtype )
  cat( "\nAssigned variable types:" )
  print( knitr::kable( vt ) )
  
  create_rules_file()

  return(dgf)  
}





# dgf <- create_dgf( bb )


