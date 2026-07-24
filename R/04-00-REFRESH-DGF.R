# Step 4: refresh a DGF when the underlying data changes.
#
# The prov_current_hash column stores a hash of each variable's (converted + formatted)
# values. update_dgf() rebuilds the DGF from the new data, then uses the hash
# to decide, per variable, whether anything actually changed:
#   - unchanged variables keep their existing (curated) DGF row verbatim, so
#     any manual edits survive;
#   - changed variables get refreshed data summaries, while their curated
#     factor level labels are carried over for levels that still exist;
#   - variables added to / removed from the data are reported.


#' Merge curated factor labels from an old level dictionary into a new one
#'
#' For a changed factor/logical variable, keep the user-edited labels from the
#' old `dd_f_levels` for any level codes that still exist in the refreshed
#' dictionary.
#'
#' @param old_json,new_json JSON strings from the `dd_f_levels` column.
#' @return A JSON string: the new dictionary with old labels merged in.
#' @keywords internal
#' @noRd
merge_level_labels <- function( old_json, new_json ) {

  if( is.na(new_json) || trimws(new_json) == "" ) return( new_json )
  new.tab <- tryCatch( json_to_df(new_json), error = function(e) NULL )
  if( is.null(new.tab) || nrow(new.tab) == 0 ||
      ! all( c("level","label") %in% names(new.tab) ) )
  { return( new_json ) }

  if( ! is.na(old_json) && trimws(old_json) != "" ) {
    old.tab <- tryCatch( json_to_df(old_json), error = function(e) NULL )
    if( ! is.null(old.tab) && all( c("level","label") %in% names(old.tab) ) ) {
      m   <- match( new.tab$level, old.tab$level )
      has <- ! is.na(m)
      new.tab$label[has] <- old.tab$label[ m[has] ]
    }
  }

  jsonify_df( new.tab )
}


#' Refresh a DGF against updated data (Step 4)
#'
#' Compares an existing DGF to a new version of the dataset and produces an
#' updated DGF. Each variable's `prov_current_hash` is used to detect change: variables
#' whose data is unchanged keep their existing (curated) DGF row, while changed
#' or newly added variables have their data summaries recomputed. Curated
#' fields (descriptions, aliases, scope, location, conversion/format rules) are
#' preserved, and hand-edited factor level labels are carried over for levels
#' that still exist.
#'
#' @param dgf An existing DGF: a data frame, or a path to a DGF `.xlsx` file.
#' @param df The updated dataset: a data frame, or a path to a `.csv` file.
#' @param file Output path stem (without extension) for the written `.csv` and
#'   `.xlsx`. Defaults to `"DGF"`.
#' @param verbose Logical; if `TRUE` (default) a summary of what changed is
#'   printed.
#' @param open Logical; open the refreshed DGF in Excel once written. Defaults
#'   to [interactive()] — on at the console, off in scripts, tests, and CI.
#'
#' @return Invisibly, the updated DGF data frame. It carries a `"status"`
#'   attribute: a named character vector labelling each variable as
#'   `"unchanged"`, `"changed"`, or `"added"`; a `"removed"` attribute listing
#'   variables no longer present in the data; and a `"stale_rules"` attribute
#'   (from [check_dgf_rules()]) listing curated `as_*` rules that no longer fit
#'   the new data.
#' @seealso [create_dgf()], [inspect_dgf()], [check_dgf_rules()]
#' @export
update_dgf <- function( dgf, df, file = "DGF", verbose = TRUE,
                        open = interactive() ) {

  if( is.character(dgf) && length(dgf) == 1 ) dgf <- load_dgf( dgf )
  if( is.character(df)  && length(df)  == 1 )
  { df <- suppressMessages( readr::read_csv( df ) ) }

  new.names <- names(df)
  idx <- match( new.names, dgf$var_name )       # old row for each new column

  # Align curated fields from the old DGF to the new columns (blank / NA where
  # the column is new).
  pick_chr <- function( col ) {
    v <- as.character( dgf[[col]][idx] )
    v[ is.na(v) ] <- ""
    v
  }
  pick_fx <- function( col ) {               # create_dgf expects NA for "none"
    v <- as.character( dgf[[col]][idx] )
    v[ is.na(v) | trimws(v) == "" ] <- NA
    v
  }

  # Rebuild the DGF from the new data, preserving curation. create_dgf is noisy;
  # capture its console output.
  utils::capture.output( suppressMessages( suppressWarnings(
    dgf.new <- create_dgf(
      df,
      dd_vdesc       = pick_chr("dd_vdesc"),
      dd_vname_alias = pick_chr("dd_vname_alias"),
      desired_data_import_rule    = pick_fx("desired_data_import_rule"),
      stable_data_format     = pick_fx("stable_data_format"),
      file        = tempfile("dgf-refresh"),
      open        = FALSE )
  ) ) )

  # Classify each variable by comparing hashes.
  old.hash <- dgf$prov_current_hash[idx]
  status <- ifelse( is.na(idx), "added",
              ifelse( dgf.new$prov_current_hash == old.hash, "unchanged", "changed" ) )
  names(status) <- new.names

  shared.cols <- intersect( names(dgf.new), names(dgf) )

  for( i in seq_along(new.names) ) {
    if( status[i] == "unchanged" ) {
      # keep the old (curated) row verbatim
      dgf.new[ i, shared.cols ] <- dgf[ idx[i], shared.cols ]
    } else if( status[i] == "changed" &&
               dgf.new$desired_data_type[i] %in% c("categorical","boolean") ) {
      # refreshed data, but keep curated level labels where levels persist
      dgf.new$dd_f_levels[i] <-
        merge_level_labels( dgf$dd_f_levels[ idx[i] ], dgf.new$dd_f_levels[i] )
    }
  }

  removed <- setdiff( dgf$var_name, new.names )

  if( verbose ) {
    n <- function(s) sum( status == s )
    say <- function(lbl, vars) if( length(vars) )
      cat( "  ", lbl, ": ", paste(vars, collapse=", "), "\n", sep="" )
    cat( "\nRefreshing DGF against new data (", length(new.names),
         " variables )\n",
         "----------------------------------------\n", sep = "" )
    cat( "  unchanged: ", n("unchanged"), "\n", sep="" )
    say( "changed", new.names[ status == "changed" ] )
    say( "added",   new.names[ status == "added" ] )
    say( "removed", removed )
    cat( "----------------------------------------\n\n" )
  }

  # Re-check the rule guards against the new data. A curated as_* rule may no
  # longer fit after the data was cleaned or replaced (e.g. dates that were
  # mm/dd/yyyy are now ISO), so reconciliation means flagging stale rules, not
  # just recomputing summaries. See check_dgf_rules().
  rule_check <- tryCatch( check_dgf_rules( dgf, df ), error = function(e) NULL )
  stale <- if( is.null(rule_check) || ! nrow(rule_check) ) rule_check
           else rule_check[ ! rule_check$fits, , drop = FALSE ]
  if( verbose && ! is.null(stale) && nrow(stale) ) {
    cat( "  stale rules (no longer fit the data):\n" )
    for( k in seq_len( nrow(stale) ) )
      cat( "    ", stale$var_name[k], " [", stale$stage[k], "] ",
           stale$rule[k], " -> ", round( 100 * stale$miss_rate[k] ), "% miss\n",
           sep = "" )
    cat( "----------------------------------------\n\n" )
  }

  # write output
  write.csv( dgf.new, paste0(file, ".csv"), row.names = FALSE )
  save_to_excel( dgf.new, filename = paste0(file, ".xlsx"), open = open )

  attr( dgf.new, "status" )      <- status
  attr( dgf.new, "removed" )     <- removed
  attr( dgf.new, "stale_rules" ) <- stale
  return( invisible( dgf.new ) )
}
