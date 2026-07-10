

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
         df,
         vtypes=NULL,
         use.df.types=FALSE,
         guess.factors=TRUE,
         guess.dates=FALSE,
         dd=NULL,
         vname=NULL,
         vlabel=NULL,
         vdesc=NULL,
         vtype=NULL,
         vconvert = NULL,
         vformat = NULL,
         vname_alias = NULL,
         keep.dd.cols=NULL,
         preview_dd=F,
         preview_dp= F,
         file="DGF")

 {  # ---------------------------------------------

  # Load data frame
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

  N_row <- nrow(df)
  N_col <- ncol(df)
  cat( paste0(
    "\nThere are ", N_row, " rows and ",
    N_col, " columns in the dataset.\n\n"  ) )


  ## VAR NAMES AND LABELS

  vname        <- names(df)
  vlabel       <- names(df)
  if(is.null(vdesc)){vdesc <- rep("", N_col)}
  if(is.null(vname_alias)){vname_alias<-rep("", N_col)}
  raw_type      <- sapply( df, class ) %>% as.character()


  ## TRY TO GUESS FACTORS
  if( guess.factors )
  { df <- recast_factors( df ) }
  guess_type <- sapply( df, class ) %>% as.character()
  # data.frame(raw_type, guess_type)

  correct.guess <- substr(vconvert, 4,nchar(vconvert)) == guess_type

  ## Set up data classes
  if(!is.null(vconvert)){
    df_converted <- sapply(seq_along(vconvert), function(i) {
      if (is.na(vconvert[i]) | correct.guess[i]) {
        return(dplyr::pull(df[, i], 1))  # Keep the original column if vconvert[i] is NA
      } else {
        func_name <- vconvert[i]
        if (exists(func_name, mode = "function")) {
            return(try(sapply(dplyr::pull(df[,i],1), get(func_name)), silent=TRUE))
        } else {
          warning(paste("Function", func_name, "not found. Returning original column."))
          return(df[, i])  # Keep original column if function doesn't exist
        }
      }
    }, simplify = FALSE)  # Keep output as a list to avoid unintended type conversion

    # Convert back to a data frame
    df <- as.data.frame(df_converted)
    names(df ) <- vname
  }
  data_type_converted <- sapply( df, class )

  # data.frame(raw_type, guess_type, data_type_converted) # see what converted


  dd_f_level <- mapply(function(vname, type, df){
    if(type %in% c("factor", "logical")){
      tab <- data.frame(levels = levels(df[,vname]))
      tab <- jsonify_df(tab)
      return(tab)
      }else{
        return("")
      }
    },
    vname = vname,type=data_type_converted, MoreArgs = list(df = df) )


  ## Need to guess factor it is logical, to make class
  vclass <- data_type_converted
  is.logical <- 2 == sapply(vname[vclass == "factor"], function(x){length(table(df[,x]))})
  vclass[names(is.logical[is.logical])] <- "logical"

  # Print types of classes
  vt <- table( vclass )
  cat( "Data type summary:\n" )
  print( knitr::kable( vt ) )

  # dates <- find_dates(df)
  # if( guess.dates )
  # { df <- recast_dates( df ) }


  ## Do the format
  #
  # vformat applies a *display* transformation to each column (e.g. zero-pad
  # EINs, style dates). It only shapes how values are previewed, so the
  # formatted frame (df_fmt) is kept separate from the underlying converted
  # data (df). Statistics and graphics for numeric/logical variables must be
  # computed on the real values, not their formatted strings (df_stats below).

  if(!is.null(vformat)){
    df_converted <- sapply(seq_along(vformat), function(i) {
      if (is.na(vformat[i])) {
        return(c(df[, i]))  # Keep the original column if vformat[i] is NA
      } else {
        func_name <- vformat[i]
        if (exists(func_name, mode = "function")) {
          return(try(sapply(c(df[,i]), get(func_name)), silent=TRUE))
        } else {
          warning(paste("Function", func_name, "not found. Returning original column."))
          return(c(df[, i]))  # Keep original column if function doesn't exist
        }
      }
    }, simplify = FALSE)  # Keep output as a list to avoid unintended type conversion

    # Convert back to a data frame
    df_fmt <- as.data.frame(df_converted)
    names(df_fmt) <- vname
  }else{
    vformat <- rep("", N_col)
    df_fmt <- df
  }

  # Data used for stats/graphics: formatted values for factor/character
  # (so, e.g., dates display as they are formatted), but the underlying
  # unformatted values for numeric/logical (so histograms and numeric
  # summaries are computed on real numbers, never on formatted strings).
  df_stats <- df_fmt
  is.numlog <- vclass %in% c("numeric", "logical")
  df_stats[ is.numlog ] <- df[ is.numlog ]


  ## HASH VALUES OF COLUMNS

  rg_hash <- sapply( df_fmt, rlang::hash )
  duplicates  <- get_dupes( df_fmt, rg_hash )
  names(rg_hash) <- NULL

  ## VARIABLE TYPES

  raw_first5    <- sapply( df_fmt, first_n ) %>% as.character()
  if(is.null(vconvert)){vconvert<- rep( "", N_col )}
  if(is.null(format)){vformat<- rep( "", N_col )}
  vtype         <- sapply( df_fmt, class ) %>% as.character()
  vtype_class   <- vclass
  vformat_out   <- rep( "", N_col )

  ## get_properties/stats/graphics
  ## Preview and properties use the formatted values (df_fmt); stats and
  ## graphics use df_stats, which keeps numeric/logical columns unformatted.

  rg_preview <- sapply(vname, get_examples, df = df_fmt)
  rg_properties <- mapply(get_properties, VNAME = vname, MoreArgs = list(df = df_fmt))
  rg_stats <- mapply(get_stats, VNAME = vname,VCLASS=vclass, MoreArgs = list(df = df_stats) )
  rg_graphics <- mapply(get_graphics, VNAME = vname,VCLASS=vclass, MoreArgs = list(df = df_stats) )

  ## CREATE FACTOR LABEL TABLES (JSON CELLS)

  # is.factor    <- dgf_type == "factor"
  # factor.names <- dgf_vname[ is.factor ]
  #
  # f_levels  <- rep( "", N )
  # f_levels[ is.factor ] <-
  #   sapply( df[ factor.names ], jsonify_f ) %>%
  #   as.character()
  #
  # f_order  <- rep( "", N )
  # f_order[ is.factor ] <-
  #   sapply( df[ factor.names ], get_levels ) %>%
  #   as.character()

  ## ADD BLANK RULE COLUMNS

  dgf_standardize  <- rep( "", N_col )
  dgf_validate     <- rep( "", N_col )


  ## CREATE FILE

  dgf <-
    data.frame(
      #first group - about the variable
      vname,             #variable name
      vlabel,            # variable label
      vdesc,             #variable description
      vname_alias,       #variable alias
      duplicates,        #duplicated variable?
      dd_f_level,        #levels if a factor/logical variable
      # dd_f_order,        #order to variables if applicable
      #2nd group
      raw_first5,        #first 5 raw values
      raw_type,          #raw input data type
      vconvert,          #covert data function
      vtype,             #final variable type
      vtype_class,       #final variable class (our internal purposes)
      vformat,           #final variable output stylings
      rg_properties,     #data properties
      rg_preview,        #data preview
      rg_stats,          #summary stats
      rg_graphics,       #data for graphics
      rg_hash,           #hash function
      dgf_standardize,   #standardization function
      dgf_validate       #validation functions
      )


  path = paste0(file, ".xlsx")
  write.csv( dgf, paste0(file, ".csv"), row.names=F )
  save_to_excel( dgf, filename = path )

  vt <- data.frame( VNAME=vname, TYPE=vclass )
  cat( "\nAssigned variable types:" )
  print( knitr::kable( vt ) )

  # create_rules_file()

  return(dgf)
}





# dgf <- create_dgf( bb )


