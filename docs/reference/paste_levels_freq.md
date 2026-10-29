# Print the combined FACTOR LEVELS table into the RG

Joins the factor level frequencies (\`rg_stats\`) with the editable
level dictionary (\`dd_f_levels\`) into one table: Label \| Frequency \|
Meaning. The Meaning column is shown only when the labels have been
customised away from the raw level codes.

## Usage

``` r
paste_levels_freq(VNAME, LABEL = "FACTOR LEVELS", max.rows = 50)
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"dd_f_levels"\`).

- LABEL:

  A character string for the section title. Defaults to \`"FACTOR
  LEVELS"\`.

- max.rows:

  Most levels to list. The rest are summarised as a "+ N more levels"
  line rather than dropped silently. Defaults to \`50\`; the compact
  guide passes a much smaller number (see \`.rail_knobs\`).

## Value

No return value; prints the table to the RG.
