# Print the quantiles of a numeric variable into the RG

Reads the \`rg_stats\` column of the DGF and prints just the quantile
rows (Q-05, Q-25, Median, Q-75, Q-95) as a QUANTILES table. The
remaining summary statistics are shown by \[paste_stats_num()\].

## Usage

``` r
paste_quantiles(VNAME, LABEL = "QUANTILES")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_stats"\`).

- LABEL:

  A character string for the section title. Defaults to \`"QUANTILES"\`.

## Value

No return value; prints the QUANTILES table to the RG.

## Details

Internal to [create_div](create_div.md) in R/03-01-create-sections.R.
