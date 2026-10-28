# Print the combined STATS table (summary + quantiles) into the RG

Reads \`rg_stats\` and prints one table: Minimum, Mean, Maximum, then
the quantiles Q-05 / Q-25 / Q-50 / Q-75 / Q-95. Skew and Kurtosis are
shown in PROPERTIES (as LOW/MED/HIGH), so they are excluded here. Values
are padded so their decimal points line up down the column (see
\[align_dec()\]).

## Usage

``` r
paste_stats_combined(VNAME, LABEL = "STATS")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_stats"\`).

- LABEL:

  A character string for the section title. Defaults to \`"STATS"\`.

## Value

No return value; prints the STATS table to the RG.
