# Generate Table of Properties

Generates needed properties for rg_properties column of the DGF. Used
inside R/01-00-CREATE-DGF.R

## Usage

``` r
get_properties(VNAME, df)
```

## Arguments

- VNAME:

  A character string specifying the name of the variable in the data
  frame. (From var_name column of the DGF)

- df:

  A data frame containing the variable to be visualized.

## Value

Data table as JSON text string needed to store in the DGF to later
generate the properties table when rendering the RG.

## Details

properties include number of rows and distinct values, most common
value, number of zero, empty cells, missing/NA cells, and cell with
infinite values
