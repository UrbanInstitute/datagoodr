# Convert a factor's levels to a formatted JSON string

Builds a level/label lookup table from a factor and serialises it to a
JSON string, adding whitespace so the result is readable when stored in
a DGF cell. The table is truncated to the first 50 levels.

## Usage

``` r
jsonify_f(f)
```

## Arguments

- f:

  A factor (or a vector coercible to a factor).

## Value

A single character string containing the pretty-printed JSON
representation of the factor's levels and labels.

## See also

[`toJSON`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
