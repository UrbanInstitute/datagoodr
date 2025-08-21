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
#'
#' @examples
#' \dontrun{
#' log_message("Starting data processing")
#' log_message("Step 1 complete", logfile = "process_log.txt")
#' log_message("Only in file", console = FALSE)
#' }
#'
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
#' @param path.raw.data  character string of path to raw dataset that is to be documented. File extension can be .csv or .xlsx. See data-dev/demo-data-small.csv for an example.
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

  ### Get Working dirctory and set up file structure ------------
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
    "File directory successfully created",
    capture.output(fs::dir_tree(location.project))
  )

  log_message(paste(mess, collapse = "\n"), log.file, TRUE)


  # create list of paths to be used.
  # for testing purposes path.raw.data <- paste0(getwd(), "/data-dev/DEMO-DATA-SMALL.csv")
  paths <- list(
    wd = wd,
    project = paste0(wd, "/", folder.name),
    data.raw.orig = path.raw.data
  )

  paths$data.raw <- paste0(paths$project, "/data-raw/")
  paths$data.processed <- paste0(paths$project, "/data-processed/")
  paths$data.final <- paste0(paths$project, "/data-final/")
  paths$dgf <- paste0(paths$project, "/DGF/")
  paths$research.guide <- paste0(paths$project, "/research-guide/")
  paths$custom.funcs <- paste0(paths$project, "custom.funcs/")



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
    paths$dgf.use <- paths$dgf.file.csv
  }

  mess <- paste("The file that contains the DGF we will use to make the RG in the next step is ",
                paths$dgf.use)
  log_message(paste(mess, collapse = "\n"), log.file, TRUE)

  mess <- c(
    paste("Raw data successfully copied to data-raw/ subdirectory." ),
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


  ### Step 3 : Render the Reserach Guide -----------------------------------------
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


  paths$research.guide.render <- paste0(paths$research.guide, rg.name)


  mess <- "Rendering RG in quarto ............"
  log_message(mess, log.file, TRUE)


  quarto::quarto_render(
    system.file("qmd-templates", "RG.qmd", package = "datagoodr"),
    execute_params = list(dgf_file = paths$dgf.use))


}
