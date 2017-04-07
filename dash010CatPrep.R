## collections-dashboard-prep
#  Prep catalogue data from EMu for dashboard-prep
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
#       - NOTE: May need to re-set working directory to folder containing "Group" csv's
#         (see line 23)

print(paste(date(), "-- starting Catalogue data import"))


# point to the directory containg the set of "Group" csv's from EMu
#setwd("C:\\Users\\kwebbink\\Desktop\\IPTdashbdTest")
setwd(paste0(getwd(),"/data01raw/emuCat/"))

DashList = list.files(pattern="Group.*.csv$")
CatDash0 <- do.call(rbind, lapply(DashList, read.csv, stringsAsFactors = F))

setwd("..")  # up to /collprep/data01raw/


CatDash02 <- CatDash0[order(CatDash0$irn),-c(1,2)]
CatDash02 <- unique(CatDash02)


# Remove duplicate irn's
CatIRNcount <- NROW(levels(as.factor(CatDash02$irn)))

CatDash02$IRNseq <- sequence(rle(as.character(CatDash02$irn))$lengths)

#CatDash03 <- CatDash02[which(nchar(as.character(CatDash02$DarGlobalUniqueIdentifier)) > 3 & CatDash02$IRNseq == 1),]
CatDash03 <- CatDash02[which(CatDash02$IRNseq == 1),]
CatCheck <- CatDash02[which(CatDash02$IRNseq > 1),]

CatDash03 <- dplyr::select(CatDash03, -IRNseq)


#############################


#####  Until EMu report is fixed/updated, Merge any missing columns, e.g.:

#####   DARCOLLECTOR
#####   DARCATALOGNO

#CatDash2 <- read.csv(file="CatDash3BU_old.csv", stringsAsFactors = F, na.strings = "")
TempDarCatnoColl <- data.frame("irn"=CatDash2$irn,
                               "DarCatalogNumber"=CatDash2$DarCatalogNumber, 
                               "DarCollector"=CatDash2$DarCollector,
                               stringsAsFactors = F)

CatDash03 <- merge(CatDash03, TempDarCatnoColl, by="irn", all.x=T)



##############################

# write the lumped/full/single CSV back out
write.csv(CatDash03, file="CatDash03bu.csv", row.names = F, na="")
#write.csv(CatCheck, file="CatCheckIRN.csv", row.names = F)

setwd("..")  # up to /collprep/

print(paste(date(), "-- finished Catalogue data import"))
