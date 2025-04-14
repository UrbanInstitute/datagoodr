

setwd( "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/datagood" )

Sys.setenv( QUARTO_PATH="C:/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe" )

quarto::quarto_render(
  input = "datagood2.qmd",
  execute_params = 
    list( 
          title = "A Title",
          data  = "dataset.csv",
          dgf   = "governance.xls" ) )

# remotes::install_github("jhelvy/renderthis")
renderthis::to_pdf( "datagood2.html" )


##################
##################



install.packages("quarto")

px <- paste0(
  system.file(package = "processx", "bin", "px"),
  system.file(package = "processx", "bin", .Platform$r_arch, "px.exe")
)
px




quarto_path()


Sys.setenv( QUARTO_PATH="C:/Users/jdlec/AppData/Local/R/win-library/4.3" )

setwd( "C:/Users/jdlec/Dropbox (Personal)/00 - URBAN/datagood" )

quarto::quarto_render(
    input = "datagood2.qmd",
    execute_params = list(
        title = "A Title",
        data  = "dataset.csv",
        dfg   = "governance.xls" )
)


C:\Users\jdlec\AppData\Local\


library(quarto)

help(quarto_version)



Error in `process_initialize(self, private, command, args, stdin, stdout, …`:
! Native call to `processx_exec` failed
Caused by error in `chain_call(c_processx_exec, command, c(command, args), pty, pty_options, …`:
! Command not found @win/processx.c:982 (processx_exec)






```{r, echo=F}
library( tidyverse )
# source( "datagood.R" )
```


```{r, echo=F}
load_dgf <- function( filename="DGF.xlsx" ) {
  dgf <- 
    openxlsx::read.xlsx( 
      xlsxFile=filename,
      sheet="DGF" )
  return(dgf)
}

fn <- "DGF-CORE-CO-2019.xlsx"
dgf <- load_dgf( fn )
 
```
