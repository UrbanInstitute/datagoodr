# Step 5: Customization framework — design notes

Aligned 2026-07-10 (from pptx/LAYOUTS deck + discussion).

## Philosophy

Rule-based, not script-based, data management. The **DGF is the rules file**;
a small rendering engine (QMD template + layout objects + functions) turns
those rules into documentation. Defaults must be fast and good enough for users
who never customize; the framework must also be highly adaptable.

## Three customization layers

1. **Content/structure** — layout objects map, per data type: div -> variable
   attribute -> label -> render function. (R/03-01-layouts.R)
2. **Presentation** — the CSS `<style>` grid in the QMD template.
3. **Behavior** — formatting/graphic functions (`v_to_txt`, `paste_*`, `get_*`),
   user-overridable via a project `DG.R`.

## Key decisions

- **Layout home:** defaults ship in the package; the QMD template (or `DG.R`)
  may override them. Non-customizers get good defaults automatically.
- **Two flavors:** `DD` (data dictionary — metadata only: label/type/scope/
  length/description/levels/location) and `RG` (research guide — DD + full data
  profile). DD = the RG layout filtered to the dictionary render functions
  (`v_to_txt`, `paste_levels`).
- **`DG.R` auto-source:** the template sources a project `DG.R` at render if
  present, so functions named in a layout resolve (custom or default).

## Project directory (orchestration)

```
my-project/
  data/                  raw + versioned data
  DGF.xlsx               the rules file (governance)
  DG.R                   custom formatting/graphing functions (auto-sourced)
  research-guide.qmd     (or data-dictionary.qmd) narrative + auto + granular calls
  _output/               rendered html/pdf
```

## Component status (start of Step 5)

- exists: layout objects, CSS, formatting/graphic fns, create_dgf/inspect_dgf/
  update_dgf.
- backbone (this phase): `inst/templates/` (RG.qmd, DD.qmd, DG.R),
  `use_datagoodr_template()`, `create_rg()`, `create_dd()`, DG.R sourcing,
  `get_design(style=)` + `create_all_sections(style=, layouts=)` for DD/RG and
  layout override.
- granular per-variable API (DONE 2026-07-10): engine decoupled from the
  `xx`/`all.layouts` globals via a package context env (get_xx/set_xx);
  dg_section()/dg_stats()/dg_quantiles()/dg_properties()/dg_preview()/
  dg_levels()/dg_graphic()/dg_field() render one variable or one element inline.
- later: aesthetic pass (CSS + gt color tables, ydata-inspired),
  standardize()/format()/create_vr(), date/time data type.

## Build order

1. Backbone (templates + create_rg/create_dd + DG.R sourcing).  <- current
2. Composability (granular `dg_*()` API).
3. Aesthetics.
4. standardize/format/create_vr, date type.
