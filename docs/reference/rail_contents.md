# Print the research guide's top bar and contents list

Writes a sticky top bar (a link per data-type group) and a numbered
two-column contents list: variable number and name on the left, its
label on the right, grouped by data type. Call inside a \`results =
"asis"\` chunk.

## Usage

``` r
rail_contents(groups, brand = "Research Guide", glimpse = 48)
```

## Arguments

- groups:

  A named list of DGF subsets, as returned by \[rail_groups()\]. Empty
  groups are skipped.

- brand:

  Text for the top bar. Defaults to \`"Research Guide"\`.

- glimpse:

  Characters of example data to show under each variable's label: the
  stabilized first values (\`stable_first5\`), or the preview values for
  a variable the stabilizer leaves alone. Whole values only — the
  glimpse stops before the value that would break the budget rather than
  cutting it — so the count varies by how long they are. \`0\` leaves
  the data out. Defaults to \`48\`.

## Value

No return value; prints raw HTML.

## See also

\[rail_sections()\]
