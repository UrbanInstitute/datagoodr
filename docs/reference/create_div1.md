# Create a level-1 div section in markdown

Writes a formatted \`div1\` block to the quarto document. \`div1\` is
the variable name for all variable types.

## Usage

``` r
create_div1(x = "var_name", label = "")
```

## Arguments

- x:

  Character string, the variable name shown as the header. Defaults to
  \`"var_name"\`.

- label:

  Optional plain-language variable label, printed on the same line as
  the name. Left out when blank or identical to the name.

## Value

No return value, called for side effects (writes markdown text).
