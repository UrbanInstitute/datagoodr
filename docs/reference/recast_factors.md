# Convert guessed factor columns to factors

Uses \[is_factor_df()\] to identify columns that should be treated as
categorical and converts each of them to a factor, leaving all other
columns unchanged.

## Usage

``` r
recast_factors(df)
```

## Arguments

- df:

  A data frame.

## Value

The input data frame with guessed-categorical columns coerced to
factors.

## See also

\[is_factor_df()\]
