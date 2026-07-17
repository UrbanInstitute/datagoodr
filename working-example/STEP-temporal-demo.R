# Build a Research Guide from the temporal demo dataset. Shows the iterative
# typing loop: create_dgf() guesses roughly, retype_dgf() applies the user's
# corrections and re-profiles, create_rg() renders.
#
#   Rscript working-example/STEP-temporal-demo.R
#
# Regenerate the data first with working-example/make-temporal-demo-data.R.

library( datagoodr )

raw <- "working-example/temporal-demo-data.csv"

# Step 1 - rough first pass. create_dgf auto-detects the clear temporals
# (m-d-Y / d-m-Y dates, the timestamp, the am/pm clock) and the ein identifier.
dgf <- create_dgf( raw, dir = "working-example", file = "DGF-temporal-demo",
                   open = FALSE )

# Step 2 - correct the guesses R could not make from the data alone. Day/month
# names, yyyy-mm, and the year/age numbers are declared as temporal with their
# unit; retype_dgf re-profiles them so the graphic matches the type.
dgf <- retype_dgf( dgf, raw,
  types = c( day_of_week = "temporal", month_abbr = "temporal",
             month_ym    = "temporal", rule_year  = "temporal",
             age_years   = "temporal" ),
  units = c( day_of_week = "dow",   month_abbr = "month",
             month_ym    = "month", rule_year  = "year",
             age_years   = "year",
             # the auto-detected timestamp defaults to a calendar; show it by week
             event_ts    = "week" ) )

# persist the corrected DGF, then render
save_to_excel( dgf, "working-example/DGF-temporal-demo.xlsx", open = FALSE )

create_rg( dgf = "working-example/DGF-temporal-demo.xlsx",
           dir  = "working-example",
           file = "research-guide-temporal-demo.qmd",
           render = TRUE, overwrite = TRUE )
