#' @title create DGF file
#'
#' @description
#' Builds a Data Governance File (DGF) from a dataset: one row per variable,
#' carrying the metadata, summary statistics, and graphics data needed to
#' render a Research Guide. Writes a `.csv` and an `.xlsx`, and returns the DGF
#' data frame.
#'
#' @details
#' Column types are inferred from the data (see `vtypes` / `use.df.types` /
#' `guess.factors` to steer that), then each variable is profiled into the
#' `rg_*` columns. The result is meant to be curated by hand - in Excel or via
#' the `v*` arguments - and fed to [create_rg()].
#'
#' @param df A data frame to document, or a path to a `.csv` file to read.
#' @param use.df.types Logical; keep the data frame's existing column types
#'   instead of re-reading the data with `readr` to re-infer them. Defaults to
#'   `FALSE`.
#' @param guess.factors Logical; treat low-cardinality columns as factors.
#'   Defaults to `TRUE`.
#' @param vname,vlabel,vdesc,vtype Optional character vectors of per-variable
#'   metadata (name, short label, long description, type), each the same length
#'   and order as the columns of `df`. Default to blank.
#' @param vconvert Optional character vector of type-conversion function names
#'   (e.g. `"as_yyyy"`), one per column, applied to the data before profiling.
#' @param vformat Optional character vector of display-formatting function names
#'   (e.g. `"dollarize"`), one per column, applied to previews and graphics.
#' @param vname_alias,vscope,vloc Optional character vectors of per-variable
#'   alias, scope, and location-code metadata. Default to blank.
#' @param dir Directory to write the DGF into. Created if it does not exist.
#'   Defaults to `"."`. Ignored when `file` is an absolute path.
#' @param file Output path stem (without extension) for the written `.csv` and
#'   `.xlsx`. Defaults to `"DGF"`. Resolved relative to `dir` unless absolute.
#' @param open Logical; open the new DGF in Excel once created. Defaults to
#'   [interactive()] — on at the console, off in scripts, tests, and CI.
#' @param vtypes,guess.dates,dd,keep.dd.cols,preview_dd,preview_dp Accepted but
#'   currently ignored; the features they were intended to steer (explicit type
#'   overrides, date/time detection, and data-dictionary merging) are not
#'   implemented yet. See `dev/TO-DO.md`.
#'
#' @return The DGF as a data frame, one row per variable. Also writes
#'   `<file>.csv` and `<file>.xlsx` as a side effect.
#'
#' @seealso [create_rg()], [update_dgf()], [inspect_dgf()]
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
         vscope = NULL,
         vloc = NULL,
         keep.dd.cols=NULL,
         preview_dd=F,
         preview_dp= F,
         dir=".",
         file="DGF",
         open = interactive())

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
  if(is.null(vscope)){vscope <- rep("", N_col)}
  if(is.null(vloc)){vloc <- rep("", N_col)}
  raw_type      <- sapply( df, class ) %>% as.character()


  ## TRY TO GUESS FACTORS
  if( guess.factors )
  { df <- recast_factors( df ) }
  guess_type <- sapply( df, class ) %>% as.character()

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



  dd_f_level <- mapply(function(vname, type, df){
    if(type %in% c("factor", "logical")){
      # Store a two-column dictionary: the level code and an editable label.
      # The label is seeded to the code so users can add human-readable
      # descriptions (e.g. "AR" -> "Arts") in Excel during Step 2.
      # Use [[ ]] so a single column is returned as a vector even when df is a
      # tibble (df[, vname] on a tibble returns a 1-column tibble, whose
      # levels() is NULL).
      lv <- levels(df[[vname]])
      tab <- data.frame(level = lv, label = lv)
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

  ## FIELD LENGTH (max character width of the underlying values)
  vlength <- sapply( df_stats, function(x){
    x <- x[ ! is.na(x) ]
    if( length(x) == 0 ) return( 0L )
    max( nchar( as.character(x) ) )
  })
  names(vlength) <- NULL

  ## get_properties/stats/graphics
  ## Preview and properties use the formatted values (df_fmt); stats and
  ## graphics use df_stats, which keeps numeric/logical columns unformatted.

  rg_preview <- sapply(vname, get_examples, df = df_fmt)
  rg_properties <- mapply(get_properties, VNAME = vname, MoreArgs = list(df = df_fmt))
  rg_stats <- mapply(get_stats, VNAME = vname,VCLASS=vclass, MoreArgs = list(df = df_stats) )
  rg_graphics <- mapply(get_graphics, VNAME = vname,VCLASS=vclass, MoreArgs = list(df = df_stats) )

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
      vscope,            #variable scope (user-supplied metadata)
      vloc,              #location code (user-supplied metadata)
      duplicates,        #duplicated variable?
      dd_f_level,        #levels/labels if a factor/logical variable
      # dd_f_order,        #order to variables if applicable
      #2nd group
      raw_first5,        #first 5 raw values
      raw_type,          #raw input data type
      vconvert,          #covert data function
      vtype,             #final variable type
      vtype_class,       #final variable class (our internal purposes)
      vlength,           #field length (max character width)
      vformat,           #final variable output stylings
      rg_properties,     #data properties
      rg_preview,        #data preview
      rg_stats,          #summary stats
      rg_graphics,       #data for graphics
      rg_hash,           #hash function
      dgf_standardize,   #standardization function
      dgf_validate       #validation functions
      )


  # `file` is a path stem (no extension); a .csv and an .xlsx are written from
  # it. An absolute stem (e.g. tempfile()) is used as-is, so `dir` only anchors
  # relative stems. dirname() also covers a subdirectory carried in the stem.
  stem <- if( is_absolute_path(file) ) file else file.path( dir, file )
  out.dir <- dirname( stem )
  if( ! dir.exists( out.dir ) ) dir.create( out.dir, recursive = TRUE )

  path = paste0(stem, ".xlsx")
  write.csv( dgf, paste0(stem, ".csv"), row.names=F )
  save_to_excel( dgf, filename = path, open = open )

  vt <- data.frame( VNAME=vname, TYPE=vclass )
  cat( "\nAssigned variable types:" )
  print( knitr::kable( vt ) )


  return(dgf)
}







