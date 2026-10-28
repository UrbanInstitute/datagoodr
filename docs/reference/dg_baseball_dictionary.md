# Data dictionary for the baseball test dataset

One row per column of \[dg_baseball\]: a short label and a description,
ready for the \`dd_vlabel\` and \`dd_vdesc\` arguments of
\[create_dgf()\].

## Usage

``` r
dg_baseball_dictionary
```

## Format

A data frame with 19 rows and 3 character variables:

- variable:

  column name in \[dg_baseball\], in the same order.

- label:

  short plain-language label, e.g. \`"batting average"\`.

- description:

  one-sentence description.

## Source

Built by \`data-raw/dg_baseball.R\` from
\`data-dev/bb-data-dictionary.csv\`.

## See also

\[dg_baseball\]
