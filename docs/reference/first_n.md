# Extract and Format the First N Unique Values from a Vector

This function extracts the first N unique, non-missing values from a
vector, formats them appropriately, and returns them as a truncated
character string.

## Usage

``` r
first_n(x, n = 5)
```

## Arguments

- x:

  A vector of any type (numeric, character, factor, or Date).

- n:

  An integer specifying the number of unique values to return. Defaults
  to 5.

## Value

A formatted character string containing up to the first N unique values
from \`x\`, separated by \`" ;; \n"\`. If \`x\` is numeric, values are
rounded to three decimal places. If \`x\` contains factors or dates,
they are converted to character strings.

## See also

[`str_trunc`](https://stringr.tidyverse.org/reference/str_trunc.html)

## Examples

``` r
first_n(c("apple", "banana", "cherry", "date", "elderberry", "fig"), 3)
#> [1] "apple ;; \nbanana ;; \ncherry"
first_n(c(1.234567, 2.345678, 3.456789), 2)
#> [1] "1.235 ;; \n2.346"
first_n(as.Date(c("2021-01-01", "2021-02-01", "2021-03-01")), 2)
#> [1] "2021-01-01 ;; \n2021-02-01"
```
