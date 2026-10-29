# Print a boolean variable's divided bar into the RG

Reads the \`rg_graphics\` column of the DGF and draws the category
counts with \[boolebar()\]: one full-width bar split into TRUE / FALSE /
NA parts, each carrying its count and share, over a tenths scale. The
compact guide's boolean graphic; the default guide uses
\[paste_booleplot()\].

## Usage

``` r
paste_boolebar(VNAME, LABEL = "VALUES")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_graphics"\`).

- LABEL:

  A character string for the section title. Defaults to \`"VALUES"\`.

## Value

No return value; draws the bar into the RG.

## See also

\[paste_booleplot()\], \[boolebar()\]
