# Rebuild a DGF from a stable CSV read

Reconstructs the portable DGF that was embedded in a stable CSV by
\[write_stable_csv()\].

## Usage

``` r
dgf_from_stable(x)
```

## Arguments

- x:

  The result of \[read_stable_csv()\], or a path to a stable CSV.

## Value

The embedded DGF as a data frame (portable families only - no
\`rg\_\*\`), or \`NULL\` if the file carries no DGF payload.

## See also

\[read_stable_csv()\], \[write_stable_csv()\]
