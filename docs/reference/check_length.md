# Check and standardize design element length

Ensures a parsed design element has the correct length and structure. If
only three elements are present, an empty string is appended as the
fourth element. If the length is not four, an error is thrown.

## Usage

``` r
check_length(x)
```

## Arguments

- x:

  A character vector representing a parsed design element.

## Value

A named character vector of length four with names \`"DIV"\`,
\`"VNAME"\`, \`"LABEL"\`, and \`"FUNCTION"\`.

## Details

Used in
[parse_design](https://urbaninstitute.github.io/datagoodr/reference/parse_design.md).
