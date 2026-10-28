# Pad a column of formatted numbers so their decimal points align

Given already-formatted number strings (commas allowed), pads the
fractional side with non-breaking spaces so that, under right alignment
in a monospace cell, every decimal point sits in the same column - rows
without a decimal get blank placeholders where the fraction would be.

## Usage

``` r
align_dec(x)
```

## Arguments

- x:

  A character vector of formatted numbers (e.g. \`"29,933"\`,
  \`"362,012.5"\`).

## Value

A character vector padded for decimal alignment.
