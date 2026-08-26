# Formex reintegration plan

Written against the real `formex` package (`00-GITHUB/formex`,
github.com/lecy/formex), reinstalled from source and measured on 2026-08-21.

> **Progress.** Phases 1–3 are **done**, on branch `formex-reintegration`
> (`219213b`, `d1641ae`, `3178c2f`). Full suite: **472 passing, 0 failures**.
> Next is **Phase 4**, v6 coordinates in the DGF schema — which needs open
> decision #1 answered first.
>
> | | before | after |
> |---|---|---|
> | `R/` files | 54 | 35 |
> | lines of R | ~10,700 | 8,244 |
> | exports | 219 | 115 |
> | formex collisions | 87 | 4 (deliberate deprecated shims) |
> | vignettes | 5 | 1 |
>
> **Two findings from Phase 3 that changed the design:**
>
> 1. **No v4→v6 translation table is needed.** 35 of the 38 dotted values the
>    legacy shim emits are already valid v6 `semantic_family.semantic_type`
>    coordinates — the v4 vocabulary is a *subset* of v6's. `desired_data_class`
>    always spoke v6. This makes Phase 4 much smaller than Part 3.3 assumed.
> 2. **Confidence is not a sufficient guard.** A column of `rnorm()` doubles
>    routes to `text/web/domain` at **depth 4, confidence 1.0**, with a
>    `variant_id` — `-0.6264538` parses as a domain name. The route therefore
>    keeps the conservatism the legacy path always had. Part 2's storage-safety
>    gate was necessary but not sufficient; this is the second guard.

---

## Part 0 - Verification (done)

`formex` reinstalled from source:

```
formex 0.0.0.9000 | Built: R 4.4.2; 2026-08-22 04:01:41 UTC
fx_stabilize      TRUE
fx_transform      TRUE
fx_classify_column TRUE
```

The `$route` record is live:

```
guess_data_type(c("03/15/2019","12/31/2020","01/01/2021"))$route
  data_type         temporal
  semantic_family   date
  semantic_type     calendar
  format_label      calendar
  semantic_type_id  n0059
  variant_id        n0059-f01
  match_kind        genome
  depth             4
  confidence        1
  router_method     learned
```

`fx_stabilize()` works end to end:

```
us_state -> CA, TX, OH        import {{ as_factor }}
calendar -> 2019-03-15, ...   import {{ as_yyyymmdd }}
isbn     -> 0395629764, 9573304716
```

And formex's date genome handles the case datagoodr's parser fails:
`fx_transform("20190315", "{{ as_mmddyyyy }}")` -> `2019-03-15`
(datagoodr's `as_yyyymmdd("20190315")` -> `NA`).

---

## Part 1 - The v6 ontology

96 rows x 25 columns, shipped at
`inst/extdata/research_data_type_ontology_v6.csv` and `data/ontology.rda`,
read by `fx_ontology()`.

### 1.1 Shape

A **4-level path** plus a stable key:

```
data_type / semantic_family / semantic_type / format_label   +  semantic_type_id, variant_id
```

`variant_id` is 1:1 with a recipe. One row = `{detector, transform, stable form,
import rule}` as a unit. That is the contract surface: *"they meet only at the
ontology's stable keys."*

Distribution across the 8 top-level types:

| data_type | variants | families |
|---|---|---|
| text | 24 | text, name, postal, web, contact, color |
| number | 23 | quantity, currency, portion, range, coordinate |
| categorical | 13 | mutually_exclusive, multiselect, scale |
| temporal | 12 | date, time, period, phase, interval |
| identifier | 10 | id |
| structured | 6 | collection, record, geometry |
| boolean | 5 | binary |
| unknown | 3 | unknown |

### 1.2 `match_kind` is the honesty column

| match_kind | n | what it means for datagoodr |
|---|---|---|
| `mask` | 48 | shape-recognizable; recipe should confirm |
| `none` | 16 | **not value-detectable** - needs the header or the dictionary |
| `shape` | 12 | numeric coercion only; subtypes are not separable |
| `lexicon` | 10 | gazetteer-backed; ceiling is coverage |
| `mask+lexicon` | 7 | the hard ones (addresses, classification codes) |
| `genome` | 3 | the tolerant date/time parsers - the strongest |

All 12 `number/quantity` rows and all 8 `categorical/mutually_exclusive` rows
are `shape` or `none`. **The ontology itself declares that a bare number or a
bare category cannot be resolved to a leaf from values alone.** That is not a
gap to fix; it is the reason `depth` exists.

### 1.3 The recipe DSL is small

All four recipe columns are 96/96 populated. Distinct transforms:

- `none` (35 rows - over a third are already stable)
- `as_ordered` (6), `as_boolean` (5), `as_range` (5), `as_integer` (4), `as_factor` (3)
- ~30 singletons: `as_ein`, `as_isbn`, `as_doi`, `as_usd`, `as_quarter`, ...
- parameterized: `as_coord[from:gcs:dms][order:latlon]`, `as_id[prefix:FIPS]`,
  `as_serial[delim::]`
- pipelines: `zeropad5+validate`, `split+order`
- lookups: `lookup:usps`, `lookup:iso3166`, `lookup:given`, `lookup:surname`, `lookup:place`

Import rules are nearly all `default:character` (23), `default:numeric` (21),
`as_text` (10), `as_id` (9), `as_factor` (7), `as_ordered` (6).

### 1.4 The temporal family maps cleanly onto our render grains

v6's `dd_data_unit` already carries what `.temporal_grain()` re-derives:

| v6 path | dd_data_unit | our grain |
|---|---|---|
| `period/year` | calendar or fiscal year | `year` |
| `period/quarter` | calendar or fiscal quarter | `quarter` |
| `period/month` | calendar month | `month` |
| `phase/hour_of_day` | hour position 0-23 | `hour` |
| `phase/day_of_week` | weekday position | `dow` |
| `phase/week_of_year` | week position 1-53 | `week` |
| `date/calendar`, `date/timestamp` | - | `date` |

So `.temporal_grain()` becomes a lookup on the v6 row, not a `switch` over
dotted strings.

---

## Part 2 - Measured: route vs. legacy on our own column types

This is the finding that orders everything else. Run on realistic columns
(n = 40-60), reporting both the v6 `$route` and the legacy `$guess`:

| column | `$route` | depth | conf | legacy `$guess` |
|---|---|---|---|---|
| county FIPS (named) | `number/quantity/count` | 3 | 0.87 | **county_fips** (1.0) |
| county FIPS (unnamed) | `number/quantity/count` | 3 | 0.87 | **zip_code** (1.0) |
| state FIPS | `number/quantity/count` | 3 | 0.97 | **state_fips** (1.0) |
| ZIP codes | `number/quantity/count` | 3 | 0.86 | **zip_code** (1.0) |
| EINs (zero-padded) | *(nothing)* | 0 | 0.22 | **ein** (1.0) |
| emails (n=40) | `number` | 1 | 0.32 | **email** (1.0) |
| emails (n=5) | `text` | 1 | 0.41 | **email** (1.0) |
| US state abbr | **`categorical/mutually_exclusive/geographic/us_state`** | 4 | 1.00 | us_state (1.0) |
| years | **`temporal/period/year/year`** | 4 | 1.00 | *(none)* |
| USD amounts | **`number/currency/usd`** | 3 | 0.95 | currency_symbol (1.0) |
| US dates | **`temporal/date/calendar/calendar`** | 4 | 1.00 | us_date (1.0) |

**Two conclusions, both load-bearing:**

1. **Neither modality dominates.** The route nails dates, states, years
   (which the legacy detectors miss entirely), and currency. The legacy
   detectors nail every zero-padded numeric code and email. datagoodr must
   consume **both** `$route` and `$guess` - which is exactly why the design note
   returns the legacy fields "unchanged" alongside.

2. **A confident-but-wrong route is more dangerous than no route.** Every
   zero-padded key we care about routes to `number/quantity/count` at depth 3
   with confidence 0.86-0.97. Acting on that would coerce `06037` to `6037` -
   precisely the mojibake `read_as_text = TRUE` exists to prevent. The adapter
   needs a **storage-safety gate**, not just a confidence threshold.

---

## Part 3 - Naming: the `read_*` / `as_*` split

Our `as_mmddyyyy()` does not *produce* `mm/dd/yyyy` - it *consumes* it and
returns a `Date`. The name states the opposite of the function. Renaming to
`read_*` fixes that, and it pays off three times over.

### 3.1 The rule

- **`read_<format>(x)`** - ingest a value written in that format; return the
  canonical/typed value. *Input* format in the name.
- **`as_<type>(x)`** - coerce a value into a target type. *Output* type in the
  name.

### 3.2 The mapping

| now | becomes | ingests |
|---|---|---|
| `as_date(x, format)` | `read_date(x, format)` | any compact-label date |
| `as_datetime(x, format)` | `read_datetime(x, format)` | any compact-label datetime |
| `as_yyyymmdd` | `read_yyyymmdd` | `20190315` / `2019-03-15` |
| `as_mmddyyyy` | `read_mmddyyyy` | `03/15/2019` |
| `as_ddmmyyyy` | `read_ddmmyyyy` | `15/03/2019` |
| `as_mdyyyy` | `read_mdyyyy` | `3/15/2019` |
| `as_dMyyyy` | `read_dMyyyy` | `15-Mar-2019` |
| `as_Mdyyyy` | `read_Mdyyyy` | `Mar 15, 2019` |
| `as_yyyymmddHHiiss` | `read_yyyymmddHHiiss` | ISO timestamp |
| `as_mmddyyyyhhiiA` | `read_mmddyyyyhhiiA` | US datetime w/ AM-PM |
| `as_yyyymm` | `read_yyyymm` | `201903` -> `2019-03` |
| `as_yyyy` | `read_yyyy` | `2019` |
| `as_mm` | `read_mm` | `8` -> `08` |
| `as_EIN` | `read_ein` | `12345678` -> `012345678` |
| `as_id` | **`as_id`** (unchanged) | coerces *to* identifier |

### 3.3 Why this is worth doing first

**It makes the DGF's two bridge columns type-distinct.** The earlier audit found
them muddled; the rename resolves it structurally:

```
raw_to_stable_transform   = a READ   (ingest the raw written form)   read_*
desired_data_import_rule  = an AS    (coerce into the target type)   as_*
```

You can now tell from a rule cell's *name* which stage it belongs to, and a rule
in the wrong column is visible on sight.

**It eliminates every `as_*` export collision.** formex exports exactly four
`as_*`: `as_EIN`, `as_mm`, `as_yyyy`, `as_yyyymm` - all four in our rename list.
Afterwards datagoodr exports one `as_*` (`as_id`), which formex does not export.
Collisions: zero.

**It resolves the same-name-different-function trap.** Measured:

| value | formex verb | datagoodr |
|---|---|---|
| `as_yyyymm("201903")` | **`2020-03`** (wrong year) | `2019-03` |
| `as_yyyymm("2019-03-15")` | `2019-03` | - |
| `as_ein("12345678")` | **`NA`** | `012345678` |
| `as_ein("012345678")` | `01-2345678` | `012345678` (no hyphen) |
| `as_yyyy("FY2019")` | **`NA`** | - |

Three of those are formex bugs worth reporting upstream (§6). But the point
stands regardless: two packages, same names, different behaviour. Renaming ours
removes the ambiguity permanently instead of relying on search-path luck.

### 3.4 Blast radius

~90 call sites across `R/`, `tests/`, `vignettes/`; 4 `man/` pages; and two
DGF fixtures (`data-dev/DGF-DRAFT.csv`, `data-dev/DGF.csv`) whose rule cells
carry the old names. Small. Ship deprecated `as_*` shims that warn and forward,
so existing user DGFs keep running for one release.

### 3.5 One decision inside the rename

`read_ein("012345678")` currently returns `012345678`; the v6 recipe's stable
form is `01-2345678` (hyphenated). Recommend **adopting the ontology's form** -
it is the shared contract, and diverging on the canonical stable value is how
two packages silently stop agreeing.

---

## Part 4 - The phases

### Phase 1 - The `read_*` / `as_*` rename  **<- start here**

Self-contained inside datagoodr. No formex dependency. Clears all four `as_*`
collisions before they can bite, and fixes the vocabulary every later phase
writes into DGF cells.

1. Rename the 14 functions per §3.2 in `R/01-07-as-rules.R` and
   `R/02-01-format-functions.R`.
2. Add deprecated `as_*` shims forwarding to `read_*` with a one-time warning.
3. Update the ~90 call sites, 4 `man/` pages, and the two `data-dev/` DGF
   fixtures.
4. Document the rule in `R/01-01-dgf-schema.R`'s header: `raw_to_stable_transform`
   takes `read_*`, `desired_data_import_rule` takes `as_*`.
5. Fix `read_yyyymmdd("20190315")` -> `NA` while you are in the file, or delete
   the parser in favour of formex's in Phase 5 - see §6.

### Phase 2 - Delete the duplicated detection layer

Follow `formex/INTEGRATION-NOTES.md`. ~2,400 lines of `R/`, plus the
`data-types/` tree, four vignettes, four test files, `data/data_type_tests.rda`,
and the seven lookups in `sysdata.rda` (keep the six `layout.*` tables).

Measured beforehand: **16 of the 20 shared files are byte-identical** to
formex's; the four that differ, formex is strictly ahead. Nothing is lost.

Add `formex` to `Imports:` and `lecy/formex` to `Remotes:`.

Delete our four detection vignettes rather than merging - formex has
formex-native v6 rewrites. (Our last commit updated the ontology vignette to
**v4** on 08-04; formex rewrote the same file to **v6** on 08-15.)

### Phase 3 - The adapter, dual-modality with a safety gate

`R/01-06-guess-dgf-types.R` becomes the adapter over `formex::guess_data_type()`.
Per Part 2 it must read **both** records:

```
route depth 4 + high confidence          -> take the route (leaf + variant_id)
route depth <= 3, legacy $guess confident -> take the legacy guess
neither confident                         -> keep the base storage type, depth 1
```

Plus the **storage-safety gate**: never let a `number/*` route re-type a column
whose raw values carry leading zeros or exceed double precision. That single
rule protects every FIPS, ZIP, EIN, and NAICS column in Part 2's table.

`test-guess-dgf-types.R`, `test-temporal.R`, `test-identifier.R` stay and become
the integration check. Add the Part 2 columns as regression fixtures.

### Phase 4 - v6 coordinates in the DGF

Store `semantic_type_id` + `variant_id` (the contract keys), plus
`guess_confidence`, `guess_depth`, `match_kind`, `ontology_version`.

Retire `.to_class_subclass()` (a v1->v4 shim, wrong shape for v6). Re-base
`.temporal_grain()` on the v6 row per §1.4.

**Represent depth honestly.** Today `guess_dgf_types()` silently falls back to
the base R-storage type, erasing the difference between "confidently a number"
and "could not resolve past number". With 16 `none` and 12 `shape` rows in the
ontology, that distinction covers a third of the vocabulary. A shallow answer is
work-for-the-human, not a finished label.

Decide (§5) whether to adopt the full `guess_*`/`final_*` split from the design
note or map `guess_*` onto new columns and treat the existing `desired_*` family
as `final_*`. The latter is less churn and preserves curated `.xlsx` files.

### Phase 5 - Stabilization via `fx_stabilize()`

Rewire `stabilize_data()` to resolve `final_variant_id` and call
`fx_stabilize()`, keeping the bare-function-name path as back-compat.

Three of our bugs land here:

1. **Stage order is inverted** - `R/09-stabilize-data.R:100` applies the import
   rule *before* the transform. The model is raw -> transform -> stable -> import.
2. **Element-wise application destroys types** -
   `vapply(col, \(x) as.character(f(x)))` at `:41` stringifies the `Date` the
   rule just produced and cannot express column-scoped or parameterized
   transforms. formex's verbs are vectorized; the wrapper must be too.
3. **`R/01-07-as-rules.R` can probably go** - formex's date genome includes the
   empty delimiter, so `%Y%m%d` is in its library and `20190315` parses, with a
   round-trip check that rejects partial matches. Keep only the `read_*` helpers
   that cover cases formex misses (§6).

### Phase 6 - Upstream and cleanup

Report the three formex recipe bugs from §3.3 - `as_yyyymm("201903")` -> wrong
year, `as_ein` failing the zero-stripped case its own ontology row documents
(`01-2345678 ;; 12345678`), `as_yyyy` failing `FY2019` though the row's format is
`{{ FYyyyy ;; yyyy }}` and `is_fiscal_year()` exists. Our `read_yyyymm` /
`read_ein` / `read_yyyy` already handle these - offer them as verbs.

Also: the verifier leaks `NAs introduced by coercion to integer range` warnings
on ordinary numeric columns; `fx_dgf_fields()` does not resolve
`semantic_type_id` from a path (only path from id), and its `depth_labeled`
tops out at 3 while `route$depth` goes to 4 - two different depth scales.

Refresh `formex/dev/datagoodr_integration.md` §9/§10 (it still lists the
transform executor as missing; it is built). Delete formex's stale
`data-types/research_data_type_ontology_v6.csv` duplicate - `fx_ontology()`
reads `inst/extdata`.

---

## Part 5 - Open decisions

1. **`guess_*`/`final_*` split, or map onto the existing `desired_*` family?**
2. **Re-export policy** for the 80 `is_*` detectors datagoodr currently exports -
   curated subset, or a clean break documented in `NEWS.md`?
3. **Does `read_ein()` adopt the hyphenated stable form?** (§3.5 - recommend yes.)
4. **Does datagoodr keep any ontology of its own?** Recommend no: one ontology,
   owned by formex, versioned v6, reached through `fx_ontology()`.

---

## Part 6 - Where to start

**Phase 1, the rename.** It is the only phase with no external dependency, it is
~90 mechanical call sites, and it buys three things at once: correct names, zero
`as_*` collisions, and a DGF whose two bridge columns are finally
distinguishable by sight.

Phase 2 (the deletion) is next and is already specified file-by-file in
`INTEGRATION-NOTES.md`.

Phase 3 is where the judgement is, and Part 2's table is the spec for it: the
route and the legacy detectors are complementary, and a confident-but-wrong
`number/quantity/count` on a zero-padded key is the failure mode to design
against.
