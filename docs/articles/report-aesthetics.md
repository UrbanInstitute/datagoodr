# Report Aesthetics and Customization

The look of a Research Guide is not hard-coded — it is driven by a
**design**: a setting that maps each data type to the sequence of
reporting functions used to render it. Because the design is data, you
can inspect it, and change it, without touching the package.

## The design is a table of data type → reporting function

[`get_design()`](https://urbaninstitute.github.io/datagoodr/reference/get_design.md)
returns the active design as a data frame. Each row places one piece of
a variable’s section:

``` r

library(datagoodr)
d <- get_design()
head(d)
```

    #>     TYPE  DIV            VNAME       LABEL FUNCTION
    #> 1 number div2        dd_vlabel             v_to_txt
    #> 2 number div3   dg_render_type   DATA MODE v_to_txt
    #> 3 number div3 dg_semantic_type   DATA TYPE v_to_txt
    #> 4 number div3     dd_data_unit        UNIT v_to_txt
    #> 5 number div3       rg_max_chr   MAX NCHAR v_to_txt
    #> 6 number div4         dd_vdesc DESCRIPTION v_to_txt

The columns are the whole grammar:

- **TYPE** — the data type the row applies to (`number`, `categorical`,
  `boolean`, `temporal`, `text`, `identifier`).
- **DIV** — the slot in the section grid the piece is drawn into.
- **VNAME** — the DGF column the piece reads (`rg_stats`, `rg_graphics`,
  `dd_vdesc`, …).
- **LABEL** — the heading shown above it.
- **FUNCTION** — the **name of the reporting function** that renders
  that column.

Here is the full recipe for a **numeric** variable — the mapping that
produced the histogram and tables you saw in the other vignettes:

``` r

d[d$TYPE == "number", c("DIV", "VNAME", "LABEL", "FUNCTION")]
```

    #>     DIV            VNAME              LABEL                 FUNCTION
    #> 1  div2        dd_vlabel                                    v_to_txt
    #> 2  div3   dg_render_type          DATA MODE                 v_to_txt
    #> 3  div3 dg_semantic_type          DATA TYPE                 v_to_txt
    #> 4  div3     dd_data_unit               UNIT                 v_to_txt
    #> 5  div3       rg_max_chr          MAX NCHAR                 v_to_txt
    #> 6  div4         dd_vdesc        DESCRIPTION                 v_to_txt
    #> 7  div5       rg_preview            PREVIEW              paste_label
    #> 8  div6       rg_preview                           paste_preview_num
    #> 9  div7    rg_properties         PROPERTIES         paste_properties
    #> 10 div8      rg_graphics                             paste_histogram
    #> 11 div9         rg_stats              STATS   paste_stats_horizontal
    #> 12 div9         rg_stats DISTRIBUTION SHAPE paste_distribution_shape

Read the last two rows: in slot `div8`, the `rg_graphics` column is
rendered by `paste_histogram`; in `div9`, `rg_stats` is rendered by
`paste_stats_horizontal`. Swap the type and the functions change — a
`categorical` row sends `rg_graphics` to `paste_treemap`, a `text` row
to `v_to_wordcloud`.

## How the mapping is parsed and applied

Internally each layout is written as a compact string,
`"div ;; column ;; LABEL ;; function"`, and two helpers turn it into
action:

- [`parse_design()`](https://urbaninstitute.github.io/datagoodr/reference/parse_design.md)
  splits those strings into the `DIV / VNAME / LABEL / FUNCTION` data
  frame above;
- at render time the **FUNCTION name is looked up and called** on the
  named DGF column
  ([`parse_functions()`](https://urbaninstitute.github.io/datagoodr/reference/parse_functions.md)
  first checks every name resolves, so a typo fails loudly instead of
  rendering nothing).

So “aesthetics” reduces to a lookup: *for this type, draw this column,
with this function.* Change the lookup and you change the report.

## Customizing: change the functions, or change the mapping

**1. Override a reporting function.** Because the design stores a
function *name*, defining your own function of that name makes the guide
call yours — no change to the mapping. This is the usual way to restyle:
redefine a renderer (or a formatter such as `dollarize`) in your
project’s `DG.R`.

``` r

# in DG.R — restyle the numeric graphic without touching the design:
paste_histogram <- function(VNAME, LABEL = "HISTOGRAM") {
  # ... your own plot from the rg_graphics payload ...
}
```

**2. Change the mapping itself.** Pass a replacement layout to
[`get_design()`](https://urbaninstitute.github.io/datagoodr/reference/get_design.md)
(the same hook
[`create_rg()`](https://urbaninstitute.github.io/datagoodr/reference/create_rg.md)’s
scaffold uses). Here is a slimmed numeric section — label, properties,
and stats only, no histogram:

``` r

custom_number <- c(
  "div2 ;; dd_vlabel     ;;            ;; v_to_txt",
  "div7 ;; rg_properties ;; PROPERTIES ;; paste_properties",
  "div9 ;; rg_stats      ;; STATS      ;; paste_stats_horizontal"
)
d2 <- get_design(layouts = list(number = custom_number))
d2[d2$TYPE == "number", c("DIV", "VNAME", "LABEL", "FUNCTION")]
```

    #>    DIV         VNAME      LABEL               FUNCTION
    #> 1 div2     dd_vlabel                          v_to_txt
    #> 2 div7 rg_properties PROPERTIES       paste_properties
    #> 3 div9      rg_stats      STATS paste_stats_horizontal

The numeric section is now three rows instead of nine, and the histogram
is gone. You can drop sections, reorder them, relabel them, or point a
slot at a different function — all by editing the character vector.

**3. Shadow a layout globally.** Defining `layout.numeric` (or
`layout.character`, `layout.logical`, …) in your session or `DG.R`
shadows the package default for that type, so every guide you render
picks it up without passing `layouts` each time.

## Density is a style, not a layout

`create_rg(style = "compact")` is the same design drawn shorter. Its
layouts differ from the defaults in only two rows — PROPERTIES is
transposed into a one-row strip, and the numeric DISTRIBUTION SHAPE
block goes, since skew and kurtosis are already drawn above the
histogram:

``` r

cp <- get_design(compact = TRUE)
cp[cp$TYPE == "number", c("DIV", "VNAME", "LABEL", "FUNCTION")]
```

    #>     DIV            VNAME       LABEL                    FUNCTION
    #> 1  div2        dd_vlabel                                v_to_txt
    #> 2  div3   dg_render_type   DATA MODE                    v_to_txt
    #> 3  div3 dg_semantic_type   DATA TYPE                    v_to_txt
    #> 4  div3     dd_data_unit        UNIT                    v_to_txt
    #> 5  div3       rg_max_chr   MAX NCHAR                    v_to_txt
    #> 6  div4         dd_vdesc DESCRIPTION                    v_to_txt
    #> 7  div5       rg_preview     PREVIEW                 paste_label
    #> 8  div6       rg_preview                       paste_preview_num
    #> 9  div7    rg_properties             paste_properties_horizontal
    #> 10 div8      rg_graphics                         paste_histogram
    #> 11 div9         rg_stats       STATS      paste_stats_horizontal

How *long* each block is does not live in the design at all. A reporting
function can declare `size` (characters per line), `max.lines` (preview
rows) or `max.rows` (table rows), and the renderer hands it the active
style’s values — so the one `paste_levels_freq` row above lists 8 factor
levels in a compact guide and 50 in the default one. Write your own
renderer with those arguments and it condenses with the rest:

``` r

# in DG.R - a renderer that respects the guide's density
paste_levels_freq <- function(VNAME, LABEL = "FACTOR LEVELS", max.rows = 50) {
  # ... your own table, trimmed to max.rows ...
}
```

The third lever is the document: `RG-compact.qmd` sets a smaller
`fig.height` per group, and `datagoodr-compact.css` halves the spacing.
Both are yours to edit in a scaffolded project.
[`vignette("report-styles")`](https://urbaninstitute.github.io/datagoodr/articles/report-styles.md)
compares the styles and shows how to switch between them.

## Where this fits

[`create_rg()`](https://urbaninstitute.github.io/datagoodr/reference/create_rg.md)
scaffolds a project with a `DG.R` precisely so these overrides live
*beside* your data, not in the package — the design travels with the
project and the package stays untouched. For the functions a design
points at, see *Data Reporting Functions*.
