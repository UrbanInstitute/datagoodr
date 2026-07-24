##############################
### Rule guards: do the DGF's rules still fit the data?
###############################
## The as_* rules in raw_to_stable_transform / desired_data_import_rule are
## guarded by their is_* detectors: a rule only applies cleanly if the data
## looks like what it expects. check_dgf_rules() makes that explicit -- it
## applies each rule to the current data and reports how many present values it
## fails to parse. Use it after editing rules or refining the data (this is what
## makes update_dgf()/refresh_dgf() a reconciliation, not a blind rebuild).


#' Check that a DGF's rules still fit the data
#'
#' For every variable carrying a `raw_to_stable_transform` or
#' `desired_data_import_rule`, applies the rule to the matching column of `data`
#' and measures the share of *present* values it turns into `NA` --- the same
#' signal the rule's `is_*` guard would give. A high miss rate means the rule no
#' longer matches the data (e.g. you cleaned a date column, so the old
#' `as_mmddyyyy` no longer applies).
#'
#' @param dgf A DGF data frame, or a path to a DGF `.xlsx`.
#' @param data The data to test against: a data frame, or a path to a `.csv`.
#' @param threshold Miss rate above which a rule is flagged as not fitting.
#'   Defaults to `0.2`.
#'
#' @return A data frame with one row per (variable, rule): `var_name`, `stage`
#'   (`"reformat"` or `"import"`), `rule`, `miss_rate`, and `fits` (logical).
#'   Empty when the DGF has no rules. Rows with `fits == FALSE` are the ones to
#'   review.
#'
#' @examples
#' \dontrun{
#' bad <- subset(check_dgf_rules(dgf, raw_data), !fits)
#' }
#' @seealso [stabilize_data()], [update_dgf()]
#' @export
check_dgf_rules <- function( dgf, data, threshold = 0.2 ) {
  if( is.character(dgf) && length(dgf) == 1 ) dgf <- load_dgf( dgf )
  if( is.character(data) && length(data) == 1 )
    data <- utils::read.csv( data, stringsAsFactors = FALSE, check.names = FALSE )
  stopifnot( is.data.frame(dgf), is.data.frame(data), "var_name" %in% names(dgf) )

  stages <- c( raw_to_stable_transform = "reformat",
               desired_data_import_rule = "import" )
  empty <- data.frame( var_name = character(), stage = character(),
                       rule = character(), miss_rate = numeric(),
                       fits = logical(), stringsAsFactors = FALSE )
  rows <- list()

  for( sc in names(stages) ) {
    if( ! sc %in% names(dgf) ) next
    for( i in seq_len( nrow(dgf) ) ) {
      rule <- dgf[[sc]][i]
      v    <- dgf$var_name[i]
      if( is.null(rule) || is.na(rule) || ! nzchar( trimws(rule) ) ) next
      if( ! v %in% names(data) ) next
      fn  <- trimws( rule )
      col <- as.character( data[[v]] )
      present <- !is.na(col) & nzchar( trimws(col) )

      if( ! exists( fn, mode = "function" ) ) {
        miss <- NA_real_
      } else {
        f   <- get( fn, mode = "function" )
        out <- try( vapply( col, function(x) as.character( f(x) ),
                            character(1), USE.NAMES = FALSE ), silent = TRUE )
        miss <- if( inherits(out, "try-error") ) 1
                else if( any(present) ) mean( is.na( out[present] ) )
                else 0
      }
      rows[[length(rows) + 1L]] <- data.frame(
        var_name = v, stage = unname(stages[[sc]]), rule = fn,
        miss_rate = round(miss, 3),
        fits = isTRUE( !is.na(miss) && miss <= threshold ),
        stringsAsFactors = FALSE )
    }
  }
  if( ! length(rows) ) return( empty )
  do.call( rbind, rows )
}
