# Create a research guide project from a DGF

Scaffolds a research-guide Quarto document (full data profile) pointed
at a DGF, plus a starter \`DG.R\`, ready to customize and render.

## Usage

``` r
create_rg(
  dgf = "DGF.xlsx",
  data = NULL,
  dir = ".",
  file = "research-guide.qmd",
  embed_css = FALSE,
  render = FALSE,
  overwrite = FALSE,
  style = c("rail", "vintage")
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

  Name for the report document. Defaults to \`"research-guide.qmd"\`.

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

- style:

  Layout style. \`"rail"\` (the default) gives each variable a left rail
  (data type, label, name, description, properties) beside its graphic,
  preview and stats, grouped by data type under a numbered contents
  list. \`"vintage"\` is the original three-column grid.

## Value

Invisibly, the path to the scaffolded (or rendered) document.

## Details

The DGF path is baked into the document's YAML, so it renders on its own
from RStudio/Positron. To re-render against a different DGF later, use
\[update_rg()\] rather than re-scaffolding: it overrides at render time
and leaves your edits to the document intact.

Each style ships its own stylesheet next to the document:
\`datagoodr.css\` for rail, \`datagoodr-vintage.css\` for vintage.

## See also

\[create_dd()\], \[update_rg()\], \[use_datagoodr_template()\]
