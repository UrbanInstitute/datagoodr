# Record what produced this report

Emits a provenance record for the current render: which DGF was used and
its content hash, the datagoodr/R/quarto versions, and when it ran. Call
it from a \`results = "asis"\` chunk in a report document.

## Usage

``` r
render_record(
  dgf,
  dgf_file = NULL,
  data_file = NULL,
  visible = FALSE,
  identify = FALSE
)
```

## Arguments

- dgf:

  The DGF data frame the report was rendered from.

- dgf_file:

  Path to the DGF, as the document received it (e.g.
  \`params\$dgf_file\`). Optional.

- data_file:

  Path to the raw dataset, if one was supplied (e.g.
  \`params\$data_file\`). Optional.

- visible:

  Logical; also print the record as a table in the report. Defaults to
  \`FALSE\`, which emits it only as an HTML comment.

- identify:

  Logical; add the username, hostname, and absolute paths. Defaults to
  \`FALSE\`. See Details.

## Value

Invisibly, the record as a named list. Called for the side effect of
printing.

## Details

Written as an HTML comment - \`\<!– datagoodr-render-record ... –\>\`
carrying JSON - so it travels with the file, survives \`embed-resources:
true\`, and can be recovered later without appearing in the report. Set
\`visible = TRUE\` to also show it as a table.

\`identify = FALSE\` by default because a Research Guide is meant to be
shared: the username and absolute paths would be shipped to every
recipient. The default record still answers "which DGF produced this?"
via \`dgf_hash\`, which is computed from the DGF's contents - not from
the file's bytes, which change on every re-save because .xlsx embeds
timestamps.

\`dgf_hash\` describes the DGF \*as the report loaded it\*. Compare it
across renders of the same document to see whether the DGF changed; it
is not a checksum of the .xlsx and is not comparable across different
readers.

## See also

\[read_render_record()\], to recover a record from a rendered file.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a report chunk:
render_record( dgf, params$dgf_file, params$data_file )

# show it in the report as well
render_record( dgf, params$dgf_file, visible = TRUE )

# internal render where the audit trail matters more than the leak
render_record( dgf, params$dgf_file, identify = TRUE )
} # }
```
