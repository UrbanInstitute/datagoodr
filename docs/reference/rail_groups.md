# Split a DGF into the research guide's data-type groups

Groups variables by the report template they render with
(\[dg_render_type()\]), in the order the research guide shows them:
Boolean, Categorical, Numeric, Text, Identifier, Temporal.

## Usage

``` r
rail_groups(dgf)
```

## Arguments

- dgf:

  A DGF data frame.

## Value

A named list of DGF subsets, one per group (empty groups included).

## See also

\[rail_contents()\], \[rail_sections()\]
