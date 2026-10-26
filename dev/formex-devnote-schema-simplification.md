# Dev note to formex — supporting a flat, format-first DGF

From: datagoodr · 2026-10-25
Re: `research_data_type_ontology_v6.csv` and `guess_data_type()`

datagoodr is simplifying the DGF so a researcher reads **one leaf label + one
format field** instead of the `data_type / semantic_family / semantic_type`
triple (see `datagoodr/dev/schema-simplification-plan.md`). Most of what we need
formex already produces. These are the gaps we found while stress-testing the
ontology as shipped, ordered by how much they block us.

## 1. Executability is the long pole — only 36/96 variants are `implemented=yes`

`usd`, `year`, `quarter`, and most of the vocabulary are `implemented=no`. Our
plan's "fall back to the ontology default recipe" assumes a runnable recipe, so
today most previews can't be computed.

**Ask:** (a) keep `implemented` honest and machine-readable (it already is —
thank you); (b) prioritize implementing the high-frequency recipes
(`usd`, `year`, `quarter`, `yyyymm`, `ein`, `us_state`, `zip`); (c) where a
recipe is `no`, we will show the read::write pair marked "proposed, not
executable" — so please keep the `raw_to_stable_transform` / `stable_import_rule`
tokens populated even for unimplemented rows (they are, today — just confirming
the contract).

## 2. read_/write_ verbs, and decompose the stabilizer into a read::write pair

The ontology stores a single verb per row (`raw_to_stable_transform = {{ as_mmddyyyy }}`)
that bakes in the canonical output. We want the output format to be
user-controllable, so we model stabilization as two halves:

```
stabilizer = {{ read_<raw format> :: write_<desired format> }}
           = {{ read_mmddyyyy :: write_yyyymmdd }}
```

**Ask:** expose `read_<format>` (parse a written form → canonical) and
`write_<format>` (canonical → a written form) as public verbs, or give us a
stable way to compose them. `read_*` can alias today's `as_*`; `write_*` is the
new half (formex currently always emits the canonical/ISO form). datagoodr Phase 1
already renamed its own ingest verbs `as_* → read_*`, so the vocabularies line up.

This also fixes the three recipe bugs from the reintegration plan §6
(`as_yyyymm("201903")` wrong year, `as_ein` failing the zero-stripped case,
`as_yyyy("FY2019")` → NA). We have working `read_yyyymm`/`read_ein`/`read_yyyy`
to contribute as the `read_*` half.

## 3. Detect units where the values permit it

`dd_data_unit` is populated on 46/96 rows but reads as a **menu of possible
units** (`usd → USD`, `measurement → unit-specific (kg;;m;;C;;L)`), not a resolved
value. We'd like the router to resolve the actual unit when values allow:

- currency symbol present → `usd` / `euro`; ambiguous bare numbers → `mixed`.
- coordinate range → the EPSG already in `dd_data_unit`.
- otherwise leave it unresolved (we render that as an empty unit facet).

**Ask:** add a `unit` (or `unit_guess`) field to the `$route` record carrying the
*resolved* unit or `NA`, distinct from the ontology's menu.

## 4. Clean up the default-format columns; add one explicit "desired default"

The fields that should carry defaults are overloaded and inconsistent:

- `stable_format` mixes a verb and examples on some rows
  (`{{ as_usd }} -45.00 ;; 2300.00`) but examples only on others
  (`2019-03-15 ;; 2019-03-15`).
- `data_format_default_type` means a strip-recipe for numbers
  (`{{ [strip:^0-9.-]… }}`) but `{{ yyyymmdd }} iso` for dates.

**Ask:** (a) keep `stable_format` to *examples only*; move any verb out of it;
(b) add an explicit **`desired_default_format`** column — the format we should
pre-fill as the stabilizer's `write_` target when the human expresses no
preference (e.g. `yyyymmdd` for calendar, `numeric` for usd). This is the field
we flagged as "maybe add to the ontology" in the plan.

## 5. Two uniqueness collisions need a documented tie-break

We default the user-facing label to `format_label` (95/96 unique — thank you).
The two that collide:

- `format_label = mixed` → `boolean/binary` **and** `unknown/unknown`.
- `semantic_type = geographic` → `categorical/mutually_exclusive` **and**
  `identifier/id` (we resolve this one by cardinality on our side; just flagging
  that the leaf alone is ambiguous).

**Ask:** confirm these are intentional, and consider a `disambiguator` note on
those rows (or rename one `mixed`) so a leaf-only consumer has a defined rule.

## 6. A format DSL grammar with namespaces and separator discipline

We want `guess_data_format` to accept a formex token, an R format string, or a
regex, told apart by a prefix, and to keep the list/compose/facet separators
distinct:

```
fx:<token>     strp:<R format>     re:<regex>
::  = read::write compose    :  = key:value facet    ;;  = list
```

**Ask:** if formex emits into this field, please use `fx:` for lexicon tokens and
reserve `::` for composition only (today `;;` is used both for alternatives and,
in our earlier sketch, for facets — we're separating those).

## 7. Minor, already on the reintegration §6 list

- `fx_dgf_fields()` has two depth scales (`route$depth` 0–4 vs `depth_labeled`
  capped at 3) and can't resolve `semantic_type_id` from a path. We rely on
  `route$depth` for the label fallback ladder.
- The `as_integer` probe still leaks "NAs introduced by coercion to integer
  range" on ordinary numeric columns; we muffle it narrowly for now.
- Delete the stale `data-types/research_data_type_ontology_v6.csv` duplicate;
  `fx_ontology()` reads `inst/extdata`.

## What we do NOT need from formex

The label collapse, the depth fallback, the two tie-breaks, `stable_first5`, the
needed-flags, and the `dg.R` escape hatch are all datagoodr-side. The asks above
are the minimum formex surface that makes them executable.
