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
#' @param var_name,dd_vlabel,dd_vdesc,stable_data_storage Optional character vectors of per-variable
#'   metadata (name, short label, long description, type), each the same length
#'   and order as the columns of `df`. Default to blank.
#' @param raw_data_import_rule Optional character vector of type-conversion function names
#'   (e.g. `"as_yyyy"`), one per column, applied to the data before profiling.
#' @param stable_data_format Optional character vector of display-formatting function names
#'   (e.g. `"dollarize"`), one per column, applied to previews and graphics.
#' @param dd_vname_alias Optional character vector of per-variable alternate
#'   names. Defaults to blank.
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
         var_name=NULL,
         dd_vlabel=NULL,
         dd_vdesc=NULL,
         stable_data_storage=NULL,
         raw_data_import_rule = NULL,
         stable_data_format = NULL,
         dd_vname_alias = NULL,
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

  var_name        <- names(df)
  dd_vlabel       <- names(df)
  if(is.null(dd_vdesc)){dd_vdesc <- rep("", N_col)}
  if(is.null(dd_vname_alias)){dd_vname_alias<-rep("", N_col)}
  # class(x)[1]: a column can be multi-class (an ordered factor, or a POSIXct
  # datetime readr guessed). Taking the primary class keeps these as clean
  # length-1 storage names and stops sapply() from collapsing to a list.
  primary_class <- function( d ) vapply( d, function(x) class(x)[1], character(1) )

  raw_data_storage      <- primary_class( df )


  ## TRY TO GUESS FACTORS
  if( guess.factors )
  { df <- recast_factors( df ) }
  guess_type <- primary_class( df )

  correct.guess <- substr(raw_data_import_rule, 4,nchar(raw_data_import_rule)) == guess_type

  ## Set up data classes
  if(!is.null(raw_data_import_rule)){
    df_converted <- sapply(seq_along(raw_data_import_rule), function(i) {
      if (is.na(raw_data_import_rule[i]) | correct.guess[i]) {
        return(dplyr::pull(df[, i], 1))  # Keep the original column if raw_data_import_rule[i] is NA
      } else {
        func_name <- raw_data_import_rule[i]
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
    names(df ) <- var_name
  }
  data_type_converted <- primary_class( df )



  dd_f_levels <- mapply(function(var_name, type, df){
    # any(): a column can carry a multi-class class() - an ordered factor is
    # c("ordered","factor"), and readr's type guess can hand back a POSIXct
    # datetime as c("POSIXct","POSIXt"). A scalar `type %in% ...` errors on
    # those ("condition has length > 1").
    if(any(type %in% c("factor", "logical"))){
      # Store a two-column dictionary: the level code and an editable label.
      # The label is seeded to the code so users can add human-readable
      # descriptions (e.g. "AR" -> "Arts") in Excel during Step 2.
      # Use [[ ]] so a single column is returned as a vector even when df is a
      # tibble (df[, var_name] on a tibble returns a 1-column tibble, whose
      # levels() is NULL).
      lv <- levels(df[[var_name]])
      tab <- data.frame(level = lv, label = lv)
      tab <- jsonify_df(tab)
      return(tab)
      }else{
        return("")
      }
    },
    var_name = var_name,type=data_type_converted, MoreArgs = list(df = df) )


  ## Need to guess factor it is logical, to make class
  vclass <- data_type_converted
  # The build-time stat/graphic dispatch keys on "numeric"; collapse the R
  # storage variants (integer, double) onto it so an all-integer column (a
  # count, a year) is profiled as a number, not sent down the character path.
  vclass[ vclass %in% c("integer", "double") ] <- "numeric"
  is.logical <- 2 == sapply(var_name[vclass == "factor"], function(x){length(table(df[,x]))})
  vclass[names(is.logical[is.logical])] <- "logical"

  ## Temporal + identifier detection - override the guessed class. Both are
  ## rough first passes the user corrects in the DGF before rendering (Step 2):
  ## R's date guessing is limited and id recognition is heuristic. Temporal is
  ## checked first, so a date column (which would otherwise look like a unique
  ## code) is not mistaken for an identifier.
  is.temporal <- as.logical( sapply( df, detect_temporal ) )
  is.id       <- mapply( detect_identifier, df, var_name ) & ! is.temporal
  vclass[ is.temporal ] <- "temporal"
  vclass[ is.id ]       <- "identifier"

  # Default unit for a detected temporal: a time-of-day class gets "hour", a
  # date/datetime gets "date" (the calendar heatmap). The user retypes the unit
  # (year/month/dow/week) in the DGF and re-renders - the graphic is chosen at
  # render, so no rebuild is needed.
  stable_data_unit <- rep( "", N_col )
  is.time <- vapply( df, function(x) inherits(x, c("hms","difftime","times")),
                     logical(1) )
  stable_data_unit[ is.temporal ] <- "date"
  stable_data_unit[ is.temporal & is.time ] <- "hour"

  # Print types of classes
  vt <- table( vclass )
  cat( "Data type summary:\n" )
  print( knitr::kable( vt ) )

  ## Do the format
  #
  # stable_data_format applies a *display* transformation to each column (e.g. zero-pad
  # EINs, style dates). It only shapes how values are previewed, so the
  # formatted frame (df_fmt) is kept separate from the underlying converted
  # data (df). Statistics and graphics for numeric/logical variables must be
  # computed on the real values, not their formatted strings (df_stats below).

  if(!is.null(stable_data_format)){
    df_converted <- sapply(seq_along(stable_data_format), function(i) {
      if (is.na(stable_data_format[i])) {
        return(c(df[, i]))  # Keep the original column if stable_data_format[i] is NA
      } else {
        func_name <- stable_data_format[i]
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
    names(df_fmt) <- var_name
  }else{
    stable_data_format <- rep("", N_col)
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

  prov_current_hash <- sapply( df_fmt, rlang::hash )
  raw_duplicated  <- get_dupes( df_fmt, prov_current_hash )
  names(prov_current_hash) <- NULL

  ## VARIABLE TYPES

  raw_first5    <- sapply( df_fmt, first_n ) %>% as.character()
  if(is.null(raw_data_import_rule)){raw_data_import_rule<- rep( "", N_col )}
  if(is.null(format)){stable_data_format<- rep( "", N_col )}
  stable_data_storage <- sapply( df_fmt, class ) %>% as.character()

  # Ontology data_type is what the render engine dispatches on. dg_type_of()
  # maps the R storage class onto it: raw_ from the class as read, stable_ from
  # the class after any type conversion. vclass (numeric/factor/logical/
  # character) is the internal build-time guess; stable_data_type is its
  # ontology name (number/categorical/boolean/string), so a variable that
  # guessed "factor" carries stable_data_type "categorical".
  raw_data_type    <- dg_type_of( raw_data_storage )
  stable_data_type <- dg_type_of( vclass )

  ## FIELD LENGTH (max character width of the underlying values)
  rg_max_chr <- sapply( df_stats, function(x){
    x <- x[ ! is.na(x) ]
    if( length(x) == 0 ) return( 0L )
    max( nchar( as.character(x) ) )
  })
  names(rg_max_chr) <- NULL

  ## get_properties/stats/graphics
  ## Preview and properties use the formatted values (df_fmt); stats and
  ## graphics use df_stats, which keeps numeric/logical columns unformatted.

  rg_preview <- sapply(var_name, get_examples, df = df_fmt)
  rg_properties <- mapply(get_properties, VNAME = var_name, MoreArgs = list(df = df_fmt))
  rg_stats <- mapply(get_stats, VNAME = var_name,VCLASS=vclass, MoreArgs = list(df = df_stats) )
  rg_graphics <- mapply(get_graphics, VNAME = var_name,VCLASS=vclass, MoreArgs = list(df = df_stats) )

  ## BLANK COLUMNS
  # Declared now, populated by later work (subtype/class/unit descriptors, the
  # standardization pipeline, validation, lineage chaining). See dev/TO-DO.md.
  blank <- rep( "", N_col )
  stable_data_transform <- blank
  validate_rules        <- blank


  ## CREATE FILE
  # Assembled in dgf_schema_cols() order (R/01-01-dgf-schema.R). The render
  # engine reads columns by name, so order is for the human reading the .xlsx.

  dgf <-
    data.frame(
      # variable key
      var_name,

      # dd_: data dictionary
      dd_vname_alias, dd_vlabel, dd_vdesc, dd_f_levels,

      # raw_: import contract (as received)
      raw_data_storage,
      raw_data_type,
      raw_data_subtype = blank,
      raw_data_class   = blank,
      raw_data_unit    = blank,
      raw_data_format  = blank,
      raw_data_import_rule,
      raw_first5,
      raw_duplicated,

      # stable_: standardized contract
      stable_data_storage,
      stable_data_type,
      stable_data_subtype   = blank,
      stable_data_class     = blank,
      stable_data_unit,
      stable_data_format,
      stable_data_transform,
      stable_data_import_rule = blank,

      # rg_: research guide artifacts (JSON strings)
      rg_properties, rg_preview, rg_stats, rg_graphics, rg_max_chr,

      # validate_: validation rules
      validate_rules,
      validate_format = blank,

      # prov_: provenance hashes
      prov_start_hash = blank,
      prov_current_hash,

      stringsAsFactors = FALSE
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

  vt <- data.frame( VNAME=var_name, TYPE=vclass )
  cat( "\nAssigned variable types:" )
  print( knitr::kable( vt ) )


  return(dgf)
}







