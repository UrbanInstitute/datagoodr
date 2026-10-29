# Parse design strings into a data frame

This function parses a character string (or vector of strings)
containing fields separated by \`;;\` into a tidy data frame. It trims
whitespace, checks element lengths with \`check_length()\`, and binds
the parsed rows together.

## Usage

``` r
parse_design(x)
```

## Arguments

- x:

  A character vector, where each element contains values separated by
  \`;;\`.

## Value

A data frame, where each input string is split into fields and
represented as a row.

## Details

Used inside
[get_design](https://urbaninstitute.github.io/datagoodr/reference/get_design.md).

## See also

\[check_length()\]
