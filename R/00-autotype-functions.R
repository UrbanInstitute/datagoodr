##############################
### AutoType functions
###############################
## Reimplementation of AutoType's (Yan & He, SIGMOD'18) hierarchical
## negative-example generation: Definition 5 (inferred alphabet) and the
## S1 (preserve-structure) / S2 (preserve-alphabet) / S3 (random) mutation
## strategies from Section 6, plus an SP (structure-scramble) strategy.
##
## These functions turn a small set of positive examples into a labelled mix
## of valid values and plausible-but-wrong "negatives", so a detector can be
## stress-tested for both recall (accepts real positives) and precision
## (rejects near-misses). They are dev / test tooling: the shipped
## `data_type_tests` object and the `data-types/` reports are both produced by
## running data-raw/build_test_cases.R over these functions.
##
## Reference: Auto-Type: Synthesizing Type-Detection Logic for Rich Semantic
## Data Types using Open-source Code. Cong Yan and Yeye He. SIGMOD 2018.
## https://dl.acm.org/doi/10.1145/3183713.3196888


## ---- alphabet inference (Definition 5) ------------------------------------

#' Infer the alphabet of a set of positive examples
#' @param P A character vector of positive examples.
#' @return A list with elements `full`, `nonpunct`, and `punct`.
#' @keywords internal
#' @noRd
infer_alphabet <- function(P) {
  chars <- unique(unlist(strsplit(paste(P, collapse = ""), "")))
  is_alnum <- grepl("^[A-Za-z0-9]$", chars)
  list(
    full     = chars,
    nonpunct = chars[is_alnum],
    punct    = chars[!is_alnum]
  )
}

## ---- the mutation strategies (Section 6) ----------------------------------

#' @keywords internal
#' @noRd
.mutate_string <- function(s, p, replace_pool, eligible_fn) {
  chars <- strsplit(s, "")[[1]]
  eligible <- eligible_fn(chars)
  do_mutate <- eligible & (runif(length(chars)) < p)
  if (any(do_mutate) && length(replace_pool) > 0) {
    chars[do_mutate] <- sample(replace_pool, sum(do_mutate), replace = TRUE)
  }
  paste(chars, collapse = "")
}

#' S1: mutate, preserving structure (replace alphanumerics only)
#' @keywords internal
#' @noRd
mutate_S1 <- function(s, alphabet, p = 0.5) {
  is_alnum <- function(chars) grepl("^[A-Za-z0-9]$", chars)
  .mutate_string(s, p, alphabet$nonpunct, is_alnum)
}

#' S2: mutate, preserving alphabet (replace any in-alphabet char)
#' @keywords internal
#' @noRd
mutate_S2 <- function(s, alphabet, p = 0.5) {
  always_eligible <- function(chars) rep(TRUE, length(chars))
  .mutate_string(s, p, alphabet$full, always_eligible)
}

#' @keywords internal
#' @noRd
.generic_pool <- c(letters, LETTERS, as.character(0:9),
                   strsplit("!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~ ", "")[[1]])

#' S3: mutate at random (replace from generic printable-ASCII pool)
#' @keywords internal
#' @noRd
mutate_S3 <- function(s, alphabet, p = 0.5) {
  always_eligible <- function(chars) rep(TRUE, length(chars))
  .mutate_string(s, p, .generic_pool, always_eligible)
}

#' SP: scramble structure (permute punctuation positions, keep alnum identity)
#' @keywords internal
#' @noRd
mutate_SP <- function(s, p = 1.0) {
  chars <- strsplit(s, "")[[1]]
  n <- length(chars)
  is_alnum <- grepl("^[A-Za-z0-9]$", chars)
  punct_idx <- which(!is_alnum)
  if (length(punct_idx) == 0) return(s)
  move <- runif(length(punct_idx)) < p
  if (!any(move)) return(s)
  moving_chars <- sample(chars[punct_idx[move]])
  fixed_chars  <- chars[-punct_idx[move]]
  new_pos <- sort(sample(seq_len(n), length(moving_chars)))
  out <- character(n)
  out[new_pos] <- moving_chars
  out[-new_pos] <- fixed_chars
  paste(out, collapse = "")
}

## ---- batch negative generation --------------------------------------------

#' Generate negative examples for a mutation tier
#'
#' Produces `n_per_positive` mutated (likely-negative) strings for each example
#' in `P`, using mutation tier `"S1"`, `"S2"`, `"S3"`, or `"SP"`.
#'
#' @param P A character vector of positive examples.
#' @param tier One of `"S1"`, `"S2"`, `"S3"`, `"SP"`.
#' @param n_per_positive Number of mutants to attempt per positive.
#' @param p Per-character mutation probability.
#' @param seed Optional integer seed for reproducibility.
#'
#' @return A character vector of unique mutated strings.
#' @export
generate_autotype_negatives <- function(P, tier = c("S1", "S2", "S3", "SP"),
                                        n_per_positive = 10, p = 0.5,
                                        seed = NULL) {
  tier <- match.arg(tier)
  if (!is.null(seed)) set.seed(seed)
  alphabet <- infer_alphabet(P)
  out <- character(0)
  for (s in P) {
    for (i in seq_len(n_per_positive)) {
      mutated <- switch(tier,
        S1 = mutate_S1(s, alphabet, p),
        S2 = mutate_S2(s, alphabet, p),
        S3 = mutate_S3(s, alphabet, p),
        SP = mutate_SP(s, p)
      )
      out <- c(out, mutated)
    }
  }
  unique(out)
}

#' Build a labelled test-case table for one data type
#'
#' Assembles the pure inputs used by the bundled [data_type_tests] object: the
#' real positive examples plus deduplicated negatives from each mutation tier,
#' labelled by origin. Unlike [build_autotype_results()], this stores no
#' detector predictions -- it is the fixture a detector is later scored against.
#'
#' @param P A character vector of positive examples.
#' @param data_type A single string naming the type (e.g. `"currency_code"`).
#' @param tiers Mutation tiers to include.
#' @param n_per_positive Number of mutants to attempt per positive per tier.
#' @param p Per-character mutation probability.
#' @param seed Integer seed; set for reproducible fixtures.
#'
#' @return A data frame with columns `data_type`, `case`, and `label`, where
#'   `label` is `"valid"` for real positives or the tier name (`"S1"`, `"S2"`,
#'   `"S3"`, `"SP"`) for negatives. Negatives coinciding with a real positive
#'   are dropped.
#' @export
generate_autotype_test_cases <- function(P, data_type,
                                         tiers = c("S1", "S2", "S3", "SP"),
                                         n_per_positive = 20, p = 0.5,
                                         seed = 514) {
  rows <- list(data.frame(
    data_type = data_type, case = P, label = "valid",
    stringsAsFactors = FALSE
  ))
  for (tier in tiers) {
    N <- generate_autotype_negatives(P, tier, n_per_positive, p, seed = seed)
    N <- setdiff(N, P)
    if (length(N) == 0) next
    rows[[tier]] <- data.frame(
      data_type = data_type, case = N, label = tier,
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, rows)
}

## ---- scored results table + reports (dev artifacts) -----------------------

#' Run a detector against positives and generated negatives
#'
#' Scores `detector` on the real positives `P` and on negatives generated at
#' each mutation tier, returning one tidy table. Used to build the
#' human-readable artifacts in `data-types/`.
#'
#' @param detector A function taking a character vector and returning a logical
#'   (or numeric score) vector.
#' @param P A character vector of positive examples.
#' @param tiers Mutation tiers to include.
#' @param n_per_positive Mutants attempted per positive per tier.
#' @param p Per-character mutation probability.
#' @param seed Integer seed.
#' @param threshold Score threshold used when `detector` returns numeric.
#'
#' @return A data frame with columns `case`, `type` (`"valid"` or a tier),
#'   `f_match` (raw detector output), and `f_predict` (logical prediction).
#' @export
build_autotype_results <- function(detector, P, tiers = c("S1", "S2", "S3", "SP"),
                                   n_per_positive = 20, p = 0.5, seed = 514,
                                   threshold = 0.5) {
  as_predict <- function(x) if (is.logical(x)) x else (x > threshold)
  f_valid <- detector(P)
  rows <- list(data.frame(
    case = P, type = "valid",
    f_match = f_valid, f_predict = as_predict(f_valid),
    stringsAsFactors = FALSE
  ))
  for (tier in tiers) {
    N <- generate_autotype_negatives(P, tier, n_per_positive, p, seed = seed)
    N <- setdiff(N, P)
    if (length(N) == 0) next
    f_neg <- detector(N)
    rows[[tier]] <- data.frame(
      case = N, type = tier,
      f_match = f_neg, f_predict = as_predict(f_neg),
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, rows)
}

#' Summarize an autotype results table by mutation tier
#'
#' @param results Output of [build_autotype_results()].
#' @return A data frame with columns `type`, `n`, and `pass_rate`.
#' @export
autotype_summary <- function(results) {
  out <- aggregate(f_predict ~ type, data = results,
                   FUN = function(x) c(n = length(x), pass_rate = mean(x)))
  data.frame(type = out$type, n = out$f_predict[, "n"],
             pass_rate = out$f_predict[, "pass_rate"])
}

#' One master-table row for a data type
#'
#' @param type_label A human-readable label for the type.
#' @param P The positive examples (for the Example column).
#' @param results Output of [build_autotype_results()].
#' @param n_examples Number of example positives to show.
#' @return A one-row data frame: `Type`, `Example`, `Recall`, `S1`-`SP`.
#' @export
autotype_summary_row <- function(type_label, P, results, n_examples = 3) {
  s <- autotype_summary(results)
  get_rate <- function(t) {
    v <- s$pass_rate[s$type == t]
    if (length(v) == 0) NA else v
  }
  data.frame(
    Type = type_label,
    Example = paste(head(P, n_examples), collapse = ";; "),
    Recall = get_rate("valid"),
    S1 = get_rate("S1"), S2 = get_rate("S2"),
    S3 = get_rate("S3"), SP = get_rate("SP")
  )
}

#' Print an autotype error report for a results table
#'
#' Reports false negatives (real positives the detector rejected) and up to
#' `n_examples` false positives per mutation tier (negatives wrongly accepted).
#'
#' @param results Output of [build_autotype_results()].
#' @param type_name A label for the report header.
#' @param n_examples Number of example errors to show per section.
#' @return `results`, invisibly (called for its printed side effect).
#' @export
generate_autotype_report <- function(results, type_name, n_examples = 3) {
  cat("################  ERROR REPORT:", type_name, "################\n\n")
  fn <- results$case[results$type == "valid" & !results$f_predict]
  cat(sprintf("False negatives -- real positives REJECTED (%d):\n", length(fn)))
  if (length(fn) > 0) cat("  ", paste(head(fn, n_examples), collapse = " | "), "\n")
  cat("\n")
  for (tier in setdiff(unique(results$type), "valid")) {
    sub <- results[results$type == tier, ]
    fp <- sub$case[sub$f_predict]
    cat(sprintf("%s false positives -- negatives wrongly ACCEPTED (%d / %d, %.1f%%):\n",
                tier, length(fp), nrow(sub), 100 * length(fp) / max(1, nrow(sub))))
    if (length(fp) > 0) cat("  ", paste(head(fp, n_examples), collapse = " | "), "\n")
    cat("\n")
  }
  invisible(results)
}
