# Pick the Research Guide template for each variable

Returns the data type whose template (layout) renders each variable: one
of \`number\`, \`text\`, \`categorical\`, \`boolean\`, \`identifier\`,
\`temporal\`.

## Usage

``` r
dg_render_type(dgf)
```

## Arguments

- dgf:

  A DGF data frame, or a one-variable list (a row from
  \[dgf_to_list()\]).

## Value

A character vector, one value per variable.

## Details

Resolved in this order:

1\. the ontology data type of \`desired_semantic_type\` (looked up in
\`formex::fx_ontology()\`, using \`guess_variant_id\` to settle a
semantic type that sits under two data types). A data type name typed
directly into \`desired_semantic_type\` (e.g. \`"number"\`) is accepted
as is, and so is a formex path (\`"identifier:id:geographic"\`), whose
first segment names the data type. A semantic type listed under two data
types (\`geographic\`) that neither a path nor \`guess_variant_id\`
settles routes to \`"text"\` for now. This is the column to edit to move
a variable to another template; 2. the legacy \`desired_data_type\`
column (\`"string"\` is read as \`"text"\`), for DGFs built before the
v7 columns or rows with a blank or unknown semantic type; 3. \`"text"\`,
the fallback for structured and unknown types, blanks, and anything the
ontology does not know.

## See also

\[create_all_sections()\], \`dev/stabilization-workflow.md\`
