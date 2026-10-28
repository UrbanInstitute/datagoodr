# Shared fixtures for the degenerate-column and preflight tests.

# A frame with one column per degenerate case, plus ordinary columns.
degenerate_df <- function(n = 120) {
  set.seed(42)
  data.frame(
    id       = sprintf("%05d", seq_len(n)),                          # unique key with leading zeros
    amount   = round(stats::rlnorm(n, 8, 1)),                        # ordinary number
    kind     = sample(c("a", "b", "c"), n, TRUE),                    # ordinary category
    const    = rep("2023", n),                                       # constant
    flag_x   = ifelse(seq_len(n) %% 3 == 0, "X", ""),                # one value + blanks (checkbox)
    empty    = rep(NA_character_, n),                                # all missing
    notes    = c(strrep("long free text ", 100),                     # row 1 is 1,500 bytes: inside the
                 sample(c("short note", "another note"), n - 1, TRUE)), #  first 50 values detect_temporal reads
    bool_mix = sample(c("0", "1", "true", "false"), n, TRUE),        # one flag spelled four ways
    code     = sample(c("00", "11"), n, TRUE),                       # zero-padded code
    id_copy  = sprintf("%05d", seq_len(n)),                          # identical to `id`
    stringsAsFactors = FALSE
  )
}

quiet_dgf <- function(df, ...) {
  out <- NULL
  suppressMessages(suppressWarnings(utils::capture.output(
    out <- create_dgf(df, file = tempfile("dgf-degen"), open = FALSE, ...)
  )))
  out
}


# Like quiet_dgf(), but lets MESSAGES through (to test them) while still hiding printed tables.
quiet_dgf_noisy <- function(df, ...) {
  out <- NULL
  suppressWarnings(utils::capture.output(
    out <- create_dgf(df, file = tempfile("dgf-noisy"), open = FALSE, ...)
  ))
  out
}
