# Formex — the DataGoodr format-expression syntax

Formex is the small language used in the DGF's machine-read columns
(`data_format`, `raw_to_stable_transform`, `stable_format`,
`stable_import_rule`, and the two `data_format_default_*` columns). It describes,
per variable, how to read the raw value, how to stabilize it, and how to import
the stable value — the raw -> stable -> import workflow, spelled out by example.

## The one rule: `{{ … }}` is the parsed container

**Everything inside `{{ … }}` is parsed. Everything outside is a human comment.**
A cell is prose with `{{ }}` interpolations — the Mustache/Jinja idiom.

```
{{ yyyymmdd }} ISO date          # "ISO date" is a trailing comment, ignored
{{ [strip:$,][dec:.2] }}
{{ @handle }}                    # leads with { -> Excel-safe, no escape needed
```

Why the double brace (not single): regex quantifiers are single braces
(`[a-z]{4}`), so `{{ }}` lets a single `{` appear inside as content without
colliding with the container. It also means every parsed cell **leads with `{`**,
which is not an Excel formula trigger (`= + - @`), so cells import as text and
leading zeros/`@`/`-` survive a CSV round-trip. (R users: this is not rlang's
`{{ }}` — it is inert cell data, never evaluated.)

## Operators (inside the braces)

```
keyword:     a MODE selector — re | split | derive | default | collapse | none
             (no keyword  =  a plain formex expression)
9  A  X      mask shorthands: digit / letter / alphanumeric   (X, not *)
[ … ]        a set: a character class ([0-8]) OR a [key:value] argument slot
( … )        a count: (n) exact · (m,n) range · (n+) open · (max_width) dynamic
\            a literal escape; its meaning is set by the mode
             (regex escaping inside re:, a literal character elsewhere)
```

Residual escape: a literal `}}` inside content (near-never) is written `\}`.

## Modes

```
{{ 9(5)-A(3) }}                     plain formex (a mask)
{{ [strip:$,][range:0,Inf][dec:.2] }}   plain formex (a number bundle)
{{ re:\d{3}-\d{2}-\d{4}|\d{2}-\d{7} }}  regex — SSN or EIN (formex has no |)
{{ derive }}                        derive the transform from raw_format -> stable_format
{{ split:[_lo][_hi] }}              split one field into two, suffixed _lo / _hi
{{ default:numeric }}               a plain typed read yields this type; no rule needed
{{ collapse:[MN=Minnesota] }}       merge levels (categorical)
{{ none }}                          no-op
```

## The two format surfaces (there are two jobs, not one)

- **Masks** describe a string's *shape* — IDs, phone, dates, geo codes. Positional:
  `9(2)-9(7)`. Position *is* the meaning, so masks stay positional. Shorthands are
  sugar for character classes, so a format and its validation are one language,
  looser vs. tighter: `9(2)-9(7)` (parse) vs `[0-8](2)-9(7)` (constrained).
- **Number bundles** parameterize a *transformation*, not a shape:
  `[strip:…][range:…][dec:…][split:…]`. Slots are labeled `[key:value]`
  (order-free, omit empties); a bare positional form `[$,][0,Inf][.2]` is an
  allowed shorthand. **`[range:…]` is validation-role, not transform-role** —
  the stabilizer flags out-of-range values, it never silently coerces them.
  `[strip]` and `[dec]` are the only transform slots.

## Temporal tokens

A named-token mask where each token is a semantic date/time unit; doubling sets
width, separators are auto-parsed. `yyyy`/`yy` year · `mm`/`m` month number ·
`MMM`/`MMMM` month name · `dd`/`d` day · `WWW`/`WWWW` weekday name · `ss`/`s`
second · `A` AM/PM · `T` timezone.

Gotcha: **minute is `ii`/`i`, not `mm`/`m`** (which is month; `M` is the text
month). Clock hours use an **explicit `12`/`24` suffix** rather than case, so the
convention survives a careless edit or CSV/Excel round-trip: `hh24` / `hh:ii24`
(24-hour) and `hh12` / `hh:ii12` (12-hour, pair with `A` for AM/PM). Legacy
`H` (24-h) / `h` (12-h) case forms are accepted as synonyms and normalized to the
explicit form.

Everything stabilizes to ISO: date `2019-03-15`, timestamp
`2019-03-15 14:30:00` (tz declared), time `14:30`, year `2019`, quarter
`2019-Q1`, month `2019-03`, week `2019-W12`; ranges `{{ split }}` to
`_start`/`_end`. **Phase** (cyclical position) stabilizes to its **numeric
position** — hour `0-23`, dow `1-7` (week-start declared), month `1-12`, week
`1-53` — stored as an ordered factor with the name as the label in `dd_f_levels`
(consistent with categorical -> code).

## Namespaced tokens

Registry-backed scheme names, resolved to width/hierarchy/reference-table:
`fips:county` · `fips:county3` (atomized component) · `metro:cbsa` ·
`postal:zip9` · `usps:state` · `gov:ein` · `pub:orcid` · `hash:uuid` ·
`epsg:4326:lat` · `gcs:dms:latlon` · `handle:twitter` · `class:naics`.

## Transform = one generic function

`f(value, from, to, …[key:value])`, dispatched by data type to per-type engines
(`as_date`, `as_id`, `as_number`, `as_factor`, `as_coord`). The
`raw_to_stable_transform` cell holds either a directive (`{{ derive }}`) or an
explicit call (`{{ as_id[prefix:FIPS] }}`). Input/output *data types* are not
extra arguments — they are the DGF row (`raw_data_type` -> `stable_data_type` ->
`desired_data_type`). A transform is possible only "if you can get there from
here": some paths are one-way (a float-corrupted ID, an undelimited range, a
pre-collapsed category cannot be recovered) — which is the argument for hardening
before the damage.

## A cell holds one of three kinds of content

1. **formex** — a mask or number bundle (shape / derivable transform).
2. **a namespaced token** — a registry-backed scheme.
3. **an argument pointer** — when the transform needs non-format information
   (categorical -> `dd_f_levels`; coordinate -> CRS args).
