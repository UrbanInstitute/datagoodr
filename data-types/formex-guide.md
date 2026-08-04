# Formex — a guide, with worked examples from the ontology

Formex is the small language DataGoodr uses to describe, per variable, **how a
raw value is read, cleaned, and imported**. Every example below is a real row
from the type ontology (`research_data_type_ontology_v4.csv`). For the terse
operator reference, see [`formex-spec.md`](formex-spec.md); this guide is the
tutorial.

---

## 1. The one rule: `{{ … }}` is the parsed part

A cell is **prose with `{{ }}` interpolations** — the Mustache/Jinja idiom.
Anything inside `{{ }}` is parsed by Formex; anything outside is a human comment.

```
{{ yyyymmdd }} iso date          # "iso date" is just a comment
{{ [strip:$,][dec:.2] }}
{{ @handle }}                    # leads with { → Excel can't treat it as a formula
```

Why double braces: a regex quantifier is a *single* brace (`[a-z]{4}`), so `{{ }}`
lets single braces appear inside as content. And because every parsed cell now
starts with `{`, Excel never mis-reads it as a formula (`= + - @`), so leading
zeros and `@`/`-` survive a CSV round-trip.

## 2. A cell holds one of three things

| kind | looks like | used for |
|---|---|---|
| **formex** | `{{ [strip:$,][dec:.2] }}`, `{{ 9(2)-9(7) }}` | number *bundles* and ID/date *masks* |
| **namespaced token** | `{{ fips:county }}`, `{{ handle:twitter }}` | registry-backed schemes |
| **directive** | `{{ derive }}`, `{{ split:[_lo][_hi] }}`, `{{ none }}` | a mode, not a pattern |

## 3. Reading a row — the raw → stable → import workflow

Each ontology row tells a small story across five columns. Take **`number.currency.usd`**:

| column | value | meaning |
|---|---|---|
| `examples` | `$-45 ;; $2300.00 ;; 17,298$` | how the raw value arrives |
| `data_format` | `{{ [strip:$,][range:-Inf,Inf][dec:.2] }}` | the pattern that matches the raw |
| `raw_to_stable_transform` | `{{ as_usd }}` | the rule that cleans it |
| `stable_format` | `{{ as_usd }} -45.00 ;; 2300.00 ;; 17298.00` | the cleaned result |
| `stable_import_rule` | `{{ default:numeric }}` | how to load the stable value |

Read left to right: a dollar amount comes in with a symbol and grouping; strip
`$` and `,`, keep two decimals; the result is a plain number, so a normal read
imports it with no extra rule.

---

## 4. Numbers — the four-slot bundle

Number formats are a **bundle of attributes**, `[strip][range][dec][split]`, not a
positional shape. Slots are labeled `[key:value]`, order-free, and empty slots
just disappear. Remember: **`[range:…]` is checked by validation, never coerced**;
only `strip` and `dec` change the value.

| row | `data_format` | note |
|---|---|---|
| `count` | `{{ [range:0,Inf][dec:.0] }}` | non-negative integer (`.0` decimals). Import is `{{ as_integer }}` — a naive read would give a double |
| `currency.usd` | `{{ [strip:$,][range:-Inf,Inf][dec:.2] }}` | strip `$` and grouping comma; 2 decimals |
| `currency.euro` | `{{ [strip:€.][range:-Inf,Inf][dec:,2] }}` | European: strip `€` and dot-thousands; **`,2`** = comma is the decimal |
| `portion.percent` | `{{ [strip:%][range:0,100][dec:.n] }}` | strip `%`; bounded 0–100; `.n` = any decimals |
| `measurement` | `{{ [range:-Inf,Inf][dec:.n] }}` | already clean → transform `{{ none }}`, import `{{ default:numeric }}` |

**Ranges split into two variables.** `number.range.min_max`:

```
examples:  1.2, 3.4        (or) 20 to 10
format:    {{ lo,hi }}     (or) {{ hi to lo }}
transform: {{ as_range }}
stable:    {{ split:[_lo][_hi] }}     → two columns, x_lo and x_hi
```

**Coordinates** are numbers with a CRS. `number.coordinate.lat_lon`:

```
examples:  40° 44' 55" N, 74° 00' 22" W     (or) +40.7128-074.0060
format:    {{ gcs:dms:latlon }}             (or) {{ iso:6709:latlon }}
transform: {{ as_coord[from:gcs:dms][order:latlon] }}
stable:    {{ split:[epsg:4326_lat=40.7128][epsg:4326_lon=-74.006] }}
```

`as_coord` reprojects any source CRS to WGS-84 decimal degrees and splits to
`_lat`/`_lon`. Two representation cases (DMS vs ISO-6709) are two rows with the
same target.

## 5. Temporal — named-token masks, ISO out

Date/time formats are masks where each token is a semantic unit; doubling sets
width, separators auto-parse. Everything stabilizes to ISO.

| row | raw | `data_format` | stable |
|---|---|---|---|
| `date.calendar` | `03/15/2019 ;; 3-15-2019` | `{{ mmddyyyy }}` | `2019-03-15` |
| `time.clock` | `2:30 PM` | `{{ hh:ii12A }}` | `14:30` |
| `phase.day_of_week` | `Mon` | `{{ WWW }}` | `1` |

Two things worth calling out:

- **Minute is `ii`, not `mm`** (`mm` is month; `M` is the text month). So a
  12-hour clock is `{{ hh:ii12A }}`.
- **Clock convention is an explicit `12`/`24` suffix**, not letter case —
  `hh:ii12` vs `hh:ii24` — so it survives a careless edit. (`h`/`H` are accepted
  as synonyms.)
- **Phases stabilize to a *number*** — `Mon → 1`, week-start declared — stored as
  an ordered factor with the name as the label in `dd_f_levels`, consistent with
  how categoricals store a code.

## 6. Identifiers — masks, schemes, and hardening

An ID format is either a **named scheme** (registry-backed) or a **COBOL-picture
mask** (`9` digit, `A` letter, `X` alphanumeric; `(n)` count). Three real rows
show the range:

```
record          ex: 550e8400-e29b-41d4-a716-446655440000
                format {{ hash:uuid }}   transform {{ none }}   import {{ as_id }}

administrative  ex: 01-2345678 ;; 12345678
                format {{ gov:ein }}   transform {{ as_ein }}
                stable 01-2345678 ;; 01-2345678     import {{ as_id }}
```

The EIN row shows the normalization contract: `as_ein` restores the dropped
leading zero *and* the delimiter, so both surface forms land on one canonical
value.

**Hardening.** `identifier.id.geographic`:

```
ex:        6037 ;; 06037
format:    {{ fips:county }}
transform: {{ as_id[prefix:FIPS] }}
stable:    FIPS-06037 ;; FIPS-06037
import:    {{ default:character }}
```

An all-numeric key is zero-padded **and** prefixed (`FIPS-`), which (a) forces
every reader to load it as text — note the import is now just
`{{ default:character }}`, no `as_id` needed — and (b) disambiguates a 5-digit
FIPS from a 5-digit CBSA. This is the anti-mojibake default for numeric keys.

**Custom IDs** with no scheme use a mask: `ORG-00123` → `{{ A(3)-9(5) }}`.

## 7. Geographic tokens — `system:unit`

Geographies are a closed, table-backed vocabulary, so the format is a scheme
name, not a pattern:

| token | geography | | token | geography |
|---|---|---|---|---|
| `fips:state` | state (2) | | `metro:cbsa` | CBSA (5) |
| `fips:county` | county (5) | | `postal:zip5` / `postal:zip9` | ZIP / ZIP+4 |
| `fips:county3` | county *component* (3) | | `usps:state` | `CA` (abbr) |
| `fips:tract` | tract (11) | | `name:state` | `California` |

A numeric suffix atomizes a component (`fips:county3` = the 3-digit within-state
part); default is the full GEOID.

## 8. Booleans — presets, unioned

A boolean format is one or more preset encodings joined by `|`, plus a `blank=`
policy (case-insensitive, trimmed). The IRS-990 mixed case is the showcase:

```
boolean.binary.mixed
  ex:     yes ;; 0 ;; t ;; x ;; (blank)
  format: {{ tf|yn|10|check blank=false }}
  stable: TRUE ;; FALSE ;; TRUE ;; TRUE ;; FALSE
```

`boolean.binary.presence` is the checkbox case — `{{ check blank=false }}` — where
a mark is TRUE and an empty cell is FALSE. The `blank=` policy is the one part
that can't be defaulted (a blank is missing in a survey, FALSE in a checkbox).

## 9. Categoricals — shape + the level dictionary

The format is the encoding *shape*; the code→label mapping lives in `dd_f_levels`.

| row | `data_format` | note |
|---|---|---|
| `mutually_exclusive.unordered` | `{{ code }}` | `M ;; F` — labels in `dd_f_levels` |
| `scale.likert` | `{{ code=label }}` | `1=Strongly disagree` — split code from label |
| `multiselect.tags` | `{{ label [delim:;] }}` | `Volunteer;Donor;Board` — a delimited set |
| `mutually_exclusive.geographic` | `{{ usps:state ;; fips:county }}` | defers to the geo tokens |
| `mutually_exclusive.classification_code` | `{{ class:naics }}` | defers to a classification scheme |

Categoricals import with `{{ as_factor }}` / `{{ as_ordered }}` (a naive read
gives character, not a factor). Ordered levels get their order from the `order`
field in `dd_f_levels`.

## 10. Text — tokens, and the literal escape

Most text is `{{ none }}` → `{{ default:character }}`. Some has a scheme:

```
web.url    ex www.pets.com ;; http://pets.com
           format {{ url }}   transform {{ as_url }}
           stable https://www.pets.com ;; https://pets.com

name.handle  ex @JaneDoe ;; janedoe   format {{ handle:twitter }}
             transform {{ as_handle }}   stable janedoe ;; janedoe
```

**The literal escape hatch.** `text.text.literal` protects a value from *any*
coercion:

```
ex:     40% ;; 02168 ;; (605) 348-9999 ;; www.usa.com
format: {{ literal }}   transform {{ none }}   import {{ as_text }}
stable: 40% ;; 02168 ;; (605) 348-9999 ;; www.usa.com   (unchanged)
```

Use `literal` when the raw representation *is* the data and must not be
touched, whatever it looks like. (The `unknown` type reuses this behavior as its
fallback.)

---

## 11. Directives, escapes, and the format/validation line

**Directives** (a `keyword:` inside the braces, or a bare keyword):

| directive | meaning |
|---|---|
| `{{ none }}` | no-op |
| `{{ default:numeric }}` | a plain typed read yields this type; no rule needed |
| `{{ derive }}` | derive the transform from `raw_format → stable_format` |
| `{{ split:[_lo][_hi] }}` | split one field into two suffixed variables |
| `{{ collapse:[MN=Minnesota] }}` | merge levels (categorical) |
| `{{ re:… }}` | the escape hatch — full regex for what masks can't express |

**Escapes.** `re:` switches to full regex (alternation, lookaround) —
`{{ re:\d{3}-\d{2}-\d{4}|\d{2}-\d{7} }}` matches "an SSN or an EIN." A backslash
makes a single character literal. Comments live outside the braces.

**Format vs. validation** share the same grammar (a mask shorthand *is* a
character class), so you can tighten a format where it matters —

```
{{ 9(2)-9(7) }}      # parse-sufficient
{{ [0-8](2)-9(7) }}  # same grammar, first two digits constrained
```

— but keep the *format* parse-sufficient and let *validation* carry what a mask
can't reach: a valid-EIN-prefix **list**, a checksum, a reference-table lookup.
The nchar-range case (`X(8,10)`) is the interesting middle — it's both a parse
fact and a constraint, and one notation serves both.
