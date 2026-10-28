# Read dates/datetimes written in a compact format

Ingests values written in the format named by \`format\` and returns
them typed. When the format carries separators the parse is
delimiter-agnostic: ordinal suffixes (\`4th\`) are stripped and any run
of non-alphanumeric characters is normalized, so \`mm/dd/yyyy\`,
\`mm-dd-yyyy\` and \`mm dd yyyy\` all read under the single label
\`mmddyyyy\`. When the format carries none (\`yyyymmdd\`), the
run-together form is read as written.

## Usage

``` r
read_date(x, format, tz = "UTC")

read_datetime(x, format, tz = "UTC")

read_yyyymmdd(x)

read_mmddyyyy(x)

read_ddmmyyyy(x)

read_mdyyyy(x)

read_dMyyyy(x)

read_Mdyyyy(x)

read_yyyymmddHHiiss(x)

read_mmddyyyyhhiiA(x)
```

## Arguments

- x:

  A character vector of date/time strings.

- format:

  A compact format label (e.g. \`"mmddyyyy"\`, \`"yyyymmddHHiiss"\`).

- tz:

  Timezone for datetime parsing. Defaults to \`"UTC"\`.

## Value

A \`Date\` or \`POSIXct\` vector; unreadable values become \`NA\`.

## See also

\[as_id()\] for the coercion direction; the \`is\_\*\` date detectors in
formex that guard these rules.

## Examples

``` r
read_date(c("3/15/2020", "1-2-2020"), "mmddyyyy")
#> [1] "2020-03-15" "2020-01-02"
read_date("20190315", "yyyymmdd")
#> [1] "2019-03-15"
read_datetime("3/15/2020 2:30 PM", "mmddyyyyhhiiA")
#> [1] "2020-03-15 14:30:00 UTC"
```
