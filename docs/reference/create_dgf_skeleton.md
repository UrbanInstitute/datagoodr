# Create an empty v2 DGF skeleton

Builds an empty Data Governance File: one row per variable, every schema
column present. \`create_dgf()\` populates it; call this directly only
to see the schema or build a DGF by hand.

## Usage

``` r
create_dgf_skeleton(varnames)
```

## Arguments

- varnames:

  Character vector of variable names from the raw source.

## Value

A data frame with one row per variable and every DGF column, all blank
except \`var_name\`.

## Details

Columns are grouped by prefix family — \`dd\_\`, \`raw\_\`,
\`stable\_\`, \`rg\_\`, \`validate\_\`, \`prov\_\`. The \`rg\_\*\`
columns are character (they hold JSON), not list-columns, so the DGF
survives an \`.xlsx\` round trip.

## See also

\[create_dgf()\], \[inspect_dgf()\]
