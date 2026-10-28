# Read a compact YYYYMM value

Ingests a six-character \`YYYYMM\` value (\`"201903"\`), or one already
hyphenated (\`"2019-03"\`), and returns the canonical \`"YYYY-MM"\`
form. \`NA\` is returned unchanged.

## Usage

``` r
read_yyyymm(x)
```

## Arguments

- x:

  A single \`YYYYMM\` value (numeric or character).

## Value

A \`"YYYY-MM"\` character string, or \`NA\` if \`x\` is \`NA\`.

## See also

\[read_yyyy()\], \[read_mm()\]

## Examples

``` r
read_yyyymm(201903)
#> [1] "2019-03"
read_yyyymm("2019-03")
#> [1] "2019-03"
```
