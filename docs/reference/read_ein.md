# Read an EIN written in any common form

Ingests an Employer Identification Number however it arrives — nine
digits, hyphenated, or with the leading zero stripped by a spreadsheet —
and returns the canonical hyphenated form \`NN-NNNNNNN\`. This is the
form the type ontology declares as the stable value for \`identifier /
id / administrative (ein)\`, so a datagoodr-stabilized EIN and a
formex-stabilized EIN are the same string.

## Usage

``` r
read_ein(x)
```

## Arguments

- x:

  A single EIN value (numeric or character).

## Value

A canonical \`"NN-NNNNNNN"\` EIN string, \`NA\` if \`x\` is \`NA\`, or
\`NA\` with a warning when \`x\` does not hold nine or fewer digits.

## See also

\[read_mm()\], \[read_yyyy()\], \[read_yyyymm()\]

## Examples

``` r
read_ein("12345678")    # leading zero restored
#> [1] "01-2345678"
read_ein("01-2345678")  # already canonical
#> [1] "01-2345678"
```
