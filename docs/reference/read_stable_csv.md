# Read a stable CSV, recovering data and embedded provenance

Reads a CSV written by \[write_stable_csv()\], returning the data plus
the embedded metadata, and flagging two distinct integrity problems.

## Usage

``` r
read_stable_csv(path)
```

## Arguments

- path:

  Path to a stable CSV. A plain, never-governed CSV is read too - it
  just returns empty metadata.

## Value

A list with:

- \`data\`:

  the data frame, with metadata columns removed

- \`stamp\`:

  the tier-1 core stamp (version, hash summary, manifest)

- \`stamp_consistent\`:

  \`TRUE\` if every row's stamp agreed

- \`meta\`:

  the recovered payloads, named

- \`missing\`:

  payloads every copy of which is gone (data loss)

- \`mismatch\`:

  payloads whose surviving copies disagree (possible tampering; a
  best-effort value is still returned)

## See also

\[write_stable_csv()\]
