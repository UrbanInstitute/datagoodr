# Baseball players: a messy test dataset

Career records for the 678 major league players whose first appearance
(debut) fell in 2010-2014. Every column is text exactly as it arrived -
written and ISO dates, dollar-formatted salaries, \`R\`/\`L\`/\`B\`
codes, and non-US birthplaces in \`birthState\` - so typing and
stabilizing have real work to do. Pair it with
\[dg_baseball_dictionary\] for labels and descriptions;
\`vignette("example-guides")\` builds a research guide from it.

## Usage

``` r
dg_baseball
```

## Format

A data frame with 678 rows and 19 character variables:

- nameFirst, nameLast:

  player's first and last name.

- birthDate:

  date of birth, written \`Mon DD, YYYY\`.

- birthYear, birthMonth:

  year and month (\`Mon\`) of birth.

- birthState, birthCity:

  place of birth: a US state code or a region name elsewhere, and a
  city.

- weight, height:

  weight in pounds and height in inches.

- bats, throws:

  batting side (\`R\`/\`L\`/\`B\`) and throwing hand (\`R\`/\`L\`).

- debut, finalGame:

  dates of first and last appearance, \`YYYY-MM-DD\`.

- G, AB, H:

  career games, at bats and hits.

- AVG, SLUG:

  career batting average and slugging percentage; blank with no recorded
  at bats.

- salary:

  salary, written \`\$851,950\`.

## Source

A subset of the baseball test file \`data-dev/bb.csv\` in the datagoodr
source repository; built by \`data-raw/dg_baseball.R\`.

## See also

\[dg_baseball_dictionary\]
