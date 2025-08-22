

#' Ingest and preprocess a raw dataset (internal)
#'
#' Reads a raw data frame and applies variable name aliases defined in the
#' data guide file (`dgf`). Additional preprocessing steps (conversion,
#' standardization, updating factor levels) are planned but not yet enabled.
#'
#' @param df A `data.frame` containing the raw input data.
#' @param path Directory path to look for the DGF file (`dgf.R`). Defaults to
#'   the current working directory (`"."`).
#'
#' @details
#' The function attempts to source `dgf.R`, which should define the variable
#' metadata object `dgf`. At present, only name aliasing via
#' [apply_name_aliases()] is applied. Other processing steps are currently
#' commented out and may be enabled later.
#'
#' @return A `data.frame` with updated variable names.
#'
#' @keywords internal
#' @noRd
ingest_raw <- function( df, path=NULL ) {

  if( is.null(path) ){ path <- "." }
  try( source( paste0( path, "/", "dgf.R" ) ) )

  # dgf <- load excel

  df <- apply_name_aliases( df, dgf )

  # df <- apply_raw_convert_fx( df, dgf )
  # df <- apply_stdz_rules( df, dgf )

  # check for changes with vhash:
  #   update skimr
  #   update factor levels

  # save new version
}




#' Apply variable name aliases (internal)
#'
#' Renames variables in a raw dataset according to alias and label mappings
#' defined in the data guide file (`dgf`).
#'
#' @param df A `data.frame` containing the raw input data.
#' @param dgf A `data.frame` (from the data guide file) containing at least the
#'   columns:
#'   \describe{
#'     \item{vname}{The standardized (clean) variable name.}
#'     \item{vname_alias}{The raw or alternate variable name.}
#'     \item{vlabel}{A descriptive label for the variable.}
#'   }
#'
#' @details
#' The function builds a crosswalk of variable names and uses
#' [crosswalkr::renamefrom()] to rename columns in \code{df}.
#' Missing aliases (\code{NA}) are replaced with the standardized name so that
#' all variables are mapped.
#'
#' @return A `data.frame` with standardized variable names and attached labels.
#'
#' @seealso [crosswalkr::renamefrom()]
#'
#' @keywords internal
#' @noRd
#' @importFrom crosswalkr renamefrom
apply_name_aliases <- function( df, dgf ) {

  cw <-
    dgf %>%
    select( vname, vname_alias, vlabel )

  no.alias <- is.na( cw$vname_alias )
  cw$vname_alias[ no.alias ] <- cw$vname[ no.alias ]

  df <-
    crosswalkr::renamefrom(
      df,
      cw_file=cw,
      raw=vname_alias,
      clean=vname,
      label=vlabel )

  return( df )

}




#' Parse and validate conversion functions (internal)
#'
#' Extracts the set of unique conversion function names from a vector and checks
#' whether they exist in the current R environment.
#'
#' @param raw_convert A character vector of function names to be used for raw
#'   data conversion.
#'
#' @details
#' The function collects the unique values of \code{raw_convert} and verifies
#' that each corresponds to a defined function. If any are missing, an error is
#' thrown listing the missing functions.
#'
#' @return A character vector of unique function names.
#'
#' @keywords internal
#' @noRd
parse_functions <- function( raw_convert ){

  fx.list <- unique( raw_convert )
  f.exists <- vapply( fx.list, exists )
  if( any( f.exists ) )
  {
    f.missing <- fx.list[ ! f.exists ]
    stop(
      paste0(
        "raw_convert functions are not defined: ",
        paste( f.exists, collapse="; " )
     ) )
  }

  return( fx.list )
}





#' Apply raw data conversion functions (internal)
#'
#' Applies user-defined conversion functions to selected variables in a dataset
#' based on specifications in the data guide file (`dgf`).
#'
#' @param df A `data.frame` containing the raw input data.
#' @param dgf A `data.frame` containing at least the columns:
#'   \describe{
#'     \item{vname}{The standardized variable name in the dataset.}
#'     \item{raw_convert}{The name of a function to apply to this variable.}
#'   }
#'
#' @details
#' The function:
#' \enumerate{
#'   \item Parses and validates all function names listed in
#'         \code{dgf$raw_convert} via [parse_functions()].
#'   \item Iterates over each unique function and applies it to the variables
#'         assigned that function in the DGF.
#'   \item Updates \code{df} in place using \code{dplyr::mutate_at()}.
#' }
#'
#' @return A `data.frame` with the specified conversions applied.
#'
#' @seealso [parse_functions()]
#'
#' @keywords internal
#' @noRd
apply_raw_convert_fx <- function( df, dgf ) {

  fx.list <- parse_functions( dgf$raw_convert )

  for( i in fx.list )
  {
    cols <- df$vname[ df$raw_convert == i ]
    df <-
      df %>%
      dplyr::mutate_at( cols, i )
  }

  return( df )
}




