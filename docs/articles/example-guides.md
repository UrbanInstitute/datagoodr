# Example Research Guides

Finished research guides, each built from a familiar dataset with a few
lines of code. Open one to see what
[`create_rg()`](https://urbaninstitute.github.io/datagoodr/reference/create_rg.md)
produces, then read the code below it to see how little it took.

| Guide | Data | What it shows |
|----|----|----|
| [Baseball players](https://urbaninstitute.github.io/datagoodr/examples/baseball.md) | `dg_baseball`, shipped with datagoodr | messy as-entered text: written dates, `$851,950` salaries, coded levels |
| [Star Wars characters](https://urbaninstitute.github.io/datagoodr/examples/starwars.md) | [`dplyr::starwars`](https://dplyr.tidyverse.org/reference/starwars.html) | list columns (films, vehicles) and missing values |
| [Motor Trend cars](https://urbaninstitute.github.io/datagoodr/examples/mtcars.md) | [`datasets::mtcars`](https://rdrr.io/r/datasets/mtcars.html) | a small numeric dataset with 0/1 codes retyped as true/false |
| [Baseball players, compact](https://urbaninstitute.github.io/datagoodr/examples/baseball-compact.md) | the baseball DGF again | the same guide in the `"compact"` style: same blocks, 35% shorter page |
| [Motor Trend cars, compact](https://urbaninstitute.github.io/datagoodr/examples/mtcars-compact.md) | the mtcars DGF again | the compact style’s boolean graphic — `vs` and `am` as one divided bar over a tenths scale |

The links open the guides on the package website; they are built by
`data-raw/example-guides.R` in the source repository.

## How a research guide is laid out

Every guide opens with a numbered contents list, then groups the
variables by data type (Boolean, Categorical, Numeric, Text, Identifier,
Temporal). Each variable is one unit:

- **Left rail** – its data mode and data type (in orange), its
  plain-language label, its name, its description, and a PROPERTIES
  table (rows, distinct values, missing, zeros).
- **Right column** – a graphic for its type (histogram, treemap, word
  cloud, true/false bars, calendar), a PREVIEW of its values, and its
  stats: quantiles and distribution shape for numbers, factor levels for
  categories, the most common values for text.

This is the default `"rail"` style. `create_rg(style = "compact")` draws
the same units condensed for documentation – the properties table
becomes a one-row strip above the graphic, the preview and the long
tables are kept short, and the whitespace is roughly halved. The
original three-column grid is still available as
`create_rg(style = "vintage")`.

## Baseball players

`dg_baseball` holds the 678 players who debuted in 2010-2014, with every
column exactly as it arrived. `dg_baseball_dictionary` supplies a label
and description for each column;
[`create_dgf()`](https://urbaninstitute.github.io/datagoodr/reference/create_dgf.md)
takes them through `dd_vlabel` and `dd_vdesc`.

``` r

library(datagoodr)

dd  <- dg_baseball_dictionary
dgf <- create_dgf(dg_baseball,
                  dd_vlabel = dd$label,
                  dd_vdesc  = dd$description,
                  dir = "baseball")
```

The `bats` and `throws` codes read better with their meanings. Level
labels live in the DGF’s `dd_f_levels` column (a level/label table),
which you can edit in Excel or set in code before rendering:

``` r

i <- match("bats", dgf$var_name)
dgf$dd_f_levels[i] <- jsonlite::toJSON(data.frame(
  level = c("R", "L", "B"),
  label = c("R (right)", "L (left)", "B (both)")))

create_rg(dgf, dir = "baseball", render = TRUE)
```

[Open the baseball
guide](https://urbaninstitute.github.io/datagoodr/examples/baseball.md)

The same DGF renders in any style, so publishing a condensed copy beside
the full one is one more call with a different file name:

``` r

create_rg(dgf, dir = "baseball", file = "baseball-compact.qmd",
          style = "compact", render = TRUE)
```

[Open the compact baseball
guide](https://urbaninstitute.github.io/datagoodr/examples/baseball-compact.md)
— same blocks, same order, a 35% shorter page. See
[`vignette("report-styles")`](https://urbaninstitute.github.io/datagoodr/articles/report-styles.md).

## Star Wars characters

No preparation at all:
[`create_dgf()`](https://urbaninstitute.github.io/datagoodr/reference/create_dgf.md)
collapses list columns such as `films` to `a|b|c` text and profiles the
rest.

``` r

dgf <- create_dgf(dplyr::starwars, dir = "starwars")
create_rg(dgf, dir = "starwars", render = TRUE)
```

[Open the Star Wars
guide](https://urbaninstitute.github.io/datagoodr/examples/starwars.md)

## Motor Trend cars

`mtcars` keeps the car names in its row names, so split them into `make`
and `model` first. Its `vs` and `am` columns are 0/1 codes that the type
guess reads as counts;
[`retype_dgf()`](https://urbaninstitute.github.io/datagoodr/reference/retype_dgf.md)
turns them into true/false variables, and level labels give the codes
their meaning.

``` r

cars <- data.frame(make  = sub(" .*", "", rownames(mtcars)),
                   model = sub("^\\S+ ?", "", rownames(mtcars)),
                   lapply(mtcars, as.character))

dgf <- create_dgf(cars, dir = "mtcars")
dgf <- retype_dgf(dgf, cars, types = c(vs = "boolean", am = "boolean"))

i <- match("am", dgf$var_name)
dgf$dd_f_levels[i] <- jsonlite::toJSON(data.frame(
  level = c("0", "1"), label = c("0 (automatic)", "1 (manual)")))

create_rg(dgf, dir = "mtcars", render = TRUE)
```

The full script, with labels and descriptions for every column, is
`data-raw/example-guides.R`.

[Open the Motor Trend
guide](https://urbaninstitute.github.io/datagoodr/examples/mtcars.md)
