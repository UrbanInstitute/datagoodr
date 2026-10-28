# Return a factor's levels as a single delimited string

Collapses the levels of a factor into one character string, separated by
\`" ;; \n"\`. If the factor has more than 50 levels, only the first 50
are used and a warning is issued.

## Usage

``` r
get_levels(f)
```

## Arguments

- f:

  A factor (or a vector coercible to a factor).

## Value

A single character string listing the factor levels.
