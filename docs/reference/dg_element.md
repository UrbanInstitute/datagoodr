# Render one element of a variable's profile

Print a single piece of a variable's profile inline: its summary
statistics, data-quality properties, value preview, factor levels,
graphic, or any text field from the DGF.

## Usage

``` r
dg_stats(dgf, var_name, label = "STATS")

dg_properties(dgf, var_name, label = "PROPERTIES")

dg_quantiles(dgf, var_name, label = "QUANTILES")

dg_preview(dgf, var_name, label = "PREVIEW", size = 80)

dg_levels(dgf, var_name, label = "LEVELS")

dg_graphic(dgf, var_name, label = NULL)

dg_field(dgf, var_name, field, label = toupper(field))
```

## Arguments

- dgf:

  A DGF data frame.

- var_name:

  The variable name (a value of \`dgf\$var_name\`).

- label:

  Optional section label; defaults to the render function's own default
  (e.g. \`"STATS"\`).

- size:

  Maximum line width for \`dg_preview\`, in characters (default 80).

- field:

  DGF column name to print (for \`dg_field\`).

## Value

No return value; prints the element. Call inside a \`results = "asis"\`
chunk.

## Functions

- `dg_stats()`: Summary statistics (type-appropriate).

- `dg_properties()`: Data-quality properties (rows, distinct, missing,
  ...).

- `dg_quantiles()`: Quantile table (numeric variables).

- `dg_preview()`: Preview of example values (numeric or character).

- `dg_levels()`: Factor/logical level dictionary.

- `dg_graphic()`: The type-appropriate graphic (histogram, treemap, bar
  plot, or word cloud). Set chunk \`fig.width\`/\`fig.height\` to size
  it.

- `dg_field()`: Any text field from the DGF (e.g. \`"dd_vdesc"\`,
  \`"dd_vlabel"\`, \`"dd_vdesc"\`). \`field\` is the DGF column name.

## See also

\[dg_section()\]
