setwd("~/Box Sync/datagoodr")


devtools::document()
# usethis::use_spell_check()

# devtools::check()
devtools::load_all()
#
#
# wd <-  "~/Desktop" #/datagoodr-2025-08-21
# folder.name = NULL
# path.raw.data =  '/Users/oliviabeck/Box Sync/datagoodr/data-dev/DEMO-DATA-SMALL.csv'
# create.dgf.params = NULL
# rg.name = "research-guide"



### PKGDOWN ------------------------
# Run once to configure package to use pkgdown
# usethis::use_pkgdown()
# ## Run to build the website
# pkgdown::build_site()
# pkgdown::build_reference()



#clean and install



pkgdown::build_site()
pkgdown::build_reference()
pkgdown::build_articles()
