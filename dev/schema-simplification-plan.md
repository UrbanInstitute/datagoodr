# DGF schema simplification — a flat, format-first workflow

Written 2026-10-25, against the real v6 ontology
(`formex/inst/extdata/research_data_type_ontology_v6.csv`, 96 variants) and the
current adapter (`R/01-06-guess-dgf-types.R`). This reshapes **Phase 4** of
`formex-reintegration-plan.md` and resolves open decision #1.

## The idea in one line

Collapse the three type coordinates (`data_type` / `semantic_family` /
`semantic_type`) that no researcher wants to read into **one label plus a format
field**, machine-proposed and human-editable, and show the human the *effect* of
every proposed rule before they accept it.

Target row (dates), after:

```
raw_first5              = 10-25-2024 ;; 3-17-1987 ;; 11-21-2004
raw_data_mode           = character                      (R storage, as read)
guess_data_type         = calendar {{ date :: temporal }}   <- formex writes
guess_data_format       = {{ mmddyyyy }}                    <- formex writes (format/units)
guess_match_kind        = genome                            <- formex writes (honesty)
desired_data_type       = calendar                          <- human confirms/overrides
desired_data_format     = {{ yyyymmdd }}                    <- human confirms/overrides
stabilizer_needed       = yes
stabilizer              = {{ read_mmddyyyy :: write_yyyymmdd }}   <- formex suggests, human edits
stable_first5           = 2024-10-25 ;; 1987-03-17 ;; 2004-11-21  <- computed from the proposed rule
load_rule_needed        = yes
load_rule               = {{ read_yyyymmdd }}               <- formex suggests
```

(Note: the stabilized middle value is **1987-03-17**, not `1987-17-03` — month 17
is impossible. The slip in the original sketch is exactly what `stable_first5`
exists to catch: a mis-ordered date detector is visible on sight.)

---

## What the ontology actually supports (measured, not assumed)

| Claim in the proposal | Verdict | Evidence |
|---|---|---|
| One leaf label implies the whole path | ✅ mostly | 80/96 rows have `format_label == semantic_type`; every path rebuilds from the leaf |
| The leaf is the *most intuitive* label | 🔧 **use `format_label`, not `semantic_type`** | `format_label` is 95/96 unique; in the 16 rows they differ, `format_label` wins (`ein`>`administrative`, `us_state`>`geographic`) |
| The leaf is unique | ⚠️ two breakers | `geographic` lives under **categorical** *and* **identifier**; `mixed` under **boolean** *and* **unknown** |
| Ontology defaults are available to fall back on | ❌ **mostly not executable yet** | only **36/96** variants are `implemented=yes`; `usd`, `year`, `quarter` are all `no` |
| Detectors can guess the current format | ⚠️ ~a third can't | 16 `none` + 12 `shape` = **28/96** are not value-detectable; need header/dictionary |
| Units are available | 🔧 as a *menu*, not a detection | 46/96 carry `dd_data_unit`, but it lists *possible* units (`usd→USD`, `measurement→kg;;m;;C;;L`); the router does not resolve which one a column uses |

### Consequence 1 — the default label is `format_label`

Default `guess_data_type` to the **deepest resolved leaf with a human name**:

```
format_label (depth 4)  ->  semantic_type (depth 3)  ->  semantic_family (depth 2)  ->  data_type (depth 1)
calendar / ein / us_state   (umbrella, when no leaf)      date / quantity               temporal / number
```

This is literally the **route depth ladder** re-expressed (§ the reintegration
plan's depth table). `route_depth` already carries which rung we reached, so the
fallback is free — no new logic, just a label-selection rule.

The parentheses `{{ family :: data_type }}` are informational **except** for the
two uniqueness breakers, where they carry real meaning:

- `geographic` — categorical (a grouping variable) vs identifier (a join key).
  The adapter already decides this by cardinality (near-unique → identifier +
  `dd_is_join_key`); **keep that rule** and let it pick the parenthetical.
- `mixed` — boolean vs unknown. Rare; fall back to `data_type` in the parens.

### Consequence 2 — honesty must travel with the guess

A third of the vocabulary cannot be resolved from values. `guess_match_kind`
(`none` / `shape` / `mask` / `lexicon` / `genome`) is the column that tells the
human *why* a guess is shallow: `number {{ quantity }}` with `match_kind=shape`
means "the values prove it's a number and can prove nothing finer — the leaf is
yours to supply," which is a finished, honest answer, not a failure. "Could not
tell from values" is a first-class, calm state, never an alarm.

### Consequence 3 — suggestions gate on `implemented`

The stabilizer/load-rule suggestion must check the variant's `implemented` flag:

- `implemented=yes` → suggest the executable rule; `stable_first5` can be computed.
- `implemented=no` → suggest the read::write pair **marked proposed**, do not
  compute `stable_first5`, and point the human at `dg.R` to define it. Never
  present an unrunnable rule as if it will run.

This is the long pole: today only calendar/timestamp and a handful else are
executable, so most `stable_first5` previews are blocked until formex implements
the common recipes (see the dev note).

---

## The schema (flat, format-first)

Replaces the `desired_data_type` + `desired_data_class` + `raw_to_stable_transform`
+ `desired_data_import_rule` cluster with:

| column | who writes | holds |
|---|---|---|
| `raw_first5` | profiler | first 5 raw values, verbatim |
| `raw_data_mode` | profiler | R storage mode as read (`character`/`double`/…) — renamed from `raw_data_type` to stop overloading "type" |
| `guess_data_type` | **formex** | leaf label `{{ family :: data_type }}` |
| `guess_data_format` | **formex** | format/units token (see DSL below) |
| `guess_match_kind` | **formex** | honesty column |
| `guess_confidence`, `guess_depth`, `guess_variant_id` | **formex** | provenance (already produced by the adapter, not yet stored) |
| `desired_data_type` | **human** | confirmed/overridden leaf label |
| `desired_data_format` | **human** | confirmed/overridden format |
| `stabilizer_needed` | formex, human edits | yes/no |
| `stabilizer` | formex suggests, human edits | `{{ read_<raw> :: write_<desired> }}` |
| `stable_first5` | computed | the proposed stabilizer applied to `raw_first5` |
| `load_rule_needed` | formex, human edits | yes/no |
| `load_rule` | formex suggests, human edits | `{{ read_<stable> }}` |

Resolves **decision #1**: machine → `guess_*`, human → the existing `desired_*`
family (kept, not renamed to `final_*`), so curated `.xlsx` files keep their
`desired_*` columns. The further collapse of type+class into label+format is the
simplification on top.

### Naming decisions

- **read_/write_ everywhere.** `read_<format>` parses a written form into the
  canonical value; `write_<format>` emits the canonical value in a target form.
  The stabilizer is a `read :: write` pair. `as_*` is retired (it was Phase 1's
  interim; the write_ half is net-new — see risks).
- **Load rule uses `read_`** (agreeing with the proposal): loading the governed
  CSV is the same "parse this format" operation, so `{{ read_yyyymmdd }}`. The
  *column name* encodes the stage, so the verb needn't.
- **`load_rule_needed`** instead of `import_rule_needed_yn`: the governed CSV is
  *loaded* back into R; "load" is short and unambiguous, and `_yn` is noise once
  the value is literally yes/no. (Alt considered: `reimport`. Rejected — "import"
  already means the raw→DGF step elsewhere.)

### The format / unit DSL

One field, three namespaces, so a parser never guesses:

```
{{ fx:mmddyyyy }}              formex lexicon token
{{ strp:%m/%d/%Y }}           an R strptime/format string
{{ re:^\d{5}$ }}              a regular expression
{{ fx:mmddyyyy ;; unit:USD }} list of key:value facets, when both are needed
```

Grammar discipline (a real risk in the sketch): reserve **`::`** for the
read::write composition only, **`:`** for `key:value` facets, and **`;;`** for
lists. The sketch's `{{ format :: mmddyyyy ;; unit :: month-day-year }}` overloads
`::` and `;;`; the form above keeps them distinct. Default-format rows use the
label `default` with a plain-English gloss: `{{ default (ISO yyyy-mm-dd) }}`.

### The `dg.R` escape hatch

Any token or verb not in the formex lexicon resolves against a project-local
`dg.R`: a function named exactly as the token (`read_mycode <- function(x) …`).
`inspect_dgf()` already checks that every named rule resolves in an environment
(`R/02-06-inspect-dgf.R`); extend that check to the stabilizer/load_rule columns
and to `dg.R`.

---

## Phases (replaces reintegration Phase 4; 5–6 continue after)

**S1 — Label selection + honesty, read-only.** Add `guess_*` columns
(`guess_data_type` as `format_label {{ family :: data_type }}`, `guess_data_format`,
`guess_match_kind`, and the three provenance fields the adapter already computes).
No stabilization yet. Lets us see the labels on real data and tune the depth
fallback and the two tie-breaks. No formex change required — the data is already
in `$route`/`$guess`.

**S2 — The format/unit DSL + `dg.R` resolver.** Parser for the three namespaces;
extend `inspect_dgf()`. Independent of formex.

**S3 — The stabilizer as read::write.** Build `write_*` verbs (the net-new half).
Compose the pair from the ontology's `data_format` (raw) and `desired_data_format`.
Gate on `implemented`. **Blocked on the dev note** for the common recipes and for
formex exposing read_/write_.

**S4 — `stable_first5` preview + `stabilizer_needed`/`load_rule_needed` flags.**
Apply the proposed pair to `raw_first5`; derive the needed-flags from (stable
storage mode vs desired R type). Depends on S3.

**S5 — Units.** Consume a detected unit from formex when present; otherwise leave
`guess_data_format`'s unit facet blank. **Blocked on the dev note** (detectors do
not resolve units today).

Migration: `desired_data_type` keeps its values; `desired_data_class` is dropped
(its dotted `family.type` is now implied by the label). A one-shot migrator maps
existing `desired_data_class` → label for curated `.xlsx` files, same shape as
`dev/migrate-dgf-v1-to-v2.R`.

## Open questions for you

1. Label the leaf with `format_label` (my recommendation) or hold to
   `semantic_type`? The only cost of `format_label` is that `administrative`,
   `geographic`, `person`, `lat_lon`, `min_max` show their sub-leaf instead.
2. `stable_first5` when the recipe is `implemented=no` — blank, or show the raw
   values greyed with a "not yet executable" note?
3. Keep `guess_data_type` as the column name even though it holds a leaf label
   (not a `data_type`)? `guess_label` is more honest; `guess_data_type` matches
   `desired_data_type`.
