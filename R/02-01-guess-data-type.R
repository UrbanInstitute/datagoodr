##############################
### Guess data type (detection workflow)
###############################
## Runtime orchestration that turns the atomized detectors (R/dt-<family>.R,
## registered in R/00-data-type-registry.R) into a best-guess, ONTOLOGY-anchored
## data-type prediction for a column. Keeps the detectors as pure predicates;
## all scoring/ranking/mapping lives here (the public seam of the module).
##
## Design (see conversation): on a large dataset this is meant to stay cheap ---
##   1. DEDUPE + SAMPLE: score at most `n_sample` unique values, not every cell.
##   2. FAST TIER first: run the fast detectors (all current ones). Only if none
##      clears `threshold` fall through to the slow tier (fuzzy matchers, none
##      yet) --- the `.slow_detectors` set makes this a no-op today.
##   3. RANK candidates by pass rate, breaking ties with a variable-NAME hint
##      and a specificity flag (loose detectors lose ties).
##   4. MAP the winner to ontology coordinates via data_type_ontology().


#' Score a column against every registered detector
#'
#' @param values A character vector (already sampled/deduped/cleaned).
#' @param detectors A named list of detector functions; defaults to the registry.
#' @return A data frame with `data_type`, `n`, `pass_rate`, ordered by descending
#'   `pass_rate`.
#' @export
score_data_type <- function(values, detectors = data_type_detectors()) {
  values <- as.character(values)
  values <- values[!is.na(values) & nzchar(trimws(values))]
  n <- length(values)
  rates <- vapply(detectors, function(f) {
    if (n == 0) return(NA_real_)
    mean(f(values), na.rm = TRUE)
  }, numeric(1))
  out <- data.frame(data_type = names(detectors), n = n,
                    pass_rate = unname(rates), stringsAsFactors = FALSE)
  out[order(-out$pass_rate), , drop = FALSE]
}

## variable-name keywords for a type (for the name hint)
#' @keywords internal
#' @noRd
.name_keywords <- function(nm) {
  onto <- data_type_ontology(nm)
  kw <- unique(c(strsplit(nm, "_")[[1]], onto[["data_class"]], onto[["data_type"]]))
  kw <- tolower(kw[!is.na(kw)])
  kw[nchar(kw) >= 3]
}

## does the variable name hint at this type?
#' @keywords internal
#' @noRd
.name_hits <- function(nm, varname) {
  if (is.null(varname) || is.na(varname) || !nzchar(varname)) return(FALSE)
  v <- tolower(varname)
  any(vapply(.name_keywords(nm), function(k) grepl(k, v, fixed = TRUE), logical(1)))
}

#' Guess the ontology-anchored data type of a column
#'
#' Reads up to `n_sample` unique values, scores them against every registered
#' detector, and returns the best-matching type (when its pass rate clears
#' `threshold`) together with its ontology coordinates. Ties in pass rate are
#' broken first by a variable-name hint, then by specificity.
#'
#' @param x A vector (coerced to character) of column values.
#' @param name Optional variable name; used only to break ties (e.g. a column
#'   named `fips` favors a FIPS detector over a same-shape ZIP detector).
#' @param n_sample Maximum number of unique non-missing values to test.
#' @param threshold Minimum pass rate for the top type to be reported as the
#'   guess; below it, `guess` is `NA` (unknown).
#' @param floor Minimum pass rate for a type to appear in `candidates`.
#' @param detectors A named list of detector functions; defaults to the registry.
#' @param seed Optional integer seed for reproducible sampling.
#'
#' @return A list with:
#'   \describe{
#'     \item{guess}{Best-matching detector type name, or `NA`.}
#'     \item{ontology}{Named vector `c(data_type, data_subtype, data_class,
#'       data_format)` for the guess (all `NA` if none).}
#'     \item{confidence}{The guess's pass rate.}
#'     \item{candidates}{Ranked data frame of types clearing `floor`, with
#'       `pass_rate`, `name_match`, and `specific` columns.}
#'     \item{n}{Number of unique values scored.}
#'   }
#'
#' @examples
#' guess_data_type(c("USD", "EUR", "JPY", "GBP"))$ontology
#' guess_data_type(c("06037", "36061"), name = "county_fips")$guess
#'
#' @seealso [score_data_type()], [data_type_ontology()]
#' @export
guess_data_type <- function(x, name = NULL, n_sample = 100, threshold = 0.8,
                            floor = 0.5, detectors = data_type_detectors(),
                            seed = NULL) {
  x <- as.character(x)
  x <- x[!is.na(x) & nzchar(trimws(x))]
  u <- unique(x)
  if (length(u) > n_sample) {
    if (!is.null(seed)) set.seed(seed)
    u <- sample(u, n_sample)
  }

  ## --- fast tier, then fall through to slow only if nothing is confident ----
  is_slow <- names(detectors) %in% .slow_detectors
  scores <- score_data_type(u, detectors[!is_slow])
  if ((nrow(scores) == 0 || max(scores$pass_rate, na.rm = TRUE) < threshold) &&
      any(is_slow)) {
    scores <- rbind(scores, score_data_type(u, detectors[is_slow]))
    scores <- scores[order(-scores$pass_rate), , drop = FALSE]
  }

  ## --- annotate with tie-breakers, filter to candidates, rank ---------------
  scores$name_match <- vapply(scores$data_type, .name_hits, logical(1),
                              varname = name)
  scores$specific   <- !(scores$data_type %in% .loose_detectors)
  cand <- scores[!is.na(scores$pass_rate) & scores$pass_rate >= floor, ,
                 drop = FALSE]
  cand <- cand[order(-round(cand$pass_rate, 3), -cand$name_match,
                     -cand$specific), , drop = FALSE]
  rownames(cand) <- NULL

  top <- if (nrow(cand)) cand[1, ] else NULL
  guess <- if (!is.null(top) && top$pass_rate >= threshold) top$data_type else NA_character_

  list(
    guess = guess,
    ontology = if (is.na(guess)) data_type_ontology(NA) else data_type_ontology(guess),
    confidence = if (is.null(top)) NA_real_ else top$pass_rate,
    candidates = cand,
    n = length(u)
  )
}
