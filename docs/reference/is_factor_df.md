# Guess factor columns across a data frame

Applies \[is_factor()\] to every column of a data frame, suppressing the
per-column console diagnostics.

## Usage

``` r
is_factor_df(df)
```

## Arguments

- df:

  A data frame.

## Value

A named logical vector, one element per column, indicating which columns
should be treated as factors.

## See also

\[is_factor()\], \[recast_factors()\]
