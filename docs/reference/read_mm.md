# Read a month number written at any width

Ingests a month number written with or without its leading zero (\`8\`
or \`"08"\`) and returns the canonical two-digit form. \`NA\` is
returned unchanged.

## Usage

``` r
read_mm(x)
```

## Arguments

- x:

  A single month value (numeric or character).

## Value

A 2-character month string, or \`NA\` if \`x\` is \`NA\`.

## See also

\[read_ein()\], \[read_yyyy()\], \[read_yyyymm()\]

## Examples

``` r
read_mm(8)
#> [1] "08"
read_mm("08")
#> [1] "08"
```
