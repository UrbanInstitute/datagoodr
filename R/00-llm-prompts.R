##############################
### LLM prompt scaffolding
###############################
## "Bring your own LLM" helpers: instead of calling an LLM API (which assumes
## paid access and a known provider), these functions assemble a portable,
## copy-paste prompt the user pastes into whatever LLM they have. Each prompt
## inlines a versioned, model-agnostic "contract" (bundled in inst/prompts/)
## plus a per-task payload, then is both printed to the console and written to
## a .md file for attaching to an LLM chat.
##
## Two workflows share the same delivery mechanism:
##   * draft_detector_prompt()      -> ask an LLM to write a new type detector
##   * draft_factor_labels_prompt() -> ask an LLM to label factor levels
## and draft_detector_prompt() is paired with evaluate_detector() to score the
## function the LLM returns.


#' Read a bundled prompt contract
#'
#' @param name Base name of a contract in `inst/prompts/` (without `.md`).
#' @param contract_path Optional override: a local file or URL to read instead
#'   of the bundled contract.
#' @return The contract text as a single string.
#' @keywords internal
#' @noRd
read_prompt_contract <- function(name, contract_path = NULL) {
  path <- contract_path
  if (is.null(path)) {
    path <- system.file("prompts", paste0(name, ".md"), package = "datagoodr")
    if (!nzchar(path)) {
      # dev fallback: running from the source tree before install
      path <- file.path("inst", "prompts", paste0(name, ".md"))
    }
  }
  if (!file.exists(path) && !grepl("^https?://", path)) {
    stop("Prompt contract not found: ", path)
  }
  paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
}

#' Print a prompt and write it to a shareable file
#'
#' Prints the assembled prompt to the console (for reading) and writes it to a
#' `.md` file (for attaching to an LLM chat, which matters once the prompt is
#' too long to paste comfortably).
#'
#' @param text The full prompt string.
#' @param slug A short name used for the default file name.
#' @param file Output path; if `NULL`, a `<slug>.md` file in `tempdir()`.
#' @param quiet If `TRUE`, suppress the console print (still writes the file).
#' @return The output file path, invisibly.
#' @keywords internal
#' @noRd
deliver_prompt <- function(text, slug, file = NULL, quiet = FALSE) {
  if (is.null(file)) file <- file.path(tempdir(), paste0(slug, ".md"))
  writeLines(text, file, useBytes = TRUE)
  if (!quiet) {
    cat(text, "\n", sep = "")
    message("\n--- prompt written to: ", normalizePath(file, mustWork = FALSE),
            " (attach this file to your LLM) ---")
  }
  invisible(file)
}

#' Draft a copy-paste prompt asking an LLM to write a new type detector
#'
#' Turns a handful of example values for a new data type into a self-contained
#' prompt: the versioned detector contract (see
#' `inst/prompts/detector-contract.md`) followed by the type's positive
#' examples and machine-generated hard negatives. Paste or attach the result
#' into any LLM; feed the function it returns to [evaluate_detector()].
#'
#' @param examples A character vector of 10-25 valid example values for the new
#'   type.
#' @param type_name A single lower_snake_case type name, e.g. `"iso_country"`.
#'   The LLM is asked to write `is_<type_name>()`.
#' @param n_negatives Max hard negatives to include per mutation tier (keeps the
#'   prompt readable; the file still captures everything you pass).
#' @param seed Integer seed for reproducible test-case generation.
#' @param file Output path for the prompt `.md`; `NULL` writes to `tempdir()`.
#' @param contract_path Optional override for the bundled contract (path or URL).
#' @param quiet If `TRUE`, only write the file (no console print).
#'
#' @return The prompt file path, invisibly. The prompt text is printed unless
#'   `quiet = TRUE`.
#'
#' @seealso [evaluate_detector()], [guess_data_type()]
#' @export
draft_detector_prompt <- function(examples, type_name, n_negatives = 15,
                                  seed = 514, file = NULL,
                                  contract_path = NULL, quiet = FALSE) {
  examples <- unique(as.character(examples))
  examples <- examples[!is.na(examples) & nzchar(examples)]
  if (length(examples) < 3) {
    stop("Provide at least a few example values (10-25 is ideal).")
  }
  contract <- read_prompt_contract("detector-contract", contract_path)

  # build labelled test cases, then sample hard negatives (exclude S1)
  tc <- generate_autotype_test_cases(examples, data_type = type_name, seed = seed)
  hard <- tc[tc$label %in% c("S2", "S3", "SP"), ]
  take <- function(lbl) {
    v <- hard$case[hard$label == lbl]
    utils::head(v, n_negatives)
  }
  negs <- unique(c(take("S2"), take("S3"), take("SP")))

  payload <- paste0(
    "## TYPE: ", type_name, "\n\n",
    "Write `is_", type_name, "(x)` per the contract above.\n\n",
    "### Positives (must return TRUE for all)\n",
    "```r\n", paste(deparse(examples), collapse = "\n"), "\n```\n\n",
    "### Hard negatives (should return FALSE; S1 not shown by design)\n",
    "```r\n", paste(deparse(negs), collapse = "\n"), "\n```\n"
  )
  prompt <- paste0(contract, "\n\n", payload)
  deliver_prompt(prompt, slug = paste0("detector-prompt-", type_name),
                 file = file, quiet = quiet)
}

#' Score a candidate detector against generated test cases
#'
#' Runs the (LLM-produced) detector over the positives and freshly generated
#' negatives and returns the same recall/precision report used to build the
#' package's own fixtures — so you can see how well the suggested function
#' works before adopting it.
#'
#' @param detector A function taking a character vector and returning a logical
#'   vector (the function the LLM wrote).
#' @param examples The same positive examples passed to [draft_detector_prompt()].
#' @param type_name Optional label for the report header.
#' @param seed Integer seed (match the drafting call for identical negatives).
#'
#' @return The results table from [build_autotype_results()], invisibly, after
#'   printing the error report via [generate_autotype_report()].
#'
#' @seealso [draft_detector_prompt()]
#' @export
evaluate_detector <- function(detector, examples, type_name = "candidate",
                              seed = 514) {
  stopifnot(is.function(detector))
  examples <- unique(as.character(examples))
  examples <- examples[!is.na(examples) & nzchar(examples)]
  res <- build_autotype_results(detector, examples, seed = seed)
  generate_autotype_report(res, type_name)
  invisible(res)
}

#' Draft a copy-paste prompt asking an LLM to label factor levels
#'
#' Collects the factor/logical variables in a DGF whose levels are still coded
#' (label == level), and builds a self-contained prompt: the versioned
#' factor-labels contract (see `inst/prompts/factor-labels-contract.md`)
#' followed by each variable's name, label, description, and its `dd_f_levels`
#' JSON. The LLM returns paste-ready JSON with human-readable labels. Useful
#' when levels are decipherable but tedious to label by hand, or are a standard
#' code system an LLM can look up (ISO currency, FIPS, NTEE, ...).
#'
#' @param dgf A DGF data frame, or a path to a DGF `.xlsx` (read via
#'   [load_dgf()]) or `.csv` (read via [utils::read.csv()]).
#' @param vars Optional character vector of `var_name`s to restrict to; default
#'   is all factor/logical variables with populated levels.
#' @param file Output path for the prompt `.md`; `NULL` writes to `tempdir()`.
#' @param contract_path Optional override for the bundled contract (path or URL).
#' @param quiet If `TRUE`, only write the file (no console print).
#'
#' @return The prompt file path, invisibly. The prompt text is printed unless
#'   `quiet = TRUE`.
#'
#' @seealso [load_dgf()], [draft_detector_prompt()]
#' @export
draft_factor_labels_prompt <- function(dgf, vars = NULL, file = NULL,
                                       contract_path = NULL, quiet = FALSE) {
  if (is.character(dgf) && length(dgf) == 1) {
    dgf <- if (grepl("\\.csv$", dgf, ignore.case = TRUE)) {
      utils::read.csv(dgf, stringsAsFactors = FALSE, check.names = FALSE)
    } else {
      load_dgf(dgf)
    }
  }
  need <- c("var_name", "dd_f_levels")
  if (!all(need %in% names(dgf))) {
    stop("Not a DGF: missing column(s) ", paste(setdiff(need, names(dgf)),
                                                collapse = ", "))
  }
  get_col <- function(nm) if (nm %in% names(dgf)) dgf[[nm]] else rep("", nrow(dgf))
  lvl  <- trimws(as.character(get_col("dd_f_levels")))
  has_levels <- !is.na(lvl) & nchar(lvl) > 2
  keep <- has_levels
  if (!is.null(vars)) keep <- keep & dgf$var_name %in% vars
  if (!any(keep)) stop("No factor variables with populated levels to label.")

  contract <- read_prompt_contract("factor-labels-contract", contract_path)
  vname <- as.character(get_col("var_name"))
  vlab  <- as.character(get_col("dd_vlabel"))
  vdesc <- as.character(get_col("dd_vdesc"))

  blocks <- vapply(which(keep), function(i) {
    lines <- paste0("## ", vname[i])
    if (nzchar(vlab[i]) && !identical(vlab[i], vname[i]) && !is.na(vlab[i])) {
      lines <- c(lines, paste0("**Label:** ", vlab[i]))
    }
    if (nzchar(vdesc[i]) && !is.na(vdesc[i])) {
      lines <- c(lines, paste0("**Description:** ", vdesc[i]))
    }
    lines <- c(lines, "```json", lvl[i], "```")
    paste(lines, collapse = "\n")
  }, character(1))

  payload <- paste0(
    "## VARIABLES TO LABEL (", sum(keep), ")\n\n",
    paste(blocks, collapse = "\n\n")
  )
  prompt <- paste0(contract, "\n\n", payload)
  deliver_prompt(prompt, slug = "factor-labels-prompt", file = file,
                 quiet = quiet)
}
