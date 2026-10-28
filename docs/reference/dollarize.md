# Format Numeric Values as Dollar Amounts

This function formats numeric values as dollar amounts by rounding them
to the nearest whole number, adding commas as thousand separators, and
prefixing them with a dollar sign.

## Usage

``` r
dollarize(x)
```

## Arguments

- x:

  A numeric vector to be formatted.

## Value

A character vector with the formatted dollar amounts.

## Examples

``` r
dollarize(1234567.89) # Returns "$1,234,568"
#> [1] "$1,234,568"
dollarize(c(1000, 2500.75, 999999.99)) # Returns c("$1,000", "$2,501", "$1,000,000")
#> [1] "$1,000"     "$2,501"     "$1,000,000"
```
