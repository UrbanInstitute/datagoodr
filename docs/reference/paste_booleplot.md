# Print the bar plot of a logical variable into the RG

Reads the \`rg_graphics\` column of the DGF and draws the logical value
counts with \[booleplot()\]: a fixed-geometry horizontal bar plot with
the category names in the left margin and each bar's count and share
(\`22.6K (90.4 its right. Categories are sorted largest-to-smallest with
the missing (\`NA\`) category last, drawn as a light bar with a
steel-blue outline.

## Usage

``` r
paste_booleplot(VNAME, LABEL = "VALUES")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_graphics"\`).

- LABEL:

  A character string for the section title. Defaults to \`"VALUES"\`.

## Value

No return value; draws the bar plot into the RG.

## Details

Internal to \`create_div\` in R/03-01-create-sections.R.
