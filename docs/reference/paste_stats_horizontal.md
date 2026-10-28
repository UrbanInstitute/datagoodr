# Print the numeric STATS transposed across a full-width row

Reads \`rg_stats\` and prints Minimum, the quantiles, Mean and Maximum
as a single-row (transposed) table so the summary spreads horizontally
across the full width instead of stacking. Skew/Kurtosis live in
PROPERTIES.

## Usage

``` r
paste_stats_horizontal(VNAME, LABEL = "STATS")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_stats"\`).

- LABEL:

  A character string for the section title. Defaults to \`"STATS"\`.

## Value

No return value; prints the STATS row to the RG.
