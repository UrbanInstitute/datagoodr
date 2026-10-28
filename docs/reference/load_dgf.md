# Load DGF from DGF Excel Sheet

This function reads DGF from an Excel file and returns the contents of
the "DGF" sheet as a data frame.

## Usage

``` r
load_dgf(filename = "DGF.xlsx", reader = c("openxlsx", "readxl"))
```

## Arguments

- filename:

  A character string specifying the name of the Excel file to read.
  Defaults to \`"DGF.xlsx"\`.

- reader:

  \`"openxlsx"\` (default; a data frame) or \`"readxl"\` (a tibble,
  which the Research Guide templates use). The two differ in how they
  type all-empty columns; see \`dev/TO-DO.md\`.

## Value

A data frame containing the data from the "DGF" sheet of the specified
Excel file. Cells that \[save_to_excel()\] moved to the \`DGF_overflow\`
sheet (over Excel's 32,767-character limit) are joined back.
