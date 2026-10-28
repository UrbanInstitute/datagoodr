# Print Graphics of a Factor Variable into RG

Read rg_graphics column of DGF and print treemap in the RG

## Usage

``` r
paste_treemap(VNAME, LABEL = "MOST COMMON VALUES")
```

## Arguments

- VNAME:

  A character string specifying the name of the variable whose
  properties are to be displayed.

- LABEL:

  A character string (from layout.TYPE object) for the section title.
  Defaults to \`"MOST COMMON VALUES"\`.

## Value

This function does not return a value; it prints the formatted treemap
to the RG

## Details

The function is an internal function of \`create_div\` in
R/03-01-create-sections.R.
