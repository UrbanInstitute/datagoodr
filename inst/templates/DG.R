# DG.R - datagoodr project customization file
# ----------------------------------------------------------------------------
# This file is sourced automatically when a datagoodr template
# (research-guide.qmd / data-dictionary.qmd) is rendered, as long as it sits
# next to the .qmd. Use it to customize your report WITHOUT editing the package:
#
#   - define or override formatting / graphic functions
#   - override a layout object to add, drop, or reorder sections
#
# Anything you define here shadows the package default of the same name.
# ----------------------------------------------------------------------------


## 1. Override a formatting function ------------------------------------------
## Example: show monetary values with a dollar sign and thousands separators.
##
# dollarize <- function(x) {
#   paste0("$", formatC(round(as.numeric(x)), big.mark = ",", format = "d"))
# }


## 2. Add a custom render function --------------------------------------------
## A function named in a layout object must exist here (or in the qmd) at
## render time. It receives (VNAME, LABEL); read the cell value with xx[[VNAME]]
## and print with cat().
##
# paste_note <- function(VNAME, LABEL = "NOTE") {
#   cat("**", LABEL, "**: ", xx[[VNAME]], "\n\n", sep = "")
# }


## 3. Override a layout object -------------------------------------------------
## Layouts map, per data type:  div ;; DGF column ;; label ;; function
## Define layout.numeric / layout.character / layout.factor / layout.logical to
## replace the package defaults. Example: drop the word cloud for character
## variables and add a custom note.
##
# layout.character <- c(
#   "div2  ;; dd_vlabel        ;; LABEL       ;; v_to_txt",
#   "div3  ;; stable_data_type   ;; DATA TYPE   ;; v_to_txt",
#   "div4  ;; dd_vdesc         ;; DESCRIPTION ;; v_to_txt",
#   "div4  ;; vloc          ;; NOTE        ;; paste_note",
#   "div10 ;; rg_properties ;; PROPERTIES  ;; paste_properties",
#   "div12 ;; rg_stats      ;; STATS       ;; paste_stats_chr" )
