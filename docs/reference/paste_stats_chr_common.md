# Print the most common strings of a character variable into the RG

Reads the most-common-values component of the character \`rg_stats\`
cell and prints a Value/Frequency table. Prints nothing if that
component is not present (e.g. a DGF generated before this element was
added).

## Usage

``` r
paste_stats_chr_common(VNAME, LABEL = "MOST COMMON")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"rg_stats"\`).

- LABEL:

  A character string for the section title. Defaults to \`"MOST
  COMMON"\`.

## Value

No return value; prints the table (or nothing) to the RG.
