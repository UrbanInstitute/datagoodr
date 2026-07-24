# The type ontology lives in two artifacts that must stay in step: the catalog
# (data-types/research_data_type_ontology.csv, the vocabulary authority) and the
# runtime crosswalk (.data_type_ontology, detector -> coordinates). Every
# (type, subtype, class) triple the crosswalk emits must be a catalog row marked
# implemented = yes, and every implemented = yes row must be emitted by a
# detector. The catalog is a dev artifact (not shipped in the built package), so
# this skips when it cannot be located.

find_ontology_csv <- function() {
  cands <- c(
    "../../data-types/research_data_type_ontology.csv",
    "../../../data-types/research_data_type_ontology.csv",
    "data-types/research_data_type_ontology.csv"
  )
  for (p in cands) if (file.exists(p)) return(normalizePath(p))
  NULL
}

test_that("runtime crosswalk == catalog implemented=yes set", {
  csv <- find_ontology_csv()
  skip_if(is.null(csv), "ontology catalog CSV not available (not shipped in build)")

  d <- utils::read.csv(csv, stringsAsFactors = FALSE, check.names = FALSE)
  names(d)[1] <- sub("^﻿", "", names(d)[1])   # strip a UTF-8 BOM if present
  catalog <- with(d[d$implemented == "yes", , drop = FALSE],
                  unique(paste(data_type, data_subtype, data_class, sep = "/")))

  xw <- datagoodr:::.data_type_ontology
  crosswalk <- unique(vapply(xw, function(v) paste(v[1], v[2], v[3], sep = "/"),
                             character(1)))

  missing_from_catalog <- setdiff(crosswalk, catalog)  # detector coords not in catalog
  detector_absent      <- setdiff(catalog, crosswalk)  # implemented rows no detector emits

  expect_true(
    length(missing_from_catalog) == 0,
    info = paste("crosswalk triples not marked implemented=yes in the catalog:",
                 paste(missing_from_catalog, collapse = ", "))
  )
  expect_true(
    length(detector_absent) == 0,
    info = paste("implemented=yes catalog rows no detector emits:",
                 paste(detector_absent, collapse = ", "))
  )
})
