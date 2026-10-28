# Summarise the class and an example value for each column

Builds a small data frame reporting, for every column of \`df\`, the
column name, its class, and the first non-missing value as an example.

## Usage

``` r
get_class_df(df)
```

## Arguments

- df:

  A data frame.

## Value

A data frame with columns \`VAR\`, \`TYPE\`, and \`EXAMPLE\`.
