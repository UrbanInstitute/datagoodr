# Saves DGF to excel

Write the DGF to excel.

## Usage

``` r
save_to_excel(df, filename = "DGF.xlsx", open = interactive())
```

## Arguments

- df:

  Data frame to write.

- filename:

  Destination \`.xlsx\` path.

- open:

  Logical; launch the saved file in Excel. Defaults to
  \[interactive()\], so it stays off in scripts, tests, and CI.

## Details

Used by \[create_dgf()\], \[update_dgf()\] and \[create_rg()\]. Any cell
over Excel's 32,767-character limit (e.g. the graphics data of a date
column with thousands of distinct dates) is moved to a second sheet,
\`DGF_overflow\`, in parts, with a \`\<\<DGF_overflow\>\>\` pointer left
in the main sheet. \[load_dgf()\] joins the parts back, so the DGF
survives being opened and saved in Excel. Leave the \`DGF_overflow\`
sheet and the pointer cells as they are.
