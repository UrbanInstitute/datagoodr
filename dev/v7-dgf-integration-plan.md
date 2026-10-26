# v7 DGF integration — columns kept, and which formex API fills each

Written 2026-10-26, against formex `main` @ `6456e24` ("v7 step 1:
transformability as a path search") and its `ONTOLOGY-V7-PLAN.md`. Supersedes the
column layout in `dev/schema-simplification-plan.md` by binding it to the actual
v7 API.

## What formex v7 gives us (and what it does not, yet)

**Landed and callable now** (`R/22-fx-transform-path.R`, exported):

| API | returns | we use it for |
|---|---|---|
| `fx_format(semantic_type, format_style, unit_type)` | an `fx_format` descriptor | expressing a column's current and desired form |
| `fx_plan_transform(from, to)` | an `fx_plan`: `transformable`, `path`, `reason` | the **stabilizer** cell + whether one is needed |
| `fx_transformable(from, to)` | logical | the `stabilizer_needed` / reachability flag |
| `fx_apply_plan(x, plan)` | values transformed | the **`stable_first5`** preview |
| `fx_transforms()` | the edge registry | introspection; grows as v7 wires recipes |

**Not landed yet (future v7 steps — our testing gate):**

1. The ontology still ships `format_label` (v6); the `format_style` + `unit_type`
   split is steps 1–4 of `ONTOLOGY-V7-PLAN.md` §5, not built.
2. `guess_data_type()$route` still emits `format_label` + `dd_unit`, **not**
   `format_style`/`unit_type`. The detector does not resolve the two axes yet.
3. `fx_transforms()` is a **seed**: temperature (`C↔F`), two calendar styles, one
   fiscal-year read. For almost every real column `fx_plan_transform()` returns
   **not transformable** until the registry is grown from ontology recipes.

**Therefore:** the draft wires every column to its API but is **frozen before
testing**. It must build and pass the existing (v6) suite unchanged — the v7 path
is additive and gated on the API being present — and the v7 DGF revisions are
tested only once formex v7's detector + ontology + grown registry are installed.

## The forward-compat seam

The one place the two formex generations differ is the `$route` axis fields.
A single shim absorbs it:

```r
.route_axes(r)  ->  list(format_style=, unit_type=)
   # v7:  r$format_style, r$unit_type            (when present)
   # v6:  derive style from r$format_label, unit from r$dd_unit
```

Everything downstream (label selection, the `fx_format` descriptors, the plan)
reads `.route_axes()`, so when formex v7's detector lands, only this shim changes.

## The v7 DGF columns — kept, renamed, new — and their source

| column | kept / new | populated by | notes |
|---|---|---|---|
| `var_name` | kept | — | key |
| `dd_vname_alias`, `dd_vlabel`, `dd_vdesc` | kept | human | data dictionary |
| `raw_first5` | kept | datagoodr profiler | verbatim first 5 raw values |
| `raw_data_mode` | **renamed** (was `raw_data_type`) | datagoodr profiler | R storage mode as read |
| `guess_semantic_type` | new | `guess_data_type()$route$semantic_type` | leaf label base |
| `guess_format_style` | new | `.route_axes()` ← `$route` (v7) / `format_label` (v6) | written-rendering axis |
| `guess_unit_type` | new | `.route_axes()` ← `$route` (v7) / `$dd_unit` (v6) | unit axis; often `NA` |
| `guess_label` | new | datagoodr derives | deepest named rung `+ {{ family :: data_type }}` (see label rule) |
| `guess_match_kind` | new | `$route$match_kind` | honesty column |
| `guess_confidence`, `guess_depth`, `guess_variant_id` | new | `$route` | provenance (adapter already computes) |
| — legacy fallback — | | `$guess` + `$ontology` | taken where the route truncates (zero-padded keys, email) |
| `desired_semantic_type` | kept (from `desired_data_type`) | human | confirmed/overridden |
| `desired_format_style` | new | human; default from ontology `desired_default_format` | render target |
| `desired_unit_type` | new | human | target unit — a differing value is what makes `convert_*` fire |
| `stabilizer_needed` | new | **`fx_transformable(from,to)`** + identity check | `no` when from≡to |
| `stabilizer` | kept (was `raw_to_stable_transform`) | **`fx_plan_transform(from,to)$path`** rendered `read :: [convert] :: write` | — |
| `stabilizer_status` | new | derived from the plan | `ready` / `not-transformable (reason)` / `proposed (recipe unimplemented)` |
| `stable_first5` | new | **`fx_apply_plan(raw_first5, plan)`** | blank when the plan is not `ready` |
| `load_rule_needed` | kept (was `import_rule_needed`) | derived: stable storage mode vs desired R type | |
| `load_rule` | kept (was `desired_data_import_rule`) | ontology `stable_import_rule`, as `read_<style>` | |
| `validate_rules`, `validate_format` | kept | human / rules | unchanged |
| `rg_*` | kept | datagoodr render pipeline | JSON strings, unchanged |
| `prov_*` | kept | datagoodr | provenance hashes, unchanged |

**Dropped:** `desired_data_class` (its dotted `family.type` is implied by the
label). `raw_data_format` folds into `guess_format_style`.

### The `from` / `to` descriptors (the heart of it)

```r
from <- fx_format(guess_semantic_type, guess_format_style, guess_unit_type)
to   <- fx_format(desired_semantic_type, desired_format_style, desired_unit_type)
plan <- fx_plan_transform(from, to)
#   plan$transformable -> stabilizer_needed / stabilizer_status
#   plan$path          -> stabilizer cell  (read :: [convert] :: write)
#   fx_apply_plan(raw_first5, plan) -> stable_first5
```

This is why temperature is the proof case: `from=(temperature,celsius,C)`,
`to=(temperature,fahrenheit,F)` resolves through `read_celsius :: convert_C_F ::
write_fahrenheit`, and `stable_first5` shows the converted values. A
fiscal→calendar year request comes back `not-transformable` with a reason,
because no converter is registered — the DGF states that honestly instead of
guessing.

### The label rule (unchanged from the simplification plan)

`guess_label` = deepest resolved rung with a human name:
`format_style`(leaf) → `semantic_type` → `semantic_family` → `data_type`, written
`<leaf> {{ family :: data_type }}`. The two uniqueness breakers (`geographic`
categorical-vs-identifier, `mixed` boolean-vs-unknown) keep the cardinality
tie-break the adapter already applies.

> **Status — finalized 2026-10-26.** formex v7 (steps 2–5) is installed; the
> gate is cleared. `guess_dgf_types()` now emits the `guess_*` axes,
> `create_dgf()` builds the v7 schema (additively — the render/stabilize contract
> columns are retained), and the stabilizer plan + `stable_first5` resolve against
> the 108-edge ontology-derived registry. Full suite: **492 passing, 0 failures**.
> The one deviation from the literal plan below: the v7 columns were *added*
> rather than the legacy `desired_data_*` being *dropped*, because `desired_data_type`
> drives the render engine across 20 files; porting rendering onto
> `desired_semantic_type` is the remaining non-blocking follow-up.

## Build order (draft now; starred steps gated on formex v7)

1. **Draft, committed now:** `R/01-08-stabilizer-plan.R` — `.route_axes()` shim,
   `.dgf_fx_format()` builders, `plan_stabilizer()` wrapping
   `fx_plan_transform`/`fx_apply_plan`, and `dgf_schema_cols_v7()`. All gated on
   `.formex_has_v7()`; a no-op when the installed formex lacks the API. The live
   `create_dgf()` / `dgf_schema_cols()` are **not** switched — the v6 path and its
   tests are untouched.
2. ★ **Wire `guess_dgf_types()`** to populate the `guess_*` axis columns from
   `.route_axes()` — once formex v7's detector resolves `format_style`/`unit_type`.
3. ★ **Flip `create_dgf()`** to `dgf_schema_cols_v7()` and add the v7 regression
   fixtures (the Part 2 columns + the temperature/fiscal cases).
4. ★ **Finalize** once formex v7 is installed and the grown registry makes real
   columns transformable: run the suite, update vignettes, retire v6 schema.

Steps 2–4 are the "test DGF revisions before finalizing" gate. Step 1 is safe to
land today because it changes no default path.
