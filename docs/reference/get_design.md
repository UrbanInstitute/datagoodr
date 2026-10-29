# Compile the section design for each variable type

Parses the layout objects with \[parse_design()\] and combines them into
a single design data frame with a \`TYPE\` column. By default the
package's layout objects are used; a QMD template or \`DG.R\` can supply
its own via \`layouts\`.

## Usage

``` r
get_design(style = c("rg", "dd"), layouts = NULL, compact = FALSE)
```

## Arguments

- style:

  Either \`"rg"\` (research guide — the full data profile) or \`"dd"\`
  (data dictionary — only the text descriptors and the factor level
  table). Defaults to \`"rg"\`.

- layouts:

  Optional named list of layout character vectors
  (\`numeric\`/\`character\`/\`factor\`/\`logical\`) that overrides the
  package defaults. Defaults to \`NULL\`.

- compact:

  Logical; use the condensed layouts behind \`create_rg(style =
  "compact")\` as the defaults instead of the standard ones. Defaults to
  \`FALSE\`. A \`layout.\*\` override in the global environment still
  wins either way, and an explicit \`layouts\` list ignores this.

## Value

A data frame containing the compiled layout design with columns
\`TYPE\`, \`DIV\`, \`VNAME\`, \`LABEL\`, and \`FUNCTION\`.

## Details

Used in
[create_all_sections](https://urbaninstitute.github.io/datagoodr/reference/create_all_sections.md)

## See also

\[parse_design()\]
