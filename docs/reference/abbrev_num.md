# Abbreviate numbers for compact, uniform axis/graphic labels

Formats numbers with K/M/B/T suffixes (thousands, millions, billions,
trillions) at a fixed number of significant figures, so labels stay
short and roughly the same width. Negatives keep their sign; \`0\` maps
to \`"0"\`. Vectorised.

## Usage

``` r
abbrev_num(x, sig = 3)
```

## Arguments

- x:

  A numeric vector.

- sig:

  Significant figures to keep (default 3).

## Value

A character vector of abbreviated numbers, e.g. \`-61.5M\`, \`4.18B\`.

## Examples

``` r
abbrev_num(c(-61467591, 100, 3.9, 4178522311))
#> [1] "-61.5M" "100"    "3.9"    "4.18B" 
```
