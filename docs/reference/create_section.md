# Create a section for a variable

Generates a formatted section in Quarto for a given variable. Uses
layouts from \`all.layouts\` and content from \`L\` to construct div
blocks.

## Usage

``` r
create_section(VNAME = "EIN", all.layouts, L)
```

## Arguments

- VNAME:

  Character string, the name of the variable to create a section for.
  Defaults to \`"EIN"\`.

- all.layouts:

  Output of
  [get_design](https://urbaninstitute.github.io/datagoodr/reference/get_design.md).

- L:

  A named list of variable-specific content. \`L\[\[VNAME\]\]\` should
  be the output of \`dgf_to_list( dgf )\` where \`dgf\` is the dgf as a
  data frame.

## Value

No return value; the function writes formatted Quarto content to the
output.

## Details

The function publishes \`L\[\[VNAME\]\]\` to the render context (see
\`set_xx\`) so the downstream div functions can read it.

## See also

\[create_all_sections()\]
