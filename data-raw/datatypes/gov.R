## data-raw/datatypes/gov.R
## Positive examples for the GOVERNMENT / ENTITY ID family. SSNs are the
## AutoType sample values (not real). DEA and Chinese-ID values are checksum-
## valid; the malformed one-letter DEA "F91234567" was dropped. UEI examples
## are synthesized to the SAM.gov rules (12 alnum, no I/O, first not 0).

ssn <- c(
  "540-39-4268", "518-07-5084", "531-33-7396", "212-61-9091", "478-46-4157",
  "600-39-4268", "458-07-5084", "426-33-7396", "686-61-9091", "142-46-4157"
)

ein <- c(
  "15-4464349", "58-9042990", "17-5287634", "11-9778467", "79-3293856",
  "94-1234567", "12-3456789", "45-6789012", "27-1234567", "83-4567890"
)

dea <- c(
  "AP5836727", "BJ6125341", "AD0865937", "AS9432042", "AJ3247194",
  "AB5692202", "AP1863845", "AL4214932", "FN5623740", "MH4836726", "FS8524616"
)

## NB: AutoType's "430602199106201124" has an invalid mod-11-2 check digit
## (computes to 3, ends in 4) and was dropped as bad data.
chinese_resident_id <- c(
  "141002197808194474", "431026197506218370", "210811198609188735",
  "371625197902109782", "140427197602187066", "440507198906264783",
  "500382197606223286"
)

uei <- c(
  "ZQGGHJH74DW7", "R7KZ8N2QP4M5", "H3JD9FGT2WX6", "AB1CD2EF3GH4",
  "M5N6P7Q8R9S2", "XY7Z8W9V2U3T", "9ABCDEFGHJK2", "K1L2M3N4P5Q6",
  "WX8YZ7VU6T5S", "J4K5L6M7N8P9"
)

naics <- c(
  "11", "236", "311", "541511", "5415", "6221", "722", "81", "92", "44",
  "51", "111110", "621", "5417"
)
