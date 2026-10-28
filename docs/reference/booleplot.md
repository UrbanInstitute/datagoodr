# Draw a compact horizontal bar plot with consistent bar geometry

A horizontal count bar plot whose bar thickness is a fixed multiple of
the label text height, so the graphic reads the same regardless of how
many categories it has (two-value flags no longer render as fat slabs).
Category names sit in the left margin; each bar is labelled to its right
with its count and share (e.g. \`22.6K (90.4 table travels inside the
plot. Categories are sorted largest-to-smallest with the missing
(\`NA\`) category always pushed last and drawn as a light bar with a
steel-blue outline, so missingness reads as a gap rather than a value.

## Usage

``` r
booleplot(
  x,
  bar_text_ratio = 2,
  gap_ratio = 1/3,
  bar_col = "#465A6F",
  na_col = "#d7e0e8",
  na_border = "#465A6F",
  na_lty = 1,
  na_lwd = 1.3,
  na_label = "NA",
  cex.names = 1.8,
  cex.value = 1.4,
  value_col = "gray30",
  x_pad = 0.03,
  plot_height_inches = NULL,
  mar = c(0, 6, 0, 1.5),
  ...
)
```

## Arguments

- x:

  A named numeric vector (or one-way \`table\`) of non-negative counts;
  the names are the category labels.

- bar_text_ratio:

  Target bar thickness as a multiple of the label text height. Defaults
  to \`3\`.

- gap_ratio:

  Gap between bars as a fraction of bar height. Defaults to \`1/3\`.

- bar_col:

  Fill for ordinary bars. Defaults to \`"#465A6F"\`, the slate of the
  histogram bars.

- na_col, na_border, na_lty, na_lwd:

  Fill, border colour, line type and line width for the missing (\`NA\`)
  bar.

- na_label:

  The label treated as the missing category. Defaults to \`"NA"\`.

- cex.names, cex.value:

  Text scaling for the category names (left) and the count/share labels
  (right).

- value_col:

  Colour of the count/share labels. Defaults to \`"gray30"\`.

- x_pad:

  Fractional padding added past the longest bar. Defaults to \`0.03\`.

- plot_height_inches:

  Device plot height used to size the bars. Defaults to the actual
  device height (\`par("pin")\[2\]\`), which is what keeps the bar
  thickness consistent across variables.

- mar:

  Plot margins (bottom, left, top, right). The left margin holds the
  category names. Defaults to \`c(0, 4.5, 0, 0.5)\`.

- ...:

  Passed to \[graphics::rect()\].

## Value

Invisibly, a list describing the geometry actually used.
