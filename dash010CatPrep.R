## EMu Data Prep Script -- to prep exported table-field data for re-import
#...in cases where need to overwrite whole table
#   (in order to not duplicate rows/get stuff out of sync if nested/multivalue-table)

# install.packages("tidyr")  # uncomment if not already installed
library("tidyr")

# point to your csv's directory
setwd("C:\\Users\\kwebbink\\Desktop\\IPTdashbdTest")

# point to your csv file(s)
IPTlist = list.files(pattern="Group.*.csv$")
CatDash <- do.call(rbind, lapply(IPTlist, read.csv))
# CHECK IF NEED A WAY TO SET STRINGSASFACTORS=FALSE

NROW(levels(as.factor(CatDash$DarGlobalUniqueIdentifier)))

CatDash2 <- CatDash[order(CatDash$DarGlobalUniqueIdentifier),]
CatDash2$GUIDseq <- sequence(rle(as.character(CatDash2$DarGlobalUniqueIdentifier))$lengths)

CatDash3 <- CatDash2[which(nchar(as.character(CatDash2$DarGlobalUniqueIdentifier)) > 3 & CatDash2$GUIDseq == 1),]
CatCheck <- CatDash2[which(CatDash2$GUIDseq > 2),]

#CatDash3 <- unique(CatDash3)

#CatxBasOfRec <- read.csv(file="ecatBasisOfRec.csv", stringsAsFactors = F)
#CatxCatProj <- read.csv(file="ecatCatProj.csv", stringsAsFactors = F)
#CatxDarYr <- read.csv(file="ecatDarYrColl.csv", stringsAsFactors = F)
#CatxDarMo <- read.csv(file="ecatDarMoColl.csv", stringsAsFactors = F)
#CatxDesK <- read.csv(file="ecatDesKDesc.csv", stringsAsFactors = F)

#CatxBasOfRec <- CatxBasOfRec[,-1]
#CatxCatProj <- CatxCatProj[,-1]
#CatxDarYr <- CatxDarYr[,-1]
#CatxDarMo <- CatxDarMo[,-1]
#CatxDesK <- CatxDesK[,-1]

#CatxBasOfRec <- unique(CatxBasOfRec)
#CatxCatProj <- unique(CatxCatProj)
#CatxDarYr <- unique(CatxDarYr)
#CatxDarMo <- unique(CatxDarMo)
#CatxDesK <- unique(CatxDesK)

##IPTlatlon <- read.csv(file="dashbdLatLong.csv")
##IPTlatlon <- IPTlatlon[,2:4]

#CatDash3 <-  subset(CatDash3, select=-c(GUIDseq))

#CatDash2 <- merge(IPTlatlon, CatDash2, by="irn", all.y=T)
#rm(IPTlatlon)

#CatDash3 <- merge(CatDash3, CatxBasOfRec, by = "irn", all.x=T)
#CatDash3 <- merge(CatDash3, CatxCatProj, by = "irn", all.x=T)
#CatDash3 <- merge(CatDash3, CatxDarYr, by = "irn", all.x=T)
#CatDash3 <- merge(CatDash3, CatxDarMo, by = "irn", all.x=T)
#CatDash3 <- merge(CatDash3, CatxDesK, by = "irn", all.x=T)
#rm(CatxBasOfRec, CatxCatProj, CatxDarYr, CatxDarMo, CatxDesK)

CatDash3 <- unique(CatDash3)



# write the lumped/full/single CSV back out
write.csv(CatDash3[,3:(NCOL(CatDash3)-1)], file="CatDash3bu.csv", row.names = F)
write.csv(CatCheck[,3:NCOL(CatCheck)], file="CatDupGUIDs.csv", row.names = F)