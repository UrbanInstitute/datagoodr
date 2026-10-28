# Print the logical CATEGORY LABELS transposed across a full-width row

Reads the level dictionary (\`dd_f_levels\`) and lays the categories out
horizontally: one column per level code, with an editable meaning
beneath each. The meaning row appears only once labels are customised.

## Usage

``` r
paste_levels_horizontal(VNAME, LABEL = "CATEGORY LABELS")
```

## Arguments

- VNAME:

  A character string naming the DGF column to read (the layout passes
  \`"dd_f_levels"\`).

- LABEL:

  A character string for the section title. Defaults to \`"CATEGORY
  LABELS"\`.

## Value

No return value; prints the table to the RG.
