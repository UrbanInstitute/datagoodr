# Read a year, plain or fiscal-year labelled

Ingests a four-digit year written plainly (\`2019\`) or with a
fiscal-year prefix (\`FY2019\`, \`FY 2019\`) and returns the bare
four-digit year. \`NA\` is returned unchanged.

## Usage

``` r
read_yyyy(x)
```

## Arguments

- x:

  A single year value (numeric or character).

## Value

The four-digit year as a character string, or \`NA\` if \`x\` is \`NA\`.

## See also

\[read_mm()\], \[read_yyyymm()\]

## Examples

``` r
read_yyyy(2019)
#> [1] "2019"
read_yyyy("FY2019")
#> [1] "2019"
```
