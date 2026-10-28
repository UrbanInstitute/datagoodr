# Split a delimited alias string into unique names

Splits a \`";;"\`-delimited string of variable-name aliases into a
trimmed vector of unique names.

## Usage

``` r
parse_nm(x)
```

## Arguments

- x:

  A single character string containing one or more names separated by
  \`";;"\`.

## Value

A character vector of unique, whitespace-trimmed names.
