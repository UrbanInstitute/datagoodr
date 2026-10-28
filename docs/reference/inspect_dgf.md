# Validate a DGF before rendering (Step 2)

Inspects a Data Governance File and checks that it is still well formed
after any manual edits, so that Step 3 can render it without error. The
following checks are run:

## Usage

``` r
inspect_dgf(dgf, convert_env = parent.frame(), verbose = TRUE)
```

## Arguments

- dgf:

  A DGF data frame, or a path to a DGF \`.xlsx\` file (read with
  \[load_dgf()\]).

- convert_env:

  Environment in which to look for the functions named in the
  \`desired_data_import_rule\`/\`stable_data_format\` columns. Defaults
  to the caller's environment, so functions you have sourced (e.g. from
  a project \`dgf.R\`) are found.

- verbose:

  Logical; if \`TRUE\` (default) a human-readable report is printed to
  the console.

## Value

Invisibly, a list with \`valid\` (a single logical) and \`problems\` (a
named list describing any issues found). Called mainly for its report.

## Details

- all required DGF columns are present;

- every \`desired_data_type\` value is one Step 3 can render (number,
  string, categorical, boolean);

- all non-empty cells in the JSON columns (\`dd_f_levels\`,
  \`rg_properties\`, \`rg_stats\`, \`rg_graphics\`) contain valid JSON;

- every function named in the \`desired_data_import_rule\` and
  \`stable_data_format\` columns is defined and callable;

- every variable has a non-empty \`prov_current_hash\`.

## See also

\[validate_json()\], \[show_invalid()\], \[create_dgf()\]
