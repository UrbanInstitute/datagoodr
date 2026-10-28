# Write a data frame to a stable CSV with embedded provenance

Writes a CSV that carries its own metadata embedded across the data rows
(no sidecar): named \`payloads\`, and - when a \`dgf\` is supplied - the
DGF's portable contract plus a provenance record. See
\[read_stable_csv()\] to recover them and \[dgf_from_stable()\] to
rebuild the DGF.

## Usage

``` r
write_stable_csv(
  df,
  path,
  payloads = list(),
  dgf = NULL,
  start_hash = NULL,
  replication = list(),
  chunk_limit = DGF_CHUNK_CHAR_LIMIT
)
```

## Arguments

- df:

  Data frame to write (typically the output of \[stabilize_data()\]).

- path:

  Output file path.

- payloads:

  Named list of extra R objects to embed. Defaults to none.

- dgf:

  Optional DGF to embed. Its portable families (\`dd\_\`/\`raw\_\`/
  \`stable\_\`/\`validate\_\`/\`prov\_\`) are stored; \`rg\_\*\` is
  excluded, since those are R-native artifacts meaningless to another
  program. A \`provenance\` payload is derived automatically.

- start_hash:

  Optional named list of the parent file's per-column \`current_hash\`,
  to chain lineage. When omitted, \`dgf\`'s \`prov_start_hash\` column
  is used if present.

- replication:

  Optional per-payload replication factors (default 2x).

- chunk_limit:

  Max characters per embedded chunk.

## Value

Invisibly, \`path\`.

## Details

With \`dgf\`, two payloads are added: \`dgf\` (the portable subset, as
records) and \`provenance\` (\`dgf_version\`, \`created\`,
\`start_hash\`, \`current_hash\` = per-column hashes of \`df\`). The
provenance payload seeds the tier-1 core stamp, so version and lineage
survive on every row.

## See also

\[read_stable_csv()\], \[dgf_from_stable()\], \[stabilize_data()\]
