## EMu Data Prep Script -- Collections Dashboard
# Merge Accession & Catalogue data from EMu

print(paste(date(), "-- merging Accessions & Catalogue data"))


# point to csv's directory
setwd(paste0(getwd(),"/data01raw"))

# Import raw EMu data ####
CatDash2 <- read.csv(file="CatDash4BU.csv", stringsAsFactors = F, na.strings = "")


# Merge any missing columns, e.g.:
#IPTlatlon <- read.csv(file="dashbdLatLong.csv")
#IPTlatlon <- IPTlatlon[,2:4]
#CatDash2 <- merge(IPTlatlon, CatDash2, by="irn", all.y=T)
#rm(IPTlatlon)

DescDarRelated <- read.csv(file="ecat3DarRelIn.csv", stringsAsFactors = F)
DescDarRelated <- DescDarRelated[,3:4]
CatDash2 <- merge(CatDash2, DescDarRelated, by="irn", all.x=T)
rm(DescDarRelated)


CatDash3 <- unique(CatDash2)
#check <- dplyr::count(CatDash3, irn)


taxlist = list.files(path="./catTaxClaRank/", pattern="dashbd.*")
setwd("./catTaxClaRank/")
CatTaxClaRank <- do.call(rbind, lapply(taxlist, read.csv))
setwd("..")
CatTaxClaRank <- CatTaxClaRank[,3:4]
CatTaxClaRank$ClaRank <- as.character(CatTaxClaRank$ClaRank)
CatTaxClaRank <- unique(CatTaxClaRank)
# if somehow can't filter out all duplicate irn's, take only "1st"
CatTaxClaRank <- CatTaxClaRank[order(CatTaxClaRank$irn),]
CatTaxClaRank$irnseq <- sequence(rle(as.character(CatTaxClaRank$irn))$lengths)
CatTaxClaRank <- CatTaxClaRank[which(CatTaxClaRank$irnseq==1),]
CatTaxClaRank <- CatTaxClaRank[,1:2]

CatDash3 <- merge(CatDash3, CatTaxClaRank, by="irn", all.x=T)
rm(taxlist)

CatDash3 <- unique(CatDash3)


# Merge EconBotany "Name of Object" Field:
ecblist = list.files(path="./catEconBot/", pattern="dashbd.*")
setwd("./catEconBot/")
CatEconBot <- do.call(rbind, lapply(ecblist, read.csv))
setwd("..")
CatEconBot <- CatEconBot[,3:4]
CatEconBot$EcbNameOfObject <- as.character(CatEconBot$EcbNameOfObject)
CatEconBot <- unique(CatEconBot)

CatDash3 <- merge(CatDash3, CatEconBot, by="irn", all.x=T)
rm(ecblist)

CatDash3 <- unique(CatDash3)


# Add/Adjust columns for Quality calculation
CatDash3$DarIndividualCount <- as.numeric(CatDash3$DarIndividualCount)  # NA's from coercion are ok here

CatDash3$RecordType <- "Catalog"

species <- c("Species","Subspecies","Variety","Subvariety","Form","Subform","Proles","Aberration")
genus <- c("Genus","Subgenus","Section","Subsection")
family <- c("Family","Subfamily","Tribe","Subtribe")
order <- c("Order","Suborder","Infraorder","Superfamily")
class <- c("Class","Subclass","Superorder")
phylum <- c("Phylum","Subphylum","Division")

CatDash3$TaxIDRank <- ""
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% species)] <- "Species"
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% genus)] <- "Genus"
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% family)] <- "Family"
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% order)] <- "Order"
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% class)] <- "Class"
CatDash3$TaxIDRank[which(CatDash3$ClaRank %in% phylum)] <- "Phylum"
CatDash3$TaxIDRank[which(CatDash3$ClaRank == "Kingdom")] <- "Kingdom"


# Import Accession data
AccDash1 <- read.csv(file="AccBacklog.csv", stringsAsFactors = F, na.strings = "")

# Map Acc fields to Cat fields
AccDash2 <- as.data.frame(cbind("irn" = AccDash1$irn,
                                "DarCountry" = AccDash1$LocCountry_tab,
                                "DarContinent" = AccDash1$LocContinent_tab,
                                "DarWaterBody" = AccDash1$LocOcean_tab,
                                "DarCollectionCode" = AccDash1$AccCatalogue,
                                #                                "DesKDescription0" = paste(AccDash1$AccAccessionDescription,"|",AccDash1$AccDescription),
                                "AccDescription" = AccDash1$AccDescription,
                                "AccDescription2" = AccDash1$AccAccessionDescription,
                                "DarIndividualCount"= as.numeric(AccDash1$CatTotal),
                                #                                "AccTotalObjects"= AccDash1$AccTotalObjects,
                                #                                "AccTotBothItOb"= as.integer(0),
                                #                                "AccTotalObjects" = AccDash1$AccTotalObjects,
                                "AccLocality" = AccDash1$AccLocality,
                                "AccGeography" = AccDash1$AccGeography,
                                "AccCatalogueNo" = AccDash1$AccCatalogueNo,
                                "RecordType" = "Accession",
                                "AccTotal" = AccDash1$AccTotal,
                                "Backlog" = AccDash1$backlog), stringsAsFactors=F)

AccDash2$DarIndividualCount <- as.numeric(AccDash2$DarIndividualCount)


library("plyr")

# Combine Accession + Catalogue datasets
FullDash <- plyr::rbind.fill(CatDash3, AccDash2)


# cleanup import
rm(CatDash2, AccDash1)
FullDash2 <- unique(FullDash)


# Qualilty - rank records ####
FullDash2$Quality <- 9
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$AccTotal>0)] <- 8
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$Quality==8 & (is.na(FullDash2$AccLocality) + is.na(FullDash2$AccGeography) < 2))] <- 7
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$Quality==7 & is.na(FullDash2$AccCatalogueNo)==FALSE)] <- 6
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$Quality==6 & FullDash2$DarIndividualCount>0)] <- 5

# Set AccTotal = 1 for Quality=9 (in order to count minimum #records/backlog)
FullDash2$Backlog[which(FullDash2$Quality==9)] <- 1


# Catalog Partial data measure -- higher = better
FullDash2$DarCountry[which(FullDash2$DarCountry=="NA")] = NA
FullDash2$DarScientificName[which(FullDash2$DarScientificName=="NA")] = NA
FullDash2$DarMonthCollected[which(FullDash2$DarMonthCollected=="NA")] = NA
FullDash2$DarCatalogNumber[which(FullDash2$DarCatalogNumber=="NA")] = NA
FullDash2$DarCollector[which(FullDash2$DarCollector=="NA")] = NA
FullDash2$DarImageURL[which(FullDash2$DarImageURL=="NA")] = NA
FullDash2$DarLatitude[which(FullDash2$DarLatitude=="NA")] = NA
FullDash2$DarLongitude[which(FullDash2$DarLongitude=="NA")] = NA

FullDash2$CatQual <- 5 - (is.na(FullDash2$DarCountry)+is.na(FullDash2$DarScientificName)+is.na(FullDash2$DarMonthCollected)+is.na(FullDash2$DarCatalogNumber)+is.na(FullDash2$DarCollector))
FullDash2$Quality[which(FullDash2$RecordType=="Catalog")] <- 4
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual>0)] <- 3
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual>2 & (is.na(FullDash2$DarLatitude)+is.na(FullDash2$DarImageURL)<2))] <- 2
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual==5 & (is.na(FullDash2$DarLatitude)+is.na(FullDash2$DarImageURL)==0))] <- 1


# Quality Summary Count Export ####
QualityFull <- dplyr::count(FullDash2, Quality)
colnames(QualityFull)[1] <- "QualityRank"

QualityCatDar <- dplyr::count(FullDash2[which(FullDash2$RecordType=="Catalog"),], CatQual)
colnames(QualityCatDar)[1] <- "DarFieldsFilled"

setwd("..")

print(paste(date(), "-- finished merging Accessions & Catalogue data"))
