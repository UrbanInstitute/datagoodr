# Write a message to a log file (and optionally the console)

Appends a timestamped message to a log file. By default, the message is
also printed to the console for immediate feedback.

## Usage

``` r
log_message(message, logfile = "datagoodr.txt", console = TRUE)
```

## Arguments

- message:

  A character string. The message to log.

- logfile:

  A character string giving the path to the log file. Defaults to
  \`"my_log.txt"\`.

- console:

  Logical. Should the message also be printed to the console? Defaults
  to \`TRUE\`.

## Value

Invisibly returns the log line written (a character string). Used for
side effects (writing to file and printing).
