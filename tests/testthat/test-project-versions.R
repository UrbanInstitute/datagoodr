# Project directories, versioned governed data, and the provenance manifest
# (R/10-project-versions.R). Mirrors test-wrapper.R's tempdir + on.exit(unlink)
# scaffolding pattern and test-stabilize-data.R's lineage-hash checks.

# A tiny raw dataset with one column a rule can visibly transform.
proj_demo_df <- function() {
  data.frame(
    ein   = c("12-3", "4567", "89", "100200300", "42", "7"),
    group = c("a", "b", "a", "b", "a", "b"),
    n     = c(1, 2, 3, 4, 5, 6),
    stringsAsFactors = FALSE
  )
}

# Scaffold a project with its DGF + v01 in a fresh temp dir. Returns the path.
new_proj <- function() {
  root <- tempfile("dg-proj")
  dir.create(root)
  csv <- file.path(root, "demo.csv")
  utils::write.csv(proj_demo_df(), csv, row.names = FALSE, na = "")
  suppressMessages(suppressWarnings(utils::capture.output(
    proj <- create_project(csv, name = "datagoodr", dir = root)
  )))
  suppressMessages(suppressWarnings(utils::capture.output(
    create_project_dgf(proj, use.df.types = FALSE, guess.factors = TRUE)
  )))
  proj
}

test_that("create_project scaffolds the tree and never rewrites the raw file", {
  root <- tempfile("dg-proj"); dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  csv <- file.path(root, "demo.csv")
  utils::write.csv(proj_demo_df(), csv, row.names = FALSE, na = "")

  suppressMessages(suppressWarnings(utils::capture.output(
    proj <- create_project(csv, name = "datagoodr", dir = root)
  )))

  expect_true(dir.exists(file.path(proj, "data", "raw")))
  rawfile <- file.path(proj, "data", "raw", "demo.csv")
  expect_true(file.exists(rawfile))
  expect_true(file.exists(file.path(proj, "data", "manifest.json")))

  # raw is written once: stamp its mtime, run more of the workflow, confirm untouched
  before <- file.info(rawfile)$mtime
  suppressMessages(suppressWarnings(utils::capture.output(
    create_project_dgf(proj, use.df.types = FALSE, guess.factors = TRUE)
  )))
  expect_identical(file.info(rawfile)$mtime, before)

  # refuses to clobber an existing project
  expect_error(
    suppressMessages(create_project(csv, name = "datagoodr", dir = root)),
    "already exists"
  )
})

test_that("v01 logs every variable; an untransformed column has equal start/end hashes", {
  proj <- new_proj()
  on.exit(unlink(dirname(proj), recursive = TRUE), add = TRUE)

  expect_true(file.exists(file.path(proj, "data", "v01.csv")))
  expect_identical(latest_version(proj), "v01")

  m <- read_manifest(proj)
  expect_length(m$versions, 1)
  v01 <- m$versions[[1]]
  vars <- vapply(v01$variables, function(x) x$var_name, character(1))
  expect_setequal(vars, c("ein", "group", "n"))        # every variable
  expect_false(isTRUE(v01$external_change_detected))

  # no rules at v01 => identity => start hash equals end hash for each variable
  for (v in v01$variables) {
    expect_true(nzchar(v$hash_start) && nzchar(v$hash_end))
    expect_identical(v$hash_start, v$hash_end)
    expect_true(nzchar(v$first5_read))
  }
})

test_that("a new conversion writes v02 and logs only the changed variable", {
  proj <- new_proj()
  on.exit(unlink(dirname(proj), recursive = TRUE), add = TRUE)

  dgf <- load_dgf(file.path(proj, "DGF.xlsx"))
  dgf$raw_to_stable_transform[dgf$var_name == "ein"] <- "read_ein"   # zero-pads digits

  suppressMessages(suppressWarnings(utils::capture.output(
    create_version(proj, dgf = dgf)
  )))

  expect_identical(latest_version(proj), "v02")
  m <- read_manifest(proj)
  expect_length(m$versions, 2)
  v02 <- m$versions[[2]]
  changed <- vapply(v02$variables, function(x) x$var_name, character(1))
  expect_identical(changed, "ein")                      # only the changed var
  ein <- v02$variables[[1]]
  expect_false(identical(ein$hash_start, ein$hash_end)) # it really changed
  expect_true(ein$changed)
})

test_that("re-running with no change writes no new version", {
  proj <- new_proj()
  on.exit(unlink(dirname(proj), recursive = TRUE), add = TRUE)

  dgf <- load_dgf(file.path(proj, "DGF.xlsx"))  # unchanged DGF
  suppressMessages(suppressWarnings(utils::capture.output(
    create_version(proj, dgf = dgf)
  )))
  expect_identical(latest_version(proj), "v01")
  expect_false(file.exists(file.path(proj, "data", "v02.csv")))
})

test_that("lineage chains: a version's in-file start_hash equals its parent's current_hash", {
  proj <- new_proj()
  on.exit(unlink(dirname(proj), recursive = TRUE), add = TRUE)

  dgf <- load_dgf(file.path(proj, "DGF.xlsx"))
  dgf$raw_to_stable_transform[dgf$var_name == "ein"] <- "read_ein"
  suppressMessages(suppressWarnings(utils::capture.output(
    create_version(proj, dgf = dgf)
  )))

  p1 <- read_stable_csv(file.path(proj, "data", "v01.csv"))$meta$provenance
  p2 <- read_stable_csv(file.path(proj, "data", "v02.csv"))$meta$provenance
  expect_identical(p1$current_hash, p2$start_hash)
})

test_that("editing a version outside the workflow is flagged as an external change", {
  proj <- new_proj()
  on.exit(unlink(dirname(proj), recursive = TRUE), add = TRUE)

  # tamper with v01's recovered data, re-embed under the same filename
  r <- read_stable_csv(file.path(proj, "data", "v01.csv"))
  dgf <- load_dgf(file.path(proj, "DGF.xlsx"))
  d <- r$data; d$n[1] <- "999"
  suppressMessages(suppressWarnings(
    write_stable_csv(d, file.path(proj, "data", "v01.csv"),
                     dgf = dgf, start_hash = r$meta$provenance$start_hash)
  ))

  suppressMessages(suppressWarnings(utils::capture.output(
    create_version(proj, dgf = dgf)
  )))
  m <- read_manifest(proj)
  last <- m$versions[[length(m$versions)]]
  expect_true(isTRUE(last$external_change_detected))
})

test_that("read_data defaults to the latest version", {
  proj <- new_proj()
  on.exit(unlink(dirname(proj), recursive = TRUE), add = TRUE)

  dgf <- load_dgf(file.path(proj, "DGF.xlsx"))
  dgf$raw_to_stable_transform[dgf$var_name == "ein"] <- "read_ein"
  suppressMessages(suppressWarnings(utils::capture.output(
    create_version(proj, dgf = dgf)
  )))

  expect_identical(latest_version(proj), "v02")
  d_latest <- read_data(proj)
  d_v01    <- read_data(proj, "v01")
  expect_equal(nrow(d_latest), 6L)
  # v02 zero-padded the ein column; v01 did not
  expect_false(identical(d_latest$ein, d_v01$ein))
})
