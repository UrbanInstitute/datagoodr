# Render one variable's full profile section

Emits the complete layout section (all divs) for a single variable,
exactly as it would appear in a full report. Use it to place one
variable's profile inline in a narrative document.

## Usage

``` r
dg_section(dgf, var_name, style = "rg", layouts = NULL)
```

## Arguments

- dgf:

  A DGF data frame.

- var_name:

  The variable name (a value of \`dgf\$var_name\`).

- style:

  \`"rg"\` (full profile) or \`"dd"\` (descriptors only). Defaults to
  \`"rg"\`.

- layouts:

  Optional layout override passed to \[get_design()\].

## Value

No return value; prints the section. Call inside a \`results = "asis"\`
chunk.

## See also

\[dg_stats()\], \[dg_properties()\], \[dg_levels()\], \[dg_field()\]
