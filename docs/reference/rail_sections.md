# Print one data-type group of the research guide

Writes the group's header band, then one unit per variable: a left rail
with the data type, label, name, description and PROPERTIES table, and a
right column with the graphic, PREVIEW and stats tables. Call inside a
\`results = "asis"\` chunk; set the chunk's \`fig.width\`/\`fig.height\`
for the group's graphic.

## Usage

``` r
rail_sections(dgf, title, layouts = NULL)
```

## Arguments

- dgf:

  A DGF subset (one element of \[rail_groups()\]). Nothing is printed
  when it has no rows.

- title:

  The group's header text, e.g. \`"Numeric"\`. Also its anchor
  (lower-cased), which \[rail_contents()\] links to.

- layouts:

  Optional named list of layout vectors overriding the package defaults;
  passed to \[get_design()\].

## Value

No return value; prints markdown.

## See also

\[rail_contents()\], \[create_all_sections()\] for the vintage grid
