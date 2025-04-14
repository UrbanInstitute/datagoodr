############################
### Step 3 - Render the Reserach Guide
############################

# set the path to the most recent verson of the DGF that you want to use
# the path is relative to where the RG.qmd file is (sorry, this is mildly annoying)
# our file path structure is
# - qmd-templates
#    - RG.qmd
# - working-example
#    - STEP3.R
#    - DGF-V2.xlsx
# so the correct file path is...
path_to_dgf <-"../working-example/DGF-V2.xlsx"


## Then we render the quarto document (in the qmd-templates folder)
quarto::quarto_render(
  "qmd-templates/RG.qmd",
  execute_params = list(dgf_file = path_to_dgf))

# The rendered versions should be in qmd-templates/RG.html and qmd-templates/RG.pdf
