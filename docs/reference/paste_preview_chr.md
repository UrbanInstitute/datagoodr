# Print Preview of a Character Variable into RG

Reads the rg_preview column of the DGF and prints the example values as
a wrapped text block (see \[wrap_preview()\]).

## Usage

``` r
paste_preview_chr(VNAME, LABEL = "PREVIEW", size = 68)
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_preview"\`).

- LABEL:

  A character string for the section title. Defaults to \`"PREVIEW"\`.

- size:

  Maximum line width, in characters. Defaults to \`80\`.

## Value

No return value; prints the preview block to the RG.

## Details

Internal to \`create_div\` in R/03-01-create-sections.R.
