## EMu Data Prep Script -- to prep exported table-field data for re-import
#...in cases where need to overwrite whole table
#   (in order to not duplicate rows/get stuff out of sync if nested/multivalue-table)

# install.packages("tidyr")  # uncomment if not already installed
detach("package:plyr")
library("tidyr")
library("dplyr")
# point to your csv's directory
setwd("C:\\Users\\kwebbink\\Desktop\\IPTdashbdTest\\accessions")



# Import raw EMu Accession data ####
IPTacc1 <- read.csv(file="efmnhtra.csv", stringsAsFactors = F)
IPTacc2 <- read.csv(file="Group1.csv", stringsAsFactors = F)
IPTacc2 <- IPTacc2[,2:NCOL(IPTacc2)]

IPTacc <- merge(IPTacc1, IPTacc2, by="efmnhtransactions_key", all.x=T)

IPTacc3 <- read.csv(file="PriAcces.csv", stringsAsFactors = F)
IPTacc3 <- IPTacc3[,2:NCOL(IPTacc3)]
colnames(IPTacc3[4]) <- "CatIRN"

# proxy for CatCatalog 
IPTaccCat <- IPTacc[,c("efmnhtransactions_key","AccCatalogue","AccTotalItems","AccTotalObjects","AccCount")]
IPTacc3 <- merge(IPTaccCat, IPTacc3, by="efmnhtransactions_key", all.x=T)
IPTacc3 <- unique(IPTacc3)

# Calculate Accession Totals
IPTacc3$CalAccSum <- as.integer(0)
IPTacc3$CalAccSum[which(IPTacc3$DarBasisOfRecord=="Lot" | IPTacc3$DarBasisOfRecord=="Preserved Specimen" | IPTacc3$DarBasisOfRecord=="Artefact")] <- IPTacc3$AccTotalItems[which(IPTacc3$DarBasisOfRecord=="Lot" | IPTacc3$DarBasisOfRecord=="Preserved Specimen" | IPTacc3$DarBasisOfRecord=="Artefact")]
IPTacc3$CalAccSum[which(IPTacc3$DarBasisOfRecord=="Specimen" && IPTacc3$AccCatalogue!="Botany")] <- IPTacc3$AccTotalObjects[which(IPTacc3$DarBasisOfRecord=="Specimen" && IPTacc3$AccCatalogue!="Botany")]
IPTacc3$CalAccSum[which(IPTacc3$AccCatalogue=="Botany")] <- IPTacc3$AccCount[which(IPTacc3$AccCatalogue=="Botany")]
IPTacc3$CalAccSum[which(is.na(IPTacc3$CalAccSum)==TRUE)] <- 0

# since Accession records without attached Cat records have no DarBasisOfRecord field, need this (at least as proxy for now):
IPTacc3$CalAccSum[which(IPTacc3$CalAccSum==0 & IPTacc3$AccTotalItems>0)] <- IPTacc3$AccTotalItems[which(IPTacc3$CalAccSum==0 & IPTacc3$AccTotalItems>0)]


# Split Botany from AGZ to summarize by "sum" (Botany) versus max
IPTacc3accBot <- IPTacc3[which(IPTacc3$AccCatalogue=="Botany"),]
IPTacc3accAGZ <- IPTacc3[which(IPTacc3$AccCatalogue!="Botany"),]

IPTacc3accBotTot <- IPTacc3accBot %>% group_by(efmnhtransactions_key) %>% summarise(AccTotal = sum(as.numeric(CalAccSum)))
IPTacc3accAGZTot <- IPTacc3accAGZ %>% group_by(efmnhtransactions_key) %>% summarise(AccTotal = max(as.numeric(CalAccSum)))

IPTacc3accTot <- rbind(IPTacc3accBotTot, IPTacc3accAGZTot)


# Calculate Catalogged Totals
IPTacc3$CalCatSum <- as.integer(0)
IPTacc3$CalCatSum[which(IPTacc3$DarBasisOfRecord=="Lot" | IPTacc3$DarBasisOfRecord=="Preserved Specimen")] <- IPTacc3$DarIndividualCount[which(IPTacc3$DarBasisOfRecord=="Lot" | IPTacc3$DarBasisOfRecord=="Preserved Specimen")]
IPTacc3$CalCatSum[which(IPTacc3$DarBasisOfRecord=="Artefact")] <- IPTacc3$CatItemsInv[which(IPTacc3$DarBasisOfRecord=="Artefact")]
IPTacc3$CalCatSum[which(IPTacc3$DarBasisOfRecord=="Specimen" && IPTacc3$AccCatalogue!="Botany")] <- 1
IPTacc3$CalCatSum[which(IPTacc3$AccCatalogue=="Botany")] <- 1
IPTacc3$CalCatSum[which(is.na(IPTacc3$CalCatSum)==TRUE)] <- 0


IPTacc3catTot <- IPTacc3 %>% group_by(efmnhtransactions_key) %>% summarise(CatTotal = sum(CalCatSum))


# Merge calculations
IPTacc3tot <- merge(IPTacc3accTot, IPTacc3catTot, by = "efmnhtransactions_key")

IPTacc <- merge(IPTacc, IPTacc3tot, by="efmnhtransactions_key", all.x=T)

IPTacc$backlog <- IPTacc$AccTotal - IPTacc$CatTotal
#write.csv(IPTacc, file="AccBacklog.csv", row.names = F)

# check for duplicates
check <- count(IPTacc, irn)
check <- check[which(check$n>1),]
check2 <- IPTacc[which(IPTacc$irn %in% check$irn),]


# filter out negative backlog values (which count as "catalogged above level 8/7/etc")
IPTaccBL1 <- IPTacc[which(IPTacc$backlog >= 0),]

# Export ACC WhereLUTs ... RE-IMPORT to Catalog-Dashboard script
AccGeographyLUT <- as.data.frame(cbind("WhereLUT"=as.character(IPTaccBL1$AccGeography)), stringsAsFactors = F)
AccGeographyLUT <- unique(AccGeographyLUT)

setwd("C:\\Users\\kwebbink\\Desktop\\IPTdashbdTest")
write.csv(AccGeographyLUT, file="AccGeographyLUT.csv", row.names = F)

setwd("C:\\Users\\kwebbink\\Desktop\\IPTdashbdTest\\accessions")


# check & split duplicate Botany records
checkBL <- count(IPTaccBL1, irn)
checkBL <- checkBL[which(checkBL$n>1),]
IPTaccBL1mult <- IPTaccBL1[which(IPTaccBL1$irn %in% checkBL$irn),]
IPTaccBL1sing <- IPTaccBL1[which(!IPTaccBL1$irn %in% checkBL$irn),]


# spread & concat (Desc + Geog) & re-merge duplicates
IPTaccBL1mult <- IPTaccBL1mult[order(IPTaccBL1mult$irn),]

# concatenate Descriptions
IPTaccBL1multDesc <- IPTaccBL1mult[,c("irn", "AccDescription")]
IPTaccBL1multDesc <- unique(IPTaccBL1multDesc[which(nchar(as.character(IPTaccBL1multDesc$AccDescription))>0),])
IPTaccBL1multDesc$AccDescription <- as.character(IPTaccBL1multDesc$AccDescription)
IPTaccBL1multDesc$irnseq <- paste0("seq", sequence(rle(as.character(IPTaccBL1multDesc$irn))$lengths))
IPTaccBL1multDesc2 <- spread(IPTaccBL1multDesc, irnseq, AccDescription)

IPTaccBL1multDesc2$AccDesConcat <- ""
date()
for (j in 1:NROW(IPTaccBL1multDesc2)) {
  for (i in 2:(NCOL(IPTaccBL1multDesc2)-1)) {
    IPTaccBL1multDesc2$AccDesConcat[j] <- paste0(IPTaccBL1multDesc2$AccDesConcat[j]," | ",IPTaccBL1multDesc2[j,i])
  }}
date()
IPTaccBL1multDesc2$AccDesConcat <- gsub(" \\| NA", "", substr(IPTaccBL1multDesc2$AccDesConcat, 4, nchar(IPTaccBL1multDesc2$AccDesConcat)), ignore.case = T)

IPTaccBL1multDesc2 <- IPTaccBL1multDesc2[,c("irn","AccDesConcat")]


# concatenate Geography
IPTaccBL1multGeo <- IPTaccBL1mult[,c("irn", "AccGeography")]
IPTaccBL1multGeo <- unique(IPTaccBL1multGeo[which(nchar(as.character(IPTaccBL1multGeo$AccGeography))>1),])
IPTaccBL1multGeo$AccGeography <- as.character(IPTaccBL1multGeo$AccGeography)
IPTaccBL1multGeo$irnseq <- paste0("seq", sequence(rle(as.character(IPTaccBL1multGeo$irn))$lengths))
IPTaccBL1multGeo2 <- spread(IPTaccBL1multGeo, irnseq, AccGeography)

IPTaccBL1multGeo2$AccGeogConcat <- ""
date()
for (j in 1:NROW(IPTaccBL1multGeo2)) {
  for (i in 2:(NCOL(IPTaccBL1multGeo2)-1)) {
    IPTaccBL1multGeo2$AccGeogConcat[j] <- paste0(IPTaccBL1multGeo2$AccGeogConcat[j]," | ",IPTaccBL1multGeo2[j,i])
  }}
date()
IPTaccBL1multGeo2$AccGeogConcat <- gsub(" \\| NA", "", substr(IPTaccBL1multGeo2$AccGeogConcat, 4, nchar(IPTaccBL1multGeo2$AccGeogConcat)), ignore.case = T)

IPTaccBL1multGeo2 <- IPTaccBL1multGeo2[,c("irn","AccGeogConcat")]

# merge concatenated Geo & Desc
IPTaccBL1multGD <- merge(IPTaccBL1multDesc2, IPTaccBL1multGeo2, all.x=T, all.y=T)

# merge to full dup-dataset
IPTaccBL1mult2 <- merge(IPTaccBL1mult, IPTaccBL1multGD, by="irn", all.x=TRUE)
IPTaccBL1mult2$AccDescription <- IPTaccBL1mult2$AccDesConcat
IPTaccBL1mult2$AccGeography <- IPTaccBL1mult2$AccGeogConcat



#  If add AccCatalogueNo field:  ####
#  NEED TO ADJUST column numbers in the rbind section below


# rbind dup & single datasets back together
IPTaccBL1mult3 <- IPTaccBL1mult2[,-c(18:19)]
IPTaccBL1mult3 <- unique(IPTaccBL1mult3)

IPTaccBL2 <- rbind(IPTaccBL1sing, IPTaccBL1mult3)

#IPTaccBL3 <- as.data.frame(cbind("irn" = IPTaccBL2$irn,
#                                 "DarLatitude" = as.numeric(0),
#                                 "DarLongitude" = as.numeric(0),
#                                 "DarGlobalUniqueIdentifier" = "",
#                                 "AccGeo" = IPTaccBL2$AccGeography,
#                                 "AccDesConcat" = paste(IPTaccBL2$AccAccessionDescription, "|", IPTaccBL2$AccDescription)
#                                 ))

IPTbasOfRec <- IPTacc3[,c(1,9)]
IPTbasOfRec <- unique(IPTbasOfRec)

IPTaccBL3 <- merge(IPTaccBL2, IPTbasOfRec, by="efmnhtransactions_key", all.x=T)

# subset only the columns needed for subsequent calculations
IPTaccBL3 <- IPTaccBL3[,-1]

# export &/or prep for rbind with cat data
setwd("C:\\Users\\kwebbink\\Desktop\\IPTdashbdTest")
write.csv(IPTaccBL3, file="AccBacklog.csv", row.names = F)
