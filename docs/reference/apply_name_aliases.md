# Rename raw columns to their DGF variable names

Uses the \`var_name\`, \`dd_vname_alias\`, and \`dd_vlabel\` columns of
a DGF to rename the columns of a raw data frame from their alias (raw)
names to their canonical DGF names, attaching labels. Columns without an
alias keep their existing name.

## Usage

``` r
apply_name_aliases(df, dgf)
```

## Arguments

- df:

  A data frame of raw data.

- dgf:

  A DGF data frame containing \`var_name\`, \`dd_vname_alias\`, and
  \`dd_vlabel\` columns.

## Value

The data frame with columns renamed and labelled per the DGF.

## See also

[`renamefrom`](https://rdrr.io/pkg/crosswalkr/man/renamefrom.html)
