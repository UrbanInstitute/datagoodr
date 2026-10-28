# Print the combined FACTOR LEVELS table into the RG

Joins the factor level frequencies (\`rg_stats\`) with the editable
level dictionary (\`dd_f_levels\`) into one table: Label \| Frequency \|
Meaning. The Meaning column is shown only when the labels have been
customised away from the raw level codes.

## Usage

``` r
paste_levels_freq(VNAME, LABEL = "FACTOR LEVELS")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"dd_f_levels"\`).

- LABEL:

  A character string for the section title. Defaults to \`"FACTOR
  LEVELS"\`.

## Value

No return value; prints the table to the RG.
