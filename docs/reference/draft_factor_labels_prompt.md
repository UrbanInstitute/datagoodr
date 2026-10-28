# Draft a copy-paste prompt asking an LLM to label factor levels

Collects the factor/logical variables in a DGF whose levels are still
coded (label == level), and builds a self-contained prompt: the
versioned factor-labels contract (see
\`inst/prompts/factor-labels-contract.md\`) followed by each variable's
name, label, description, and its \`dd_f_levels\` JSON. The LLM returns
paste-ready JSON with human-readable labels. Useful when levels are
decipherable but tedious to label by hand, or are a standard code system
an LLM can look up (ISO currency, FIPS, NTEE, ...).

## Usage

``` r
draft_factor_labels_prompt(
  dgf,
  vars = NULL,
  file = NULL,
  contract_path = NULL,
  quiet = FALSE
)
```

## Arguments

- dgf:

  A DGF data frame, or a path to a DGF \`.xlsx\` (read via
  \[load_dgf()\]) or \`.csv\` (read via \[utils::read.csv()\]).

- vars:

  Optional character vector of \`var_name\`s to restrict to; default is
  all factor/logical variables with populated levels.

- file:

  Output path for the prompt \`.md\`; \`NULL\` writes to \`tempdir()\`.

- contract_path:

  Optional override for the bundled contract (path or URL).

- quiet:

  If \`TRUE\`, only write the file (no console print).

## Value

The prompt file path, invisibly. The prompt text is printed unless
\`quiet = TRUE\`.

## See also

\[load_dgf()\], \[draft_detector_prompt()\]
