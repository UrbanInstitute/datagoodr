# Refresh a DGF against updated data (Step 4)

Compares an existing DGF to a new version of the dataset and produces an
updated DGF. Each variable's \`prov_current_hash\` is used to detect
change: variables whose data is unchanged keep their existing (curated)
DGF row, while changed or newly added variables have their data
summaries recomputed. Curated fields (descriptions, aliases, scope,
location, conversion/format rules) are preserved, and hand-edited factor
level labels are carried over for levels that still exist.

## Usage

``` r
update_dgf(dgf, df, file = "DGF", verbose = TRUE, open = interactive())
```

## Arguments

- dgf:

  An existing DGF: a data frame, or a path to a DGF \`.xlsx\` file.

- df:

  The updated dataset: a data frame, or a path to a \`.csv\` file.

- file:

  Output path stem (without extension) for the written \`.csv\` and
  \`.xlsx\`. Defaults to \`"DGF"\`.

- verbose:

  Logical; if \`TRUE\` (default) a summary of what changed is printed.

- open:

  Logical; open the refreshed DGF in Excel once written. Defaults to
  \[interactive()\] — on at the console, off in scripts, tests, and CI.

## Value

Invisibly, the updated DGF data frame. It carries a \`"status"\`
attribute: a named character vector labelling each variable as
\`"unchanged"\`, \`"changed"\`, or \`"added"\`; a \`"removed"\`
attribute listing variables no longer present in the data; and a
\`"stale_rules"\` attribute (from \[check_dgf_rules()\]) listing curated
\`as\_\*\` rules that no longer fit the new data.

## See also

\[create_dgf()\], \[inspect_dgf()\], \[check_dgf_rules()\]
