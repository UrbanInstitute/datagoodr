# Ingest a raw dataset using DGF rules (Step 2, work in progress)

Orchestrates the Step 2 ingest workflow: sources a project \`dgf.R\`
rules file, then applies the DGF's variable-name aliases (and, once
implemented, type-conversion and standardization rules) to the raw data
frame.

## Usage

``` r
ingest_raw(df, path = NULL)
```

## Arguments

- df:

  A data frame of raw data to ingest.

- path:

  Directory containing the project \`dgf.R\` rules file. Defaults to
  \`NULL\`, which uses the current working directory.

## Value

A data frame with DGF rules applied.

## Details

This function is part of the not-yet-operational Step 2 pipeline;
several steps remain stubbed out.
