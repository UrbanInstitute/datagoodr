### Log functions -------------------
#' Write a message to a log file (and optionally the console)
#'
#' Appends a timestamped message to a log file. By default, the message is also
#' printed to the console for immediate feedback.
#'
#' @param message A character string. The message to log.
#' @param logfile A character string giving the path to the log file.
#'   Defaults to `"my_log.txt"`.
#' @param console Logical. Should the message also be printed to the console?
#'   Defaults to `TRUE`.
#'
#' @return Invisibly returns the log line written (a character string).
#'   Used for side effects (writing to file and printing).
#' @export
log_message <- function(message, logfile = "datagoodr.txt", console = TRUE) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")

  # Collapse multi-line messages into one block
  if (length(message) > 1) {
    message <- paste(message, collapse = "\n")
  }
  log_line <- sprintf("[%s] %s", timestamp, message)

  # Write to log file
  cat(log_line, "\n", file = logfile, append = TRUE)

  # Print in console
  if(console){cat(sprintf("[%s] %s\n", timestamp, message))}
}





###########################################
### Wrapper function for entire project
###########################################

#' Generate DGF and RG
#'
#' Run the entire datagoodr workflow
#'
#' @param wd charterer string of project output location. Default is the current working directory.
#' @param folder.name character string of folder project output will be put into. Defaut is "datagoodr-TODAYSDATE".
#' @param path.raw.data  character string of absolute path to raw dataset that is to be documented. File extension can be .csv or .xlsx. See data-dev/demo-data-small.csv for an example.
#' @param create.dgf.params list of function arguments for creating the dgf. See \link{create_dgf} for available function arguments (df argument is not needed). Defaul is NULL which uses the default arguments for \link{create_dgf}.
#' @param rg.name character string to name the final research guide output. Default is "research-guide".
#'
#'
#'
#'
#' @return This function outputs entire datagoodr workflow into the `wd` directory.
#'
#' @details
#' Run the entire datagoodr workflow.....
#'
#'
#' @export
datagoodr <- function(wd = getwd(), folder.name = NULL,
                      path.raw.data,
                      create.dgf.params = NULL,
                      rg.name = "research-guide"){

  old.wd <- getwd()
  on.exit(setwd(old.wd), add = TRUE)


  ### Get Working directory and set up file structure ------------
  if(is.null(wd)){
    wd <- getwd()
    #for testing purposes wd <- "~/Desktop"
  }
  if(is.null(folder.name)){
    folder.name <- paste0("datagoodr-", Sys.Date())
  }

  # create main directory
  location.project <- paste0(wd, "/", folder.name)
  if(!dir.exists(wd)){
    mess <- paste("Input working directory", wd, "does not exist. Abort mission.")
    stop(mess)
  }else if(dir.exists(location.project)){
    mess <- paste("Project directory", location.project, "aready exists. Don't overwrite your files! Abort mission.")
    stop(mess)
  }else{
    dir.create(location.project)
  }


  # create subdirectories
  subdir <- c("data-raw", "data-processed", "data-final",
              "DGF", "research-guide", "custom-funcs")
  sapply(subdir, function(x) {
    dir.create(file.path(location.project, x), showWarnings = FALSE)
  })

  # add to log file
  log.file <- paste0(location.project, "/log-", folder.name, ".txt")
  mess <- c(
    "",
    "===========================================",
    paste0("🛰️ datagoor mission control:"),
    paste0("Status: All systems go"),
    paste0("Process initiated at: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    "==========================================="
  )
  log_message(mess, log.file, TRUE)


  mess <- c(
    "Prjoect file directory successfully created",
    capture.output(fs::dir_tree(location.project))
  )

  log_message(paste(mess, collapse = "\n"), log.file, TRUE)



  # create list of paths to be used.
  # for testing purposes path.raw.data <- paste0(old.wd, "/data-dev/DEMO-DATA-SMALL.csv")
  # path.raw.data <- '/Users/oliviabeck/Box Sync/datagoodr/data-dev/DEMO-DATA-SMALL.csv'
  paths <- list(
    wd = wd,
    project = paste0(wd, "/", folder.name),
    data.raw.orig = path.raw.data
  )

  paths$data.raw <- paste0( "data-raw/")
  paths$data.processed <- paste0("data-processed/")
  paths$data.final <- paste0("data-final/")
  paths$dgf <- paste0( "DGF/")
  paths$research.guide <- paste0( "research-guide/")
  paths$custom.funcs <- paste0("custom.funcs/")

  # paths$data.raw <- paste0(paths$project, "/data-raw/")
  # paths$data.processed <- paste0(paths$project, "/data-processed/")
  # paths$data.final <- paste0(paths$project, "/data-final/")
  # paths$dgf <- paste0(paths$project, "/DGF/")
  # paths$research.guide <- paste0(paths$project, "/research-guide/")
  # paths$custom.funcs <- paste0(paths$project, "custom.funcs/")


  # move working directory to project directory

  mess <- paste("Current working direcoty is", old.wd)
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)

  mess <- paste("Switching working directory to project directory at", paths$project)
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)
  setwd(paths$project)

  mess <- c(    capture.output(fs::dir_tree(location.project))
  )

  log_message(paste(mess, collapse = "\n"), log.file, TRUE)


  ### Raw Data ----------------------------

  # check raw data input exists
  does.raw.data.exist <- file.exists(paths$data.raw.orig)

  mess <- paste("Input raw data file location: ", paths$data.raw.orig)
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)

  mess <- paste("Does raw data file exist?", does.raw.data.exist)
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)


  #check file is csv or excel
  filetype.data.raw <- tools::file_ext(paths$data.raw.orig)
  acceptable.extensions <- c("csv", "xlsx", "xls")

  mess <- paste("Input raw data is a", filetype.data.raw, "file.")
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)

  # stop if raw data file is not an acceptable file extension
  if(!(filetype.data.raw %in%acceptable.extensions )){
    mess <- paste(c("Raw data input must be one of:", acceptable.extensions), collapse = " ")
    log_message(paste(mess, collapse = "\n"), log.file, TRUE)

    mess <- "Abort mission."
    log_message(paste(mess, collapse = "\n"), log.file, TRUE)
    stop()
  }


  # save raw data in project folder
  file.copy(from = paths$data.raw.orig,
            to = paths$data.raw)
  paths$data.raw.file <- paste0(paths$data.raw,
                          list.files(paste0(location.project, "/data-raw")))

  mess <- c(
    paste("Raw data successfully copied to data-raw/ subdirectory." ),
    capture.output(fs::dir_tree(location.project))
  )

  log_message(paste(mess, collapse = "\n"), log.file, TRUE)


  ### Step 1: Create the DGF ------------------------

  mess <- c(
    "",
    "===========================================",
    paste0("Step 1: Create the DGF"),
    "===========================================",
    "Reading in raw data to R ..."
  )
  log_message(mess, log.file, TRUE)



  ### Make DGF V1 --------------------
  if(filetype.data.raw == "csv"){
    output_text <- capture.output({
      data.raw <- readr::read_csv(path.raw.data)
    }, type = "message")

    mess <- paste("Console message from readr::read_csv \n",
                  paste(output_text, collapse = "\n"), collapse = " ")

  }else if(filetype.data.raw %in% c("xls, xlsx")){
    output_text <- capture.output({
      data.raw <- readxl::read_excel(path.raw.data)
    }, type = "message")

    mess <- paste("Console message from readxl::read_excel \n",
                  paste(output_text, collapse = "\n"), collapse = " ")

  }else{
    mess <- "Raw data file cannot be read. \n Abort mission."
    log_message(mess, log.file, TRUE)
    stop()
  }
  log_message(mess, log.file, TRUE)



  # output message about function inputs for create_dgf
  mess <- "Creating DGF.... "
  log_message(mess, log.file, TRUE)


  if(is.null(create.dgf.params)){
    create.dgf.params <- list()
  }
  create.dgf.params$df <- data.raw
  create.dgf.params$file = paste0(paths$dgf,"DGF-V1")

  mess.args <- capture.output(
    for (name in names(create.dgf.params)[-which(names(create.dgf.params) == "df")]) {
      value <- create.dgf.params[[name]]
      cat("  -", name, "=", paste(value, collapse = ",  "), "\n")
    })

  mess.args <- paste(mess.args, collapse = "\n")

  mess <- paste(
    "Function arguments used in create_dgf function to make DGF in the DGF subdirectory: \n",
    "**All function arguments not explicitly listed here take the default values listed in the create_dgf help file.**",
    "\n",
    "  - input data set used for 'df' argument is",
    paths$data.raw.file,
    "\n",
    mess.args,
    collapse = "\n"
  )
  log_message(mess, log.file, TRUE)


  # run create_dgf
  dgf.output <- capture.output(
    do.call(create_dgf, create.dgf.params))

  paths$dgf.file.xlsx <- paste0(paths$dgf,  "DGF-V1.xlsx")
  paths$dgf.file.csv <- paste0(paths$dgf,  "DGF-V1.csv")
  paths$dgf.file.txt <- paste0(paths$dgf,  "DGF-V1.txt")


  #also save dgf in txt file
  cat(c(dgf.output), "\n", file = paths$dgf.file.txt)


  mess <- paste("DGF succefully created!")
  log_message(mess, log.file, TRUE)

  mess <- c(
    paste("DGF is saved in", paths$dgf, "subdirectory."),
    capture.output(fs::dir_tree(location.project))
  )

  log_message(paste(mess, collapse = "\n"), log.file, TRUE)

  ## Manual updates to the dgf?
  mess <- "Do you want to update the dgf manually? [y/n]"
  log_message(paste(mess, collapse = "\n"), log.file, FALSE)
  dgf.manual <- readline(mess)
  dgf.manual <- tolower(dgf.manual)
  log_message(paste(dgf.manual, collapse = "\n"), log.file, FALSE)


  while(!(dgf.manual %in% c("y", "n", "yes", "no"))){
    mess = "Invalid input. Do you want to update the dgf manually? [y/n]"
    log_message(paste(mess, collapse = "\n"), log.file, FALSE)
    dgf.manual <- readline(mess)
    dgf.manual <- tolower(dgf.manual)
    log_message(paste(dgf.manual, collapse = "\n"), log.file, FALSE)
  }
  if(dgf.manual %in% c("y", "yes")){
    mess = paste("Save updated DGF in DGF/ subdirectory.",
                 "Remember to write your changes in a change log.")
    log_message(paste(mess, collapse = "\n"), log.file, TRUE)
    mess = "Type in the name of the file in the DGF/ subdirectory that contains the updated DGF you wish to use to create the RG:"
    dgf.use.name <- readline(mess)
    paths$dgf.use <- paste0(paths$dgf, "/", dgf.use.name, collapse = "")


    while(!file.exists(paths$dgf.use)){
      mess <- paste("The file", dgf.use.name, "does not exist in the DGF/ subdirectory. \n Type in the name of the file in the DGF/ subdirectory that contains the updated DGF you wish to use to create the RG:")
      log_message(paste(mess, collapse = "\n"), log.file, FALSE)
      dgf.use.name <- readline(mess)
      log_message(paste(dgf.use.name, collapse = "\n"), log.file, FALSE)
      paths$dgf.use <- paste0(paths$dgf, dgf.use.name, collapse = "")
      }
  }else{
    paths$dgf.use <- paths$dgf.file.xlsx
  }

  mess <- paste("The file that contains the DGF we will use to make the RG in the next step is ",
                paths$dgf.use)
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)

  mess <- c(
    'File structure at the end of Step 1:',
    capture.output(fs::dir_tree(location.project))
  )

  log_message(paste(mess, collapse = "\n"), log.file, TRUE)


  ### Step 2 : Validate the DGF -----------------------------------------
  mess <- c(
    "",
    "===========================================",
    paste0("Step 2: Validate the DGF"),
    "==========================================="  )
  log_message(mess, log.file, TRUE)



  mess <- paste(
  "This step would include many of the DGF validation steps in the R/02*.R files.
  The goal of this step is to validate each column to make sure it is in a format that step 3 can correctly process.
  This is not currently operational, so we skip it for now... ")
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)


  ### Step 3 : Render the Research Guide -----------------------------------------
  mess <- c(
    "",
    "===========================================",
    paste0("Step 3: Render the Research Guide"),
    "==========================================="  )
  log_message(mess, log.file, TRUE)

  mess <- paste("Research guide template is saved in the datagoodr R package at datagoodr/inst/qmd-templates.qmd.",
                "That file on your system is located at",
                system.file("qmd-templates", "RG.qmd", package = "datagoodr"))
  log_message(mess, log.file, TRUE)

  ## Replace all instances of "file_name_placeholder" in YAML to correct file name
  replace_in_qmd <- function(file, old, new) {
    txt <- readLines(file)
    txt <- gsub(old, new, txt, fixed = TRUE)  # fixed=TRUE treats old as literal
    writeLines(txt, file)
  }
  #make quarto document name
  if(is.null(rg.name) | rg.name == "research-guide"){
    quarto.name <- paste0("research-guide-",  format(Sys.time(), "%Y-%m-%d"))
  }else{
    quarto.name <- rg.name
  }
  replace_in_qmd(paths$research.guide.template,
                 "file_name_placeholder",
                 paste0('"', quarto.name, '"'))


  mess <- paste("Research guide template sucessfully saved to research-guide/ subdirectory.")
  log_message(mess, log.file, TRUE)

  mess <-  capture.output(fs::dir_tree(location.project))
  log_message(mess, log.file, TRUE)


  paths$research.guide.render <- paste0(paths$research.guide, rg.name)


  mess <- "Rendering RG in quarto ............"
  log_message(mess, log.file, TRUE)


  sink(log.file, type = "output", append = TRUE)



  result <- tryCatch(
    {
      # Capture console output during render
      mess.quarto <- capture.output(
        quarto::quarto_render(
          input = paths$research.guide.template,
          execute_params = list(dgf_file = paste0("../", paths$dgf.use)),
          output_format = "all",
          execute_dir = paths$research.guide
        ),
        type = "output"
      )

      # Action if render succeeds
      log_message(mess.quarto, log.file, TRUE)

      mess <- "✅ Quarto render succeeded!"
      log_message(mess, log.file, TRUE)


      TRUE
    },
    error = function(e) {
      # Action if render fails
      mess <- "❌ Quarto render failed:"
      message(mess)
      message(e$message)

      # Optionally log the error
      log_message(paste(mess, e$message), log.file, TRUE)

      sink()
      FALSE  # return value indicating failure
    }
  )

  # if quarto document doesn't render, abort mission
  if (!result) {
    mess <- "Abort Mission"
    log_message(mess, log.file, TRUE)
    sink()
    stop()
  }



  cat(paste(mess.quarto, "\n"))

  file.types <- c(".md", ".html", ".pdf")
  for(ft in file.types){
    file.rename(paste0(paths$project, "/", paths$research.guide, "RG-template", ft),
                paste0(paths$project,  "/", paths$research.guide, "research-guide-", format(Sys.time(), "%Y-%m-%d"),ft))
  }

  mess <- paste(
    "Research Guide sucessfully created in research-guide/ subdirectory. \n",
    "Directory stucture at the end of Step 3")
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)

  mess <- capture.output(fs::dir_tree(location.project))
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)





  # #### Step 4: Refresh the DGF ----------------
  #
  # mess <- paste(
  #   "Step 4: Refresh the DGF",
  #   "When the data set is updated, this step is meant to compare the old data set to the new one. If anything changed, the DGF should also updated. This updating is designed to be done through the rg_hash column of the DGF. The hashing allows us to check if a variable needs to up updated in the DGF without actually verifying each individual entry.",
  #   "In the new data set for each variable, generate the hash value. If the new hash value matches the one in the rg_hash column of the old DGF, no need to update that variable, great! If the new hash value does not match the  one in the rg_hash column of the old DGF, then that variable's rg_[preview/properties/stats/graphics/hash] need to be updated.",
  #   "This step is not currently operational so we skip it for now....",
  #   collapse = " \n"
  # )
  # log_message(mess, log.file, TRUE)
  #
  #
  #
  # ## Step 5: Customize -----------------
  #
  # mess <- paste(
  #   "Step 5: Customize the Research Guide",
  #   "The R/05*.R functions are designed for customization of the RG. This could be templates,  div arrangements, fonts, colors, or 'polishing' functions for the variables (such as `dollarize` for monetary values).",
  #   "This step is not currently operational so we skip it for now....",
  #   collapse = " \n"
  # )
  # log_message(mess, log.file, TRUE)


  ## Mission complete ---------------
  mess <- "🚀 Mission Complete! All tasks finished successfully."
  log_message(mess, log.file, TRUE)

  mess <- "Final project directory structure is"
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)

  mess <- capture.output(fs::dir_tree(location.project))
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)

  mess <- paste("Returning to oringial working directory", old.wd)
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)

  setwd(old.wd)



}
