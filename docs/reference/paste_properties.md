# Print Properties of a Variable into RG

Read rg_properties column of DGF and print properties in a table in the
RG

## Usage

``` r
paste_properties(VNAME, LABEL = "PROPERTIES")
```

## Arguments

- VNAME:

  A character string specifying the name of the variable whose
  properties are to be displayed.

- LABEL:

  A character string (from layout.TYPE object) for the section title.
  Defaults to \`"PROPERTIES"\`.

## Value

This function does not return a value; it prints the formatted table to
the RG as html code

## Details

The function is an internal function of [create_div](create_div.md) in
R/03-01-create-sections.R.
