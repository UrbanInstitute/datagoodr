# Deprecated \`as\_\*\` rule names

Renamed to \`read\_\*\` to state the format each one \*ingests\*. Each
shim forwards to its replacement and warns once per session.

## Usage

``` r
as_date(x, format, tz = "UTC")

as_datetime(x, format, tz = "UTC")

as_yyyymmdd(x)

as_mmddyyyy(x)

as_ddmmyyyy(x)

as_mdyyyy(x)

as_dMyyyy(x)

as_Mdyyyy(x)

as_yyyymmddHHiiss(x)

as_mmddyyyyhhiiA(x)

as_EIN(x)

as_mm(x)

as_yyyy(x)

as_yyyymm(x)
```

## Arguments

- x, format, tz:

  Passed through to the replacement function.

## Value

Whatever the replacement returns.

## See also

\[read_date()\], \[read_ein()\]
