setwd(paste0(getwd(),"/collprep/"))


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

if (!file.exists("data01raw/CatDash03bu.csv")) { source("dash010CatPrep.R") }
if (!file.exists("data01raw/AccBacklogBU.csv")) { source("dash015AccPrep.R") }

source("dash020FullBind.R")
source("dash021Where.R")
source("dash022What.R")
source("dash023When.R")
#  ADD dash024Who.R
source("dash030FullExport.R")
