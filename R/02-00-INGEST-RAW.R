

#' Ingest a raw dataset using DGF rules (Step 2, work in progress)
#'
#' Orchestrates the Step 2 ingest workflow: sources a project `dgf.R` rules
#' file, then applies the DGF's variable-name aliases (and, once implemented,
#' type-conversion and standardization rules) to the raw data frame.
#'
#' @param df A data frame of raw data to ingest.
#' @param path Directory containing the project `dgf.R` rules file. Defaults
#'   to `NULL`, which uses the current working directory.
#'
#' @return A data frame with DGF rules applied.
#' @details This function is part of the not-yet-operational Step 2 pipeline;
#'   several steps remain stubbed out.
#' @rdname ingest_raw
#' @export
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




#' Rename raw columns to their DGF variable names
#'
#' Uses the `var_name`, `dd_vname_alias`, and `dd_vlabel` columns of a DGF to rename
#' the columns of a raw data frame from their alias (raw) names to their
#' canonical DGF names, attaching labels. Columns without an alias keep their
#' existing name.
#'
#' @param df A data frame of raw data.
#' @param dgf A DGF data frame containing `var_name`, `dd_vname_alias`, and `dd_vlabel`
#'   columns.
#'
#' @return The data frame with columns renamed and labelled per the DGF.
#' @seealso \code{\link[crosswalkr]{renamefrom}}
#' @rdname apply_name_aliases
#' @export
apply_name_aliases <- function( df, dgf ) {

  need_pkg( "crosswalkr" )

  cw <-
    dgf %>%
    dplyr::select( var_name, dd_vname_alias, dd_vlabel )

  no.alias <- is.na( cw$dd_vname_alias )
  cw$dd_vname_alias[ no.alias ] <- cw$var_name[ no.alias ]

  df <-
    crosswalkr::renamefrom(
      df,
      cw_file=cw,
      raw=dd_vname_alias,
      clean=var_name,
      label=dd_vlabel )

  return( df )

}




#' Collect and check the conversion functions named in a DGF
#'
#' Takes the unique function names listed in a DGF's `raw_convert` column and
#' verifies that each is a defined function, erroring if any are missing.
#'
#' @param raw_convert A character vector of function names (typically the
#'   `raw_convert` column of a DGF).
#'
#' @return A character vector of the unique function names.
#' @details Part of the not-yet-operational Step 2 pipeline. Note: the current
#'   existence check has known defects (missing `vapply` template, inverted
#'   condition) and is not yet wired into the tested workflow.
#' @rdname parse_functions
#' @export
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





#' Apply DGF type-conversion functions to raw columns
#'
#' For each conversion function named in a DGF's `raw_convert` column, applies
#' that function to the columns assigned to it, transforming the raw data into
#' its intended types.
#'
#' @param df A data frame of raw data.
#' @param dgf A DGF data frame with `var_name` and `raw_convert` columns.
#'
#' @return The data frame with conversion functions applied to the relevant
#'   columns.
#' @details Part of the not-yet-operational Step 2 pipeline.
#' @seealso \code{\link[dplyr]{mutate_at}}, [parse_functions()]
#' @rdname apply_raw_convert_fx
#' @export
#' @importFrom dplyr mutate_at
apply_raw_convert_fx <- function( df, dgf ) {

  fx.list <- parse_functions( dgf$raw_convert )

  for( i in fx.list )
  {
    cols <- df$var_name[ df$raw_convert == i ]
    df <-
      df %>%
      dplyr::mutate_at( cols, i )
  }

  return( df )
}




