# Print the research guide's top bar and contents list

Writes a sticky top bar (a link per data-type group) and a numbered
two-column contents list: variable number and name on the left, its
label on the right, grouped by data type. Call inside a \`results =
"asis"\` chunk.

## Usage

``` r
rail_contents(groups, brand = "Research Guide")
```

## Arguments

- groups:

  A named list of DGF subsets, as returned by \[rail_groups()\]. Empty
  groups are skipped.

- brand:

  Text for the top bar. Defaults to \`"Research Guide"\`.

## Value

No return value; prints raw HTML.

## See also

\[rail_sections()\]
