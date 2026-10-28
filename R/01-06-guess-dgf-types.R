##############################
### Guess-based DGF type enrichment
###############################
## THE FORMEX SEAM. Detection lives in the formex package; this file is
## datagoodr's adapter over it. Everything here is workflow --- how a column
## prediction becomes DGF coordinates --- and nothing here is detection.
##
## Runs formex::guess_data_type() over each column of the raw data and refines
## the coarse R-storage typing that create_dgf() starts from:
##   * fills the (blank) desired_data_class with the ontology role, written as
##     `class.subclass` (dotted), when a detector confidently matches;
##   * refines desired_data_type for coarse ("text") columns and for strong
##     semantic guesses (temporal / identifier);
##   * promotes a geographic CATEGORICAL to an IDENTIFIER when the column is
##     near-unique (a key, not a grouping var), and flags dd_is_join_key.
##
## formex's legacy crosswalk still speaks the (type, subtype, class, format)
## vocabulary and is returned as `$ontology`; .to_class_subclass() translates a
## detector's (subtype, class, format) into the v4 `class.subclass` the DGF
## currently carries. Both are read from the PUBLIC return value --- this file
## touches no formex internals.
##
## NOTE: formex now also returns a v6 `$route` record (a 4-level path plus
## semantic_type_id / variant_id / depth / confidence). Consuming it, and
## retiring .to_class_subclass(), is the next phase of the reintegration --- see
## dev/formex-reintegration-plan.md. Measured, the route and the legacy $guess
## are COMPLEMENTARY: the route resolves dates/states/years that the detectors
## miss, and misroutes every zero-padded numeric key (FIPS, ZIP, EIN) to
## number/quantity/count. The adapter must read both, with a storage-safety gate.
##
## It is intentionally conservative: it never overrides a number/categorical/
## boolean base type from a loose detector, so a count column that happens to
## look like a Unix timestamp stays a number. Columns with no confident match
## are left exactly as create_dgf() typed them.


## Call formex's classifier, muffling ONE known-noisy upstream warning.
##
## formex's v6 verifier runs an `as_integer` coercion over every candidate
## recipe, which emits "NAs introduced by coercion to integer range" on ordinary
## large-numeric columns. It is diagnostic noise from a probe that is SUPPOSED to
## fail for non-integer candidates, and profiling a wide frame emits it once per
## column. Muffled narrowly, by message, so every other warning still surfaces.
## Remove once fixed upstream (see dev/formex-reintegration-plan.md, Part 6).
#' @keywords internal
#' @noRd
.formex_guess <- function(vals, name = NULL, seed = NULL, n_sample = NULL) {
  ## n_sample is passed only when asked for, so the installed formex keeps
  ## control of its own default.
  args <- list(vals, name = name, seed = seed)
  if (!is.null(n_sample)) args$n_sample <- n_sample
  withCallingHandlers(
    do.call(formex::guess_data_type, args),
    warning = function(w) {
      if (grepl("NAs introduced by coercion", conditionMessage(w), fixed = TRUE))
        invokeRestart("muffleWarning")
    }
  )
}


## ---- why the formex call is hoisted out of the decision loop ---------------
##
## MEASURED (formex 0.0.0.9000, baseball 4,620 x 19): guess_data_type() is 63%
## of create_dgf() -- far more than the rg_* profiles, which are under 7%. Two
## properties of that cost shape the design here:
##
##   1. It is FLAT in nrow. formex samples `n_sample = 100` values internally,
##      so 100 rows cost the same as 4,620 (~5.5s either way). Row subsampling
##      on this side buys nothing; the cost is PER COLUMN (~0.29s, of which a
##      ~0.126s floor is paid even by a 10-value vector) and the dominant term
##      is the router -- `route = FALSE` drops 5.7s to 1.4s.
##   2. It is independent per column. The decision logic in guess_dgf_types()
##      below is pure bookkeeping on one column's answer, so the only part worth
##      distributing is the guess itself.
##
## Hence: fetch every column's guess up front (optionally on a worker pool),
## then run the unchanged decision loop over the results.
##
## `seed` exists because formex's internal sample is drawn from the session RNG.
## Left to chance, create_dgf() is NOT REPRODUCIBLE: measured across four runs
## of the same frame, `weight` moved between number/quantity/measurement and a
## bare number, `AB` between identifier and number, and `AVG` landed on
## text/web/domain once -- and those disagreements reach desired_data_type in
## the written DGF. A fixed seed makes the build repeatable and is also what
## lets the parallel path return results identical to the serial one.
##
## `n_sample` addresses the same instability at its source. formex's default of
## 100 is smaller than the distinct-value count of many real columns, so the
## confidence it reports is a sample statistic, and columns sitting near
## `route_threshold` flip on it. MEASURED on bb.csv `birthState` (210 distinct
## values), confidence over six seeds:
##
##   n_sample = 100  ->  0.631 - 0.905  (sd 0.108)  straddles the 0.8 threshold
##   n_sample = 300  ->  0.813 - 0.813  (sd 0)      stable, and above it
##
## Raising it is therefore both a determinism fix and a better answer --- at
## 300 the column resolves to mutually_exclusive.geographic instead of falling
## back to text, and `AVG` stops carrying a spurious text:web:domain class.
## create_dgf() now defaults it to 300: that covers most real columns
## exhaustively, and the formex-side speedup (lecy/formex@3d812d2) paid for the
## extra work. The cost is real but bounded, and falls on high-cardinality
## columns, where a larger sample is doing more actual checking --- `birthState`
## 0.50s -> 0.82s, `AB` up to ~1.4s, since the sample stops being a shortcut.
## Above the distinct count the draw is merely reproducible (see `seed`), not
## complete; an adaptive min(n_distinct, cap) would be better still, but that
## belongs in formex.
#' @keywords internal
#' @noRd
.formex_guess_all <- function(df, workers = 1L, seed = NULL, n_sample = NULL) {

  vars <- names(df)
  vals <- lapply(df, as.character)
  n    <- length(vars)

  workers <- suppressWarnings(as.integer(workers))
  if (length(workers) != 1L || is.na(workers)) workers <- 1L
  workers <- min(workers, n)

  if (workers <= 1L || n <= 1L)
    return(lapply(seq_len(n), function(i) .formex_guess(vals[[i]], name = vars[i],
                                                        seed = seed,
                                                        n_sample = n_sample)))

  if (!requireNamespace("parallel", quietly = TRUE))
    return(lapply(seq_len(n), function(i) .formex_guess(vals[[i]], name = vars[i],
                                                        seed = seed,
                                                        n_sample = n_sample)))

  ## Self-contained worker: reaches only for formex::, and its environment is
  ## reset to globalenv() so serialising it to a PSOCK worker does not drag
  ## datagoodr's namespace along (which may not be installed there under
  ## pkgload::load_all()).
  fx <- function(vals, name, seed, n_sample) {
    args <- list(vals, name = name, seed = seed)
    if (!is.null(n_sample)) args$n_sample <- n_sample
    withCallingHandlers(
      do.call(formex::guess_data_type, args),
      warning = function(w) {
        if (grepl("NAs introduced by coercion", conditionMessage(w), fixed = TRUE))
          invokeRestart("muffleWarning")
      }
    )
  }
  environment(fx) <- globalenv()

  cl <- try(parallel::makePSOCKcluster(workers), silent = TRUE)
  if (inherits(cl, "try-error"))
    return(lapply(seq_len(n), function(i) .formex_guess(vals[[i]], name = vars[i],
                                                        seed = seed,
                                                        n_sample = n_sample)))
  on.exit(try(parallel::stopCluster(cl), silent = TRUE), add = TRUE)

  ok <- unlist(parallel::clusterEvalQ(
          cl, requireNamespace("formex", quietly = TRUE) ))
  if (!all(ok)) {
    warning("formex is not available on the worker processes; ",
            "guessing column types sequentially.", call. = FALSE)
    return(lapply(seq_len(n), function(i) .formex_guess(vals[[i]], name = vars[i],
                                                        seed = seed,
                                                        n_sample = n_sample)))
  }

  res <- parallel::clusterMap(cl, fx, vals, vars,
                              MoreArgs = list(seed = seed, n_sample = n_sample),
                              SIMPLIFY = FALSE, USE.NAMES = FALSE)
  unname(res)
}

## ---- the storage-safety gate ----------------------------------------------
##
## formex's v6 router misroutes zero-padded numeric keys. Measured on realistic
## columns (formex 0.0.0.9000, 2026-08-22):
##
##   county FIPS  -> number/quantity/count  depth 3  conf 0.87
##   state FIPS   -> number/quantity/count  depth 3  conf 0.97
##   ZIP codes    -> number/quantity/count  depth 3  conf 0.86
##
## Acting on that would re-type 06037 as a number and hand back 6037 --- exactly
## the corruption create_dgf(read_as_text = TRUE) exists to prevent. A
## confident-but-wrong route is more dangerous than no route, so confidence
## alone cannot be the guard.
##
## The guard is the SAME predicate that governs read-as-text promotion:
## .safe_numeric() already refuses leading-zero integers and integers past the
## 2^53 exact range. If a column may not be promoted to numeric, then no
## number/* route may re-type it either. One rule, both directions.
#' @keywords internal
#' @noRd
.route_is_storage_safe <- function(route, vals) {
  if (is.null(route) || is.na(route$data_type)) return(TRUE)
  if (!identical(route$data_type, "number")) return(TRUE)
  .safe_numeric(vals)
}

## Is the route resolved to a confident LEAF? v6 truncates gracefully: depth 4
## means it pinned a format_label and earned a variant_id; anything shallower is
## a path prefix the verifier could not defend, and the legacy detectors are
## measurably better on those.
#' @keywords internal
#' @noRd
## TRUE when the route resolved a semantic TYPE confidently (depth >= 3), even
## if it stopped short of a format leaf (depth 4). A confident categorical/
## geographic at depth 3 (e.g. a birthCity column) still carries a usable
## data_type + class, so it should be adopted rather than discarded to text; the
## format_label/variant is simply left blank. The confidence bar still applies,
## so a genuinely low-confidence path (a non-US-heavy place column at 0.77) is
## not forced.
.route_is_leaf <- function(route, threshold = 0.8) {
  !is.null(route) &&
    isTRUE(as.integer(route$depth) >= 3L) &&
    !is.na(route$confidence) && route$confidence >= threshold &&
    !is.na(route$semantic_family) && !is.na(route$semantic_type)
}

## The v6 path as the DGF's dotted `class.subclass`.
##
## No translation table is needed: 35 of the 38 dotted values the legacy shim
## can emit ARE valid v6 `semantic_family.semantic_type` coordinates. The v4
## vocabulary is a subset of v6's, so the DGF column already speaks v6.
#' @keywords internal
#' @noRd
.route_class_subclass <- function(route) {
  paste0(route$semantic_family, ".", route$semantic_type)
}

## Is the winning detector a LOOSE one (fires broadly)? formex's candidate table
## carries a `specific` flag per candidate; the winner is the first row. Reading
## it here keeps datagoodr off formex's internal `.loose_detectors`.
#' @keywords internal
#' @noRd
.guess_is_loose <- function(g) {
  cand <- g$candidates
  if (is.null(cand) || !nrow(cand) || !"specific" %in% names(cand)) return(FALSE)
  hit <- which(cand$data_type == g$guess)
  if (!length(hit)) return(FALSE)
  !isTRUE(cand$specific[hit[1]])
}

## ontology data_type -> the DGF's desired_data_type vocabulary. structured and
## unknown fall back to text, which the render engine handles via the character
## path (dg_type_of / .dgf_vclass_of).
#' @keywords internal
#' @noRd
.ontology_to_dgf_type <- function(t) {
  switch(t,
    number      = "number",
    categorical = "categorical",
    boolean     = "boolean",
    temporal    = "temporal",
    identifier  = "identifier",
    text        = "text",
    structured  = "text",
    unknown     = "text",
    "text")
}

## Legacy crosswalk (subtype, class, format) -> v4 `class.subclass`. Keyed on the
## legacy data_class, with data_subtype disambiguating hash IDs and data_format
## naming the color model. Returns "" for a class with no v4 mapping (e.g. a
## bare number, whose default class is left blank).
#' @keywords internal
#' @noRd
.to_class_subclass <- function(subtype, cls, fmt) {
  switch(cls,
    category            = "mutually_exclusive.unordered",
    group               = "mutually_exclusive.unordered",
    geography           = "mutually_exclusive.geographic",
    classification_code = "mutually_exclusive.classification_code",
    administrative_code = "mutually_exclusive.classification_code",
    ordered_category    = "mutually_exclusive.ordered",
    missingness_reason  = "mutually_exclusive.missingness_reason",
    email               = "contact.email",
    phone               = "contact.phone",
    url                 = "web.url",
    network_address     = "web.ip",
    color               = paste0("color.", if (nzchar(fmt)) fmt else "hex"),
    address             = "postal.full",
    person_name         = "name.person",
    organization_name   = "name.organization",
    place_name          = "name.place",
    label               = "text.label",
    title               = "text.title",
    text                = "text.long",
    long_text           = "text.long",
    record_id           = if (identical(subtype, "hash_id")) "id.hash" else "id.record",
    entity_id           = "id.entity",
    administrative_id   = "id.administrative",
    geographic_id       = "id.geographic",
    version_id          = "id.version",
    calendar_date       = "date.calendar",
    timestamp           = "date.timestamp",
    time_of_day         = "time.clock",
    year                = "period.year",
    quarter             = "period.quarter",
    month               = "period.month",
    semester            = "period.semester",
    season              = "period.season",
    reporting_period    = "period.reporting_period",
    hour_of_day         = "phase.hour_of_day",
    day_of_week         = "phase.day_of_week",
    week_of_year        = "phase.week_of_year",
    month_of_year       = "phase.month_of_year",
    season_of_year      = "phase.season_of_year",
    date_range          = "interval.date_range",
    currency            = "currency.usd",
    "")
}

## v4 temporal `class.subclass` -> the render grain that selects the graphic.
## Replaces the old stable_data_unit lookup: the render engine now derives the
## grain from desired_data_class, so the grain travels with the type, not a
## separate unit column.
#' @keywords internal
#' @noRd
.temporal_grain <- function(class_subclass) {
  sub <- sub("^[^.]*\\.?", "", as.character(class_subclass))  # drop the class part
  switch(sub,
    calendar = "date", timestamp = "date", date_range = "date",
    clock = "hour", hour_of_day = "hour",
    year = "year", quarter = "quarter",
    month = "month", month_of_year = "month",
    day_of_week = "dow", week_of_year = "week",
    "date")
}

#' Refine DGF types from formex, reading both of its answers
#'
#' formex returns two predictions per column and they are **complementary** ---
#' neither dominates, so this reads both:
#'
#' * the **v6 `$route`** (a 4-level path plus `variant_id`, truncating
#'   gracefully to `depth` 0-4). Wins when it resolves to a leaf. It reaches
#'   types no detector emits --- a bare four-digit year is
#'   `temporal/period/year` to the router and nothing at all to the detectors.
#' * the **legacy `$guess`** (a detector name at a pass rate). Wins where the
#'   route truncates, which is every zero-padded numeric key and email.
#'
#' Resolution order, with a storage-safety gate on the route:
#'
#' \preformatted{
#'   route depth 4, confident, storage-safe -> take the route
#'   otherwise, legacy guess confident      -> take the legacy guess
#'   neither                                -> keep the base type, record depth
#' }
#'
#' @param df The raw data frame (columns to profile).
#' @param base_type Character vector of the create_dgf base `desired_data_type`
#'   per column (ontology vocabulary), same length/order as `names(df)`.
#' @param distinct_threshold Share of distinct non-missing values above which a
#'   geographic categorical is promoted to an identifier (a key).
#' @param route_threshold Minimum route confidence for a depth-4 leaf to be
#'   taken over the legacy guess.
#' @param workers Integer; how many processes to spread the per-column formex
#'   calls over. `1` (the default) stays in-process. See `.formex_guess_all()`
#'   for why the guess, and not the profiling, is the part worth distributing.
#' @param seed Integer or `NULL`; seed handed to `formex::guess_data_type()` so
#'   its internal 100-value sample - and therefore the whole DGF - is
#'   reproducible. `NULL` restores the old session-RNG behaviour.
#' @param n_sample Integer or `NULL`; how many values formex samples per column.
#'   Defaults to `300`; `NULL` leaves formex's own default (100). The sample is
#'   drawn from the distinct values, so confidence is stable exactly when
#'   `n_sample >= n_distinct` - see `.formex_guess_all()`.
#'
#' @return A data frame, one row per column: `desired_data_type`,
#'   `desired_data_class` (dotted `class.subclass`), `dd_is_join_key`, and the
#'   decision's provenance --- `route_variant_id`, `route_depth`,
#'   `route_confidence`. Columns with no confident answer from either modality
#'   carry the base type and a blank class, with `route_depth` recording how far
#'   detection actually got.
#' @seealso [.route_is_storage_safe()], which is why a confident `number/*`
#'   route cannot re-type a zero-padded key.
#' @keywords internal
#' @noRd
guess_dgf_types <- function(df, base_type, distinct_threshold = 0.9,
                            route_threshold = 0.8,
                            workers  = getOption("datagoodr.workers", 1L),
                            seed     = getOption("datagoodr.guess_seed", 1L),
                            n_sample = getOption("datagoodr.guess_n_sample", 300L)) {
  vars <- names(df)

  ## every column's formex answer, fetched up front (see .formex_guess_all())
  guesses <- .formex_guess_all(df, workers = workers, seed = seed,
                               n_sample = n_sample)

  out <- data.frame(
    desired_data_type  = base_type,
    desired_data_class = rep("", length(vars)),
    dd_is_join_key     = rep("", length(vars)),
    ## v7 guess_* axes: what formex's route detected, recorded verbatim so the
    ## DGF carries the machine proposal next to the human's desired_* answer.
    ## The route is the natural source for these (the two-axis leaf lives there);
    ## the legacy $guess still drives desired_data_type below where it wins.
    guess_label        = rep("", length(vars)),
    guess_semantic_type = rep("", length(vars)),
    guess_format_style = rep("", length(vars)),
    guess_unit_type    = rep("", length(vars)),
    guess_match_kind   = rep("", length(vars)),
    guess_variant_id   = rep("", length(vars)),
    guess_depth        = rep(NA_integer_, length(vars)),
    guess_confidence   = rep(NA_real_, length(vars)),
    stringsAsFactors = FALSE
  )

  for (i in seq_along(vars)) {
    vals <- as.character(df[[i]])
    g <- guesses[[i]]
    r <- g$route

    nn  <- vals[!is.na(vals) & nzchar(trimws(vals))]
    pct <- if (length(nn)) length(unique(nn)) / length(nn) else 0
    safe <- .route_is_storage_safe(r, vals)

    ## Record the route's two-axis leaf once, regardless of which modality wins
    ## the desired type. .route_axes() reads v7 format_style/unit_type when the
    ## installed formex emits them, else derives them from v6 format_label/dd_unit.
    if (!is.null(r)) {
      ax <- .route_axes(r)
      ## DEV: record the full resolved path (data_type:semantic_family:
      ## semantic_type), truncated to the lowest level the route actually
      ## reached, so the DGF shows where typing stopped. The functional
      ## consumers (.dgf_fx_format, .desired_default_style) take the leaf.
      out$guess_semantic_type[i] <- {
        p <- c(r$data_type, r$semantic_family, r$semantic_type)
        p <- p[!is.na(p) & nzchar(p)]
        if (length(p)) paste(p, collapse = ":") else ""
      }
      out$guess_format_style[i]  <- if (is.na(ax$format_style)) "" else ax$format_style
      out$guess_unit_type[i]     <- if (is.na(ax$unit_type)) "" else ax$unit_type
      out$guess_match_kind[i]    <- if (is.null(r$match_kind) || is.na(r$match_kind)) "" else r$match_kind
      out$guess_label[i]         <- .guess_label(r, ax)
    }

    ## ---- MODALITY 1: a confident v6 leaf ---------------------------------
    ## Preferred when it resolves all the way down, because it carries the
    ## ontology coordinate directly and reaches types no detector emits (a bare
    ## four-digit year is temporal/period/year to the router; the legacy
    ## detectors return nothing at all for it).
    ##
    ## But depth and confidence are NOT sufficient on their own. MEASURED: a
    ## column of rnorm() doubles routes to text/web/domain at depth 4 with
    ## confidence 1.0, because "-0.6264538" parses as a domain. So the route
    ## gets the same conservatism the legacy path has always had --- it may
    ## refine a coarse ("text") base type, or supply a strong semantic signal
    ## (temporal/identifier), but it may not overturn a base type create_dgf()
    ## already determined from storage.
    if (.route_is_leaf(r, route_threshold) && safe) {
      gtype <- .ontology_to_dgf_type(r$data_type)
      cs    <- .route_class_subclass(r)
      override <- (base_type[i] == "text") ||
                  (gtype %in% c("temporal", "identifier"))

      if (override || identical(gtype, base_type[i])) {
        if (override) out$desired_data_type[i] <- gtype
        out$desired_data_class[i] <- cs
        out$guess_variant_id[i]   <- if (is.na(r$variant_id)) "" else r$variant_id
        out$guess_depth[i]        <- as.integer(r$depth)
        out$guess_confidence[i]   <- as.numeric(r$confidence)
        if (out$desired_data_type[i] == "identifier" && pct >= distinct_threshold)
          out$dd_is_join_key[i] <- "TRUE"
        next
      }
      ## the route contradicts a confident base type -> record how far it got,
      ## stamp nothing, and fall through to the detectors.
      out$guess_depth[i]      <- as.integer(r$depth)
      out$guess_confidence[i] <- as.numeric(r$confidence)
    }

    ## ---- MODALITY 2: the legacy detector guess ---------------------------
    ## Where the route truncates, the detectors are measurably better: every
    ## zero-padded key (FIPS, ZIP, EIN) and email routes shallow or wrong but
    ## detects at pass rate 1.0. This is the original v4 path, unchanged.
    if (is.na(g$guess)) {
      ## ---- MODALITY 3: a shallow route is still an honest partial answer --
      ## Record the depth so a truncated path reads as work-for-the-human
      ## rather than a finished label. The base type is left as create_dgf()
      ## typed it; we only note how far detection actually got.
      if (!is.null(r) && !is.na(r$depth)) {
        out$guess_depth[i]      <- as.integer(r$depth)
        out$guess_confidence[i] <- as.numeric(r$confidence)
      }
      next
    }

    o     <- g$ontology
    otype <- o[["data_type"]]
    gtype <- .ontology_to_dgf_type(otype)
    sub   <- o[["data_subtype"]]
    cls   <- o[["data_class"]]
    fmt   <- o[["data_format"]]
    cs    <- .to_class_subclass(sub, cls, fmt)

    ## the legacy detector answered, so record how far the route got alongside
    ## it --- the two modalities disagree often enough to be worth auditing.
    if (!is.null(r) && !is.na(r$depth)) {
      out$guess_depth[i]      <- as.integer(r$depth)
      out$guess_confidence[i] <- as.numeric(r$confidence)
    }

    ## cardinality promotion: a near-unique geographic categorical is a key
    if (otype == "categorical" && cls == "geography" && pct >= distinct_threshold) {
      gtype <- "identifier"
      cs    <- "id.geographic"
    }

    ## a column already typed identifier (by detect_identifier) that the
    ## detectors recognize as a geography is a geographic KEY.
    if (base_type[i] == "identifier" && otype == "categorical" && cls == "geography") {
      gtype <- "identifier"
      cs    <- "id.geographic"
    }

    ## only OVERRIDE the base type when it is coarse ("text") or the guess is
    ## a strong semantic signal (temporal/identifier) from a NON-loose detector
    ## "loose" = the winning detector fires broadly (phone, unix_time, bare
    ## numeric codes). formex marks this per candidate as `specific`; read it
    ## off the public candidate table rather than reaching for its internals.
    loose <- .guess_is_loose(g)
    override <- (base_type[i] == "text") ||
                (gtype %in% c("temporal", "identifier") && !loose)

    if (override) {
      out$desired_data_type[i] <- gtype
    } else if (gtype != base_type[i]) {
      ## base kept but guess disagrees -> don't stamp an inconsistent class
      next
    }
    out$desired_data_class[i] <- cs
    ## flag a join key when the column is an identifier AND near-unique
    if (out$desired_data_type[i] == "identifier" && pct >= distinct_threshold) {
      out$dd_is_join_key[i] <- "TRUE"
    }
  }
  out
}
