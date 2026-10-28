# Print the level dictionary of a factor/logical variable into the RG

Reads the \`dd_f_levels\` column of the DGF (a JSON table of level codes
and their editable labels) and prints it as a two-column LEVELS table.

## Usage

``` r
paste_levels(VNAME, LABEL = "CATEGORY MEANING")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"dd_f_levels"\`).

- LABEL:

  A character string for the section title. Defaults to \`"LEVELS"\`.

## Value

No return value; prints the LEVELS table to the RG. Nothing is printed
when the variable has no levels.

## Details

Internal to [create_div](create_div.md) in R/03-01-create-sections.R.
The table is capped at the first 50 levels.
