# Report Styles

One DGF can be published in more than one shape. The **style** decides
how much room a variable gets on the page; the **design** decides which
blocks it gets at all (see
[`vignette("report-aesthetics")`](https://urbaninstitute.github.io/datagoodr/articles/report-aesthetics.md)).
This article is about the first.

Every style opens with the same contents list, and every row of it
glimpses the variable’s data — the first values as the stabilizer will
write them, or the preview sample where no stabilizer runs.
`rail_contents(glimpse = )` sets how many characters it may use, or `0`
leaves the data out.

## The three styles

| Style | `create_rg(style = )` | For |
|----|----|----|
| **Rail** (default) | `"rail"` | Reading a dataset for the first time. One variable per screen: a left rail with its type, label, name and description, beside its graphic, preview and stats. |
| **Compact** | `"compact"` | Documentation. The same blocks condensed — several variables per screen. |
| **Vintage** | `"vintage"` | The original three-column grid, kept so guides built with it still render. |

Compare the same dataset in the first two:
[baseball](https://urbaninstitute.github.io/datagoodr/examples/baseball.md)
and [baseball,
compact](https://urbaninstitute.github.io/datagoodr/examples/baseball-compact.md).

## Switching

The style is chosen when the document is scaffolded, because it picks
three things at once: the template, its stylesheet, and the figure sizes
the graphics are drawn at.

``` r

library(datagoodr)

create_rg(dgf)                       # rail, the default
create_rg(dgf, style = "compact")    # same guide, documentation density
create_rg(dgf, style = "vintage")    # the original grid
```

Each writes a `.qmd` plus its own stylesheet next to it —
`datagoodr.css`, `datagoodr-compact.css`, `datagoodr-vintage.css` — so a
project can be restyled by editing its own copy without touching the
package.

To publish a dataset in two styles at once, scaffold two documents and
give them different names. Both read the same DGF, so there is still one
source of truth:

``` r

create_rg(dgf, file = "research-guide.qmd")
create_rg(dgf, file = "research-guide-compact.qmd", style = "compact")
```

Changing the style of a guide you have already annotated means
scaffolding the new one beside it rather than converting in place —
[`update_rg()`](https://urbaninstitute.github.io/datagoodr/reference/update_rg.md)
re-renders an existing document against a different DGF, but it does not
restyle it.

## What compact actually changes

Nothing is left out: the same blocks appear in the same order, for the
same types. What changes is how much page each one takes.

- **PROPERTIES is transposed** into a one-row strip at the top of the
  body (`ROWS DISTINCT MISSING/NA`) instead of a vertical table in the
  rail. In the rail that table is what set a variable’s height, so
  condensing anything else first would have shortened nothing.
- **Booleans are drawn as one divided bar**
  ([`boolebar()`](https://urbaninstitute.github.io/datagoodr/reference/boolebar.md))
  rather than a stack of one bar per category: the parts share a length,
  over a tenths scale, so they read as shares of a whole — which is what
  a boolean is.
- **The long tables and the preview are kept short** — 8 factor levels
  instead of 50, 2 preview lines instead of 4. A truncated table says
  what it left out (`+ 444 more levels`) rather than stopping silently.
- **The numeric DISTRIBUTION SHAPE block goes**, since skew and kurtosis
  are already drawn above the histogram.
- **Graphics are drawn smaller** and the whitespace is roughly halved.

On the baseball guide that is a 35% shorter page.

## Density is a knob, not a rewrite

Compact is the rail renderer at a higher density, so everything that
customizes a rail guide works on it unchanged: a renderer you redefine
in `DG.R`, a `layout.*` shadow, your own stylesheet. Its design is
readable the same way as any other:

``` r

get_design(compact = TRUE)
```

A reporting function opts into the style’s density by declaring `size`
(characters per line), `max.lines` (preview rows) or `max.rows` (table
rows). The renderer fills them in from the active style, so the same
layout row prints 8 levels in a compact guide and 50 in the default one
— and your own renderer condenses with the rest if it takes the same
arguments:

``` r

# in DG.R - a renderer that respects the guide's density
paste_levels_freq <- function(VNAME, LABEL = "FACTOR LEVELS", max.rows = 50) {
  # ... your own table, trimmed to max.rows ...
}
```

## Mixing styles in one document

[`rail_sections()`](https://urbaninstitute.github.io/datagoodr/reference/rail_sections.md)
takes the style per call, so a document can draw the groups that deserve
room at full size and the rest condensed — for example a guide whose
numeric variables are the point and whose identifiers are just
inventory:

``` r

groups <- rail_groups(dgf)
rail_sections(groups$Numeric,    "Numeric")                      # full size
rail_sections(groups$Identifier, "Identifier", style = "compact") # condensed
```

Use the stylesheet of the style that dominates the document; the two
share all their structure, so either one renders both.
