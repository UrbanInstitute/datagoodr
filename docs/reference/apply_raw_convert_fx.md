# Apply DGF type-conversion functions to raw columns

For each conversion function named in a DGF's \`raw_convert\` column,
applies that function to the columns assigned to it, transforming the
raw data into its intended types.

## Usage

``` r
apply_raw_convert_fx(df, dgf)
```

## Arguments

- df:

  A data frame of raw data.

- dgf:

  A DGF data frame with \`var_name\` and \`raw_convert\` columns.

## Value

The data frame with conversion functions applied to the relevant
columns.

## Details

Part of the not-yet-operational Step 2 pipeline.

## See also

[`mutate_at`](https://dplyr.tidyverse.org/reference/mutate_all.html),
\[parse_functions()\]
