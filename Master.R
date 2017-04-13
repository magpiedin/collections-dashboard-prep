# Run this script to prep a Collections Dashboard dataset.

#origdir <- "D:/colldash2/collprep/"
origdir <- getwd()

# Instructions
print("Step 1 - Save scripts repo to computer.")
print("Step 2 - Save raw data to sub-folder called 'data01raw'.")
print(paste("Step 3 - Currently, the working directory is set to: ", getwd()))
switchYN <- readline(prompt="Do you need to change the working directory to the folder containing the scripts? (Y/N) ")

if (switchYN=="Y") {
  origdir <- readline(prompt="Enter working directory (e.g., C:/path/to/folder ) ")
  setwd(origdir)
} else if (switchYN=="N") {
  setwd(origdir)
}

if (dir.exists(paste0(origdir,"/output"))==T) {
  print("Step 4 - 'output' directory already set up.")
} else if (dir.exists(paste0(origdir,"/output"))==F) {
  dir.create("./output", showWarnings = T)
  print("Step 4 - 'output' directory created.")
}


sourceDir <- function(path, trace = TRUE, ...) {
  for (nm in list.files(path, pattern = "\\.[Rr]$")) {
    if(trace) cat(nm,":")
    source(file.path(path, nm), ...)
    if(trace) cat("\n")
  }
}


sourceDir(paste(getwd(),"/functions",sep=""))

usePackage("tidyr")
usePackage("plyr")
usePackage("dplyr")


# Run scripts

if (!file.exists("data01raw/CatDash03bu.csv")) { source("dash010CatPrep.R") }
if (!file.exists("data01raw/AccBacklogBU.csv")) { source("dash015AccPrep.R") }

source("dash020FullBind.R")
source("dash021Where.R")
source("dash022What.R")
source("dash023When.R")
source("dash024Who.R")
source("dash030FullExport.R")
