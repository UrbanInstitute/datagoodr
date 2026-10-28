# Create a data dictionary project from a DGF

Scaffolds a data-dictionary Quarto document (descriptors only — no data
profiles) pointed at a DGF, plus a starter \`DG.R\`.

## Usage

``` r
create_dd(
  dgf = "DGF.xlsx",
  data = NULL,
  dir = ".",
  file = "data-dictionary.qmd",
  embed_css = FALSE,
  render = FALSE,
  overwrite = FALSE
)
```

## Arguments

- dgf:

  Path to a DGF \`.xlsx\` file, or a DGF data frame (which is written to
  \`DGF.xlsx\` in \`dir\`). Defaults to \`"DGF.xlsx"\`.

- data:

  Optional path to the raw dataset. Defaults to \`NULL\`. The report
  renders from the DGF alone, so this is only needed when a custom chunk
  or \`DG.R\` wants the underlying values; when supplied it is read into
  \`raw.data\` in the document.

- dir:

  Directory to scaffold into. Defaults to the current directory.

- file:

  Name for the report document. Defaults to \`"data-dictionary.qmd"\`.

- embed_css:

  Logical; write the stylesheet into the document instead of calling
  \[datagoodr_css()\] at render. Defaults to \`FALSE\`. Use it to edit
  the CSS in place, accepting that an embedded copy stops tracking the
  packaged stylesheet.

- render:

  Logical; render the document immediately. Defaults to \`FALSE\`
  (scaffold only, so the user can annotate it first).

- overwrite:

  Logical; overwrite an existing document. Defaults to \`FALSE\`.

## Value

Invisibly, the path to the scaffolded (or rendered) document.

## See also

\[create_rg()\], \[update_rg()\], \[use_datagoodr_template()\]
