# Create all non-level-1 div section in markdown

Writes a formatted \`div\` block to the quarto document. Format of the
\`div\` block is determined by the \`all.layouts\` table.

## Usage

``` r
create_div(div.num = "div2", all.layouts)
```

## Arguments

- div.num:

  Character string naming the div to render (e.g. \`"div2"\`).

- all.layouts:

  output of
  [get_design](https://urbaninstitute.github.io/datagoodr/reference/get_design.md)

## Value

No return value, called for side effects (writes markdown text).

## Details

The current variable's content is read from the render context (set by
[create_section](https://urbaninstitute.github.io/datagoodr/reference/create_section.md)
or a \`dg\_\*()\` helper). If \`div.num\` is not included in
\`all.layouts\`, nothing is printed for that div.
