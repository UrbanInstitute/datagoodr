# Print the histogram of a numeric variable into the RG

Reads the \`rg_graphics\` column of the DGF and draws a clean, axis-free
histogram of the winsorized distribution, with the true min/max
abbreviated at the lower corners and mean/median marked (labels on top).
A dominant spike (e.g. a pile of zeros) is capped so the rest of the
shape stays visible, and mean/median lines are clamped to the plot so an
outlier mean pins to the edge to signal skew.

## Usage

``` r
paste_histogram(VNAME, LABEL = "HISTOGRAM")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_graphics"\`).

- LABEL:

  A character string for the section title. Defaults to \`"HISTOGRAM"\`.

## Value

No return value; draws the histogram into the RG.

## Details

Internal to \`create_div\` in R/03-01-create-sections.R.
