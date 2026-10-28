# Return the datagoodr report stylesheet

Reads a report stylesheet from the package's templates. The report
templates emit it inside a \`\<style\>\` block, so one file drives the
look of every report of that style. To restyle, edit the project's local
copy (or add overriding rules in your project \`.qmd\`).

## Usage

``` r
datagoodr_css(style = NULL)
```

## Arguments

- style:

  Which stylesheet: \* \`"rail"\` - the default research guide
  (\`datagoodr.css\`). \* \`"vintage"\` - the original three-column
  grid, used by \`create_rg(style = "vintage")\` and by the data
  dictionary (\`datagoodr-vintage.css\`). \* \`NULL\` (the default) -
  the behavior before styles existed: a local \`datagoodr.css\` if there
  is one, else the vintage stylesheet. This keeps report documents
  scaffolded by earlier versions, which call \`datagoodr_css()\` with no
  argument, rendering as they always have.

## Value

A single character string of CSS (empty if no stylesheet is found).

## Details

A project-local copy in the render directory takes precedence over the
packaged one, so a scaffolded project can be restyled by editing its own
copy: \`datagoodr.css\` for rail, \`datagoodr-vintage.css\` for vintage.
A local \`datagoodr.css\` that is not a rail stylesheet (an older
project's copy of the vintage one) is skipped for \`"rail"\`, so it
cannot break a new rail guide, and still serves \`"vintage"\` when no
\`datagoodr-vintage.css\` exists.
