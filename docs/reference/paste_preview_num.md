# Print Preview of a Numeric Variable into RG

Reads the rg_preview column of the DGF and prints the example values as
a wrapped text block (see \[wrap_preview()\]).

## Usage

``` r
paste_preview_num(
  VNAME,
  LABEL = "PREVIEW",
  size = 68,
  max.lines = 4,
  digits = 3
)
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_preview"\`).

- LABEL:

  A character string for the section title. Defaults to \`"PREVIEW"\`.

- size:

  Maximum line width, in characters. Defaults to \`68\`.

- max.lines:

  Maximum wrapped rows to print, which is what keeps the preview to a
  short strip. Defaults to \`4\`; the compact guide passes fewer (see
  \`.rail_knobs\`).

- digits:

  Decimal places kept for long decimals, so \`0.3333333333\` shows as
  \`0.333\`. Shorter numbers are shown as stored. \`NULL\` turns
  rounding off. Defaults to \`3\`.

## Value

No return value; prints the preview block to the RG.

## Details

Internal to \`create_div\` in R/03-01-create-sections.R.
