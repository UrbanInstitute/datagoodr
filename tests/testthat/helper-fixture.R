# Small synthetic dataset exercising all four DGF variable types:
#   num   -> numeric      (continuous)
#   cat   -> factor       (3 repeated levels)
#   flag  -> logical      (2-level category, recoded to logical by create_dgf)
#   notes -> character    (all unique free text)
make_demo_df <- function(n = 60) {
  set.seed(1)
  data.frame(
    num   = stats::rnorm(n),
    cat   = rep(c("A", "B", "C"), length.out = n),
    flag  = rep(c("yes", "no"), length.out = n),
    notes = paste("observation", seq_len(n)),
    stringsAsFactors = FALSE
  )
}

# Build a DGF from the demo data quietly, returning the DGF data frame.
build_demo_dgf <- function(df = make_demo_df()) {
  f <- tempfile("dgf-test")
  suppressMessages(suppressWarnings(
    utils::capture.output(dgf <- create_dgf(df, file = f))
  ))
  dgf
}
