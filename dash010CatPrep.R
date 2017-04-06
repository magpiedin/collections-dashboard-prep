## EMu Data Prep Script -- to prep exported table-field data for re-import
#
# 1) In EMu, retrieve Catalogue records for dashboard, 
#       06-Apr-2017 dataset includes all ecatalogue records where:
#           + (CatDepartment = "Anthropology" & CatLegalStatus = "Permanent Collection") |
#           + (CatDepartment = "Zoology" | "Botany" | "Geology")  &  AdmPublishWebNoPassword = "Yes"
#
# 2) Report them out with "IPT dashboard" report
#       - see collections-dashboard "Help" page for details on which fields are included in report
#       - Best to report out 200k records at a time.
#       - Rename "Group1.csv" as "Group1_[sequence-number].csv", and keep in one folder
#           NOTE - Sequence numbering method does not matter as long as names are unique.
#                - "Group" is the only required term in the CSV filenames.
#
# 3) Run this script  
#       - NOTE: need to set working directory to folder containing "Group" csv's
#         (see line 20)

print(paste(date(), "-- starting Catalogue data import"))


# point to the directory containg the set of "Group" csv's from EMu
#setwd("C:\\Users\\kwebbink\\Desktop\\IPTdashbdTest")
setwd(paste0(getwd(),"/data01raw/emu/"))

DashList = list.files(pattern="Group.*.csv$")
CatDash <- do.call(rbind, lapply(DashList, read.csv, stringsAsFactors = F))

CatDash2 <- CatDash[order(CatDash$irn),-c(1,2)]
CatDash2 <- unique(CatDash2)


# Remove duplicate irn's
CatIRNcount <- NROW(levels(as.factor(CatDash2$irn)))

CatDash2$IRNseq <- sequence(rle(as.character(CatDash2$irn))$lengths)

#CatDash3 <- CatDash2[which(nchar(as.character(CatDash2$DarGlobalUniqueIdentifier)) > 3 & CatDash2$IRNseq == 1),]
CatDash3 <- CatDash2[which(CatDash2$IRNseq == 1),]
CatCheck <- CatDash2[which(CatDash2$IRNseq > 1),]

CatDash3 <- dplyr::select(CatDash3, -IRNseq)


# write the lumped/full/single CSV back out
write.csv(CatDash3, file="CatDash3bu.csv", row.names = F)
#write.csv(CatCheck, file="CatCheckIRN.csv", row.names = F)

setwd("..")  # up to /collprep/data01ra/
setwd("..")  # up to /collprep/

print(paste(date(), "-- finished Catalogue data import"))
