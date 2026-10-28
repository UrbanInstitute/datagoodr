# Generate Statistics Based on Variable Type

Generates needed graphics for rg_stats column of the DGF. Used inside
R/01-00-CREATE-DGF.R

## Usage

``` r
get_stats(VNAME, df, VCLASS)
```

## Arguments

- VNAME:

  A character string specifying the name of the variable in the data
  frame. (From var_name column of the DGF)

- df:

  A data frame containing the variable to be visualized.

- VCLASS:

  A character string indicating the class of the variable (e.g.,
  "numeric", "factor", "logical", or other).

## Value

Data table as JSON text string needed to store in the DGF to later
generate the appropriate plot when rendering the RG.

## Details

The function calls different helper functions based on \`VCLASS\`:

- \`"numeric"\`: Calls \`get_graphics_num(VNAME, df)\`

- \`"factor"\`: Calls \`get_graphics_fact(VNAME, df)\`

- \`"logical"\`: Calls \`get_graphics_log(VNAME, df)\`

- Other classes: Calls \`get_graphics_chr(VNAME, df)\`
