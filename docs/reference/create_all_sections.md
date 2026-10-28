# Create sections for all variables in a DGF

Generates Quarto report sections for each variable in the provided DGF
object, using the layouts from \[get_design()\] and the content from
\[dgf_to_list()\].

## Usage

``` r
create_all_sections(dgf, style = c("rg", "dd"), layouts = NULL)
```

## Arguments

- dgf:

  the DGF as a data frame

- style:

  Either \`"rg"\` (research guide, full profile) or \`"dd"\` (data
  dictionary, descriptors only). Passed to \[get_design()\]. Defaults to
  \`"rg"\`.

- layouts:

  Optional named list of layout character vectors overriding the package
  defaults. Passed to \[get_design()\]. Defaults to \`NULL\`.

## Value

No return value; the function writes formatted Quarto content for each
variable to the output.

## Details

\- Converts the DGF data frame into a list of variables using
\[dgf_to_list()\]. - Retrieves the design layouts with
\[get_design()\]. - Iterates over each variable name, calling
\[create_section()\] to generate its report section.
