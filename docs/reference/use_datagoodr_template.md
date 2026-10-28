# Copy a datagoodr report template into a project

Installs one of the package's Quarto templates (research guide or data
dictionary) into a directory, along with a starter \`DG.R\`
customization file, so it can be edited and rendered locally.

## Usage

``` r
use_datagoodr_template(
  dir = ".",
  flavor = c("rg", "dd"),
  dg = TRUE,
  overwrite = FALSE,
  file = NULL,
  style = c("rail", "vintage")
)
```

## Arguments

- dir:

  Directory to write into. Created if it does not exist. Defaults to the
  current working directory.

- flavor:

  \`"rg"\` for the research guide (full data profile) or \`"dd"\` for
  the data dictionary (descriptors only). Defaults to \`"rg"\`.

- dg:

  Logical; also copy a starter \`DG.R\` if one is not already present.
  Defaults to \`TRUE\`.

- overwrite:

  Logical; overwrite an existing \`.qmd\` of the same name. Defaults to
  \`FALSE\`.

- file:

  Optional name for the copied document. Defaults to the flavor's
  standard name (\`research-guide.qmd\` / \`data-dictionary.qmd\`). The
  template is written straight to this name, so the overwrite guard
  applies to the file you actually asked for — naming one report never
  touches another.

- style:

  Research guide style: \`"rail"\` (the default) or \`"vintage"\` (the
  original three-column grid). Ignored for the data dictionary, which
  always uses the vintage grid.

## Value

Invisibly, the path to the copied template.

## See also

\[create_rg()\], \[create_dd()\]
