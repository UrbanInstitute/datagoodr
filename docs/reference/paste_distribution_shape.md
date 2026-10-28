# Print the DISTRIBUTION SHAPE table (skew / kurtosis) into the RG

Reads the numeric \`rg_stats\` cell and prints a small three-column
table - Skew and Kurtosis with their raw value and a LOW/MED/HIGH
interpretation. Shown in the numeric STATS block, directly beneath the
STATS table.

## Usage

``` r
paste_distribution_shape(VNAME, LABEL = "DISTRIBUTION SHAPE")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_stats"\`).

- LABEL:

  A character string for the section title. Defaults to \`"DISTRIBUTION
  SHAPE"\`.

## Value

No return value; prints the table (or nothing when the shape stats are
unavailable).
