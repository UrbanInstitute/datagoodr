quarto::quarto_render(
  input = "qmd-templates/test-render/datagood2.qmd",
  execute_params = list(
    title = "A Title",
    data  = "../../data-dev/DEMO-DATA-SMALL.csv",
    dgf   = "../../data-dev/DGF-CORE-CO-2019-V1.xlsx" )
)



# Olivia File path
setwd("~/Box Sync/datagood2/qmd-templates")
quarto::quarto_render(
  input = "RG.qmd"
)
