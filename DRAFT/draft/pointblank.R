# library( pointblank )

require( pointblank )

pointblank::agent <- 
  pointblank::create_agent(
    tbl = small_table,
    tbl_name = "small_table",
    label = "VALID-I Example No. 1"
  ) %>%
  pointblank::col_is_posix(vars(date_time)) %>%
  pointblank::col_vals_in_set(vars(f), set = c("low", "mid", "high")) %>%
  pointblank::col_vals_lt(vars(a), value = 10) %>%
  pointblank::col_vals_regex(vars(b), regex = "^[0-9]-[a-z]{3}-[0-9]{3}$") %>%
  pointblank::col_vals_between(vars(d), left = 0, right = 5000) %>%
  pointblank::interrogate()

html <- 
agent %>%  
  pointblank::get_agent_report() %>%
  htmltools::as.tags()