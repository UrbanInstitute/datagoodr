# The research guide has three styles: "rail" (the default), "compact" (the
# same guide condensed for documentation) and "vintage" (the original
# three-column grid). Each has its own template and stylesheet.

scaffold <- function(style = NULL) {
  d <- tempfile("rg-style"); dir.create(d)
  args <- list(dgf = build_demo_dgf(), dir = d, file = "rg.qmd",
               render = FALSE, overwrite = TRUE)
  if (!is.null(style)) args$style <- style
  suppressMessages(suppressWarnings(utils::capture.output(do.call(create_rg, args))))
  d
}

test_that("create_rg scaffolds the rail template by default", {
  d <- scaffold()
  txt <- readLines(file.path(d, "rg.qmd"), warn = FALSE)
  expect_true(any(grepl("rail_sections(", txt, fixed = TRUE)))
  css <- file.path(d, "datagoodr.css")
  expect_true(file.exists(css))
  expect_true(any(grepl(".dg-unit", readLines(css), fixed = TRUE)))
})

test_that("style = 'vintage' scaffolds the original grid", {
  d <- scaffold("vintage")
  txt <- readLines(file.path(d, "rg.qmd"), warn = FALSE)
  expect_true(any(grepl("create_all_sections(", txt, fixed = TRUE)))
  expect_true(any(grepl('datagoodr_css("vintage")', txt, fixed = TRUE)))
  expect_true(file.exists(file.path(d, "datagoodr-vintage.css")))
})

test_that("style = 'compact' scaffolds the condensed guide", {
  d <- scaffold("compact")
  txt <- readLines(file.path(d, "rg.qmd"), warn = FALSE)
  expect_true(any(grepl('rail_sections( groups$Boolean, "Boolean", style = "compact" )',
                        txt, fixed = TRUE)))
  expect_true(any(grepl('datagoodr_css("compact")', txt, fixed = TRUE)))
  expect_true(file.exists(file.path(d, "datagoodr-compact.css")))
  # it is the rail renderer at a higher density, not the vintage grid
  expect_false(any(grepl("create_all_sections(", txt, fixed = TRUE)))
})

test_that("datagoodr_css picks the right sheet, and old projects keep theirs", {
  rail    <- datagoodr_css("rail")
  vintage <- datagoodr_css("vintage")
  compact <- datagoodr_css("compact")
  expect_true(grepl(".dg-unit", rail, fixed = TRUE))
  expect_true(grepl(".parent", vintage, fixed = TRUE))
  expect_false(grepl(".dg-unit", vintage, fixed = TRUE))
  # compact is its own sheet: same rail structure, its own density
  expect_true(grepl(".dg-unit", compact, fixed = TRUE))
  expect_false(identical(compact, rail))

  # an older project: a local datagoodr.css that is the vintage sheet
  d <- tempfile("old-proj"); dir.create(d)
  writeLines(c("/* my old styles */", ".parent { color: red; }"),
             file.path(d, "datagoodr.css"))
  owd <- setwd(d); on.exit(setwd(owd))
  expect_match(datagoodr_css(), "my old styles", fixed = TRUE)            # legacy call
  expect_match(datagoodr_css("vintage"), "my old styles", fixed = TRUE)   # still theirs
  expect_false(grepl("my old styles", datagoodr_css("rail"), fixed = TRUE)) # not for rail
})

test_that("rail_groups splits by render type in display order", {
  g <- rail_groups(build_demo_dgf())
  expect_named(g, c("Boolean", "Categorical", "Numeric", "Text",
                    "Identifier", "Temporal"))
  expect_true(all(vapply(g, is.data.frame, logical(1))))
})

test_that("rail sections render a unit per variable with rail and body", {
  dgf <- build_demo_dgf()
  g <- rail_groups(dgf)
  out <- suppressMessages(suppressWarnings(capture.output({
    rail_contents(g)
    for (k in names(g)) rail_sections(g[[k]], k)
  })))
  expect_equal(sum(startsWith(out, "::::: {.dg-unit")), nrow(dgf))
  expect_true(any(grepl("dg-rail", out, fixed = TRUE)))
  expect_true(any(grepl("dg-body", out, fixed = TRUE)))
  expect_true(any(grepl('class="toc"', out, fixed = TRUE)))
})

test_that("compact renders the same blocks as rail, shorter", {
  dgf <- build_demo_dgf()
  g   <- rail_groups(dgf)
  run <- function(style) suppressMessages(suppressWarnings(capture.output(
    for (k in names(g)) rail_sections(g[[k]], k, style = style))))

  rail    <- run("rail")
  compact <- run("compact")

  # every variable is still a unit, with the same rail + body scaffolding
  expect_equal(sum(startsWith(compact, "::::: {.dg-unit")), nrow(dgf))
  expect_true(any(grepl("dg-rail", compact, fixed = TRUE)))
  expect_true(any(grepl("dg-props", compact, fixed = TRUE)))
  expect_true(any(grepl("dg-preview", compact, fixed = TRUE)))

  # ... but the properties strip sits in the body, not the rail
  body.start <- grep("{.dg-body}", compact, fixed = TRUE)[1]
  props      <- grep("dg-props", compact, fixed = TRUE)[1]
  expect_gt(props, body.start)

  # and the whole guide is markedly shorter
  expect_lt(length(compact), length(rail))
})

test_that("compact layouts condense the design without dropping blocks", {
  rg <- get_design()
  cp <- get_design(compact = TRUE)

  expect_true("paste_properties" %in% trimws(rg$FUNCTION))
  expect_false("paste_properties" %in% trimws(cp$FUNCTION))
  expect_true("paste_properties_horizontal" %in% trimws(cp$FUNCTION))

  # skew/kurtosis are drawn above the histogram, so the block goes
  expect_true("paste_distribution_shape" %in% trimws(rg$FUNCTION))
  expect_false("paste_distribution_shape" %in% trimws(cp$FUNCTION))

  # every other block survives, type for type
  drop <- function(d) d[!trimws(d$FUNCTION) %in%
                          c("paste_properties", "paste_properties_horizontal",
                            "paste_distribution_shape"), c("TYPE", "DIV", "FUNCTION")]
  expect_equal(drop(cp), drop(rg), ignore_attr = TRUE)
})

test_that("a global layout override still wins in compact", {
  assign("layout.numeric", c("div2 ;; dd_vlabel ;; LABEL ;; v_to_txt"),
         envir = globalenv())
  on.exit(rm("layout.numeric", envir = globalenv()), add = TRUE)
  d <- get_design(compact = TRUE)
  expect_equal(sum(d$TYPE == "number"), 1)
})

test_that("the compact style shortens the long tables and the preview", {
  knob.rail    <- datagoodr:::.rail_knobs("rail")
  knob.compact <- datagoodr:::.rail_knobs("compact")
  expect_lt(knob.compact$max.rows,  knob.rail$max.rows)
  expect_lt(knob.compact$max.lines, knob.rail$max.lines)

  # a 12-level factor, each level rarer than the last: the compact guide lists
  # the 8 most frequent and tallies the rest
  df <- data.frame(g = rep(LETTERS[1:12], times = 12:1), stringsAsFactors = FALSE)
  dgf <- build_demo_dgf(df)
  out <- suppressMessages(suppressWarnings(capture.output(
    rail_sections(rail_groups(dgf)$Categorical, "Categorical", style = "compact"))))
  expect_true(any(grepl("+ 4 more levels", out, fixed = TRUE)))
  levels.block <- out[seq(grep("FACTOR LEVELS", out)[1], length(out))]
  rows <- grep("^[| ]+[0-9]", levels.block, value = TRUE)   # its data rows
  expect_length(rows, 8)
  expect_true(any(grepl("|A", rows, fixed = TRUE)))      # most frequent: listed
  expect_false(any(grepl("|L", rows, fixed = TRUE)))     # rarest: tallied only

  # the same variable in the default guide lists all 12, with no tally
  out.rail <- suppressMessages(suppressWarnings(capture.output(
    rail_sections(rail_groups(dgf)$Categorical, "Categorical"))))
  expect_false(any(grepl("more levels", out.rail, fixed = TRUE)))
})

test_that("paste_properties_horizontal transposes the properties table", {
  dgf <- build_demo_dgf()
  xx  <- datagoodr:::.rail_context(dgf)[["num"]]
  set_xx(xx)
  out <- capture.output(paste_properties_horizontal("rg_properties", ""))
  tbl <- trimws(out[nzchar(trimws(out))])

  # header + separator + exactly one value row
  expect_equal(sum(startsWith(tbl, "|")), 3)
  expect_true(any(grepl("ROWS", tbl, fixed = TRUE)))
  expect_true(any(grepl("DISTINCT", tbl, fixed = TRUE)))
})
