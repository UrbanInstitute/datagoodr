# Wrap preview values into a text block

Packs example values into lines no wider than \`size\` characters,
separated by \`sep\`. Any single value longer than \`size\` is truncated
to \`size - 3\` characters, given a trailing \`...\`, and placed on its
own line.

## Usage

``` r
wrap_preview(x, size = 80, sep = " ;; ")
```

## Arguments

- x:

  A character vector of values, or a single \`;;\`-delimited string.

- size:

  Maximum line width, in characters. Defaults to \`80\`.

- sep:

  Separator placed between values packed onto the same line. Defaults to
  \`" ;; "\`.

## Value

A character vector of wrapped lines.

## Examples

``` r
wrap_preview(c("apple", "banana", "cherry"), size = 15)
#> [1] "apple ;; banana" "cherry"         
```
