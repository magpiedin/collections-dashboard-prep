## EMu Data Prep Script -- Collections Dashboard
# Merge Accession & Catalogue data from EMu

print(paste(date(), "-- ...finished importing Cat & Acc data.  Starting dash020FullBind.R"))


# point to csv's directory
setwd(paste0(origdir,"/data01raw"))

# Import raw EMu data ####
if (exists("CatDash03")==TRUE) {
  CatDash2 <- CatDash03
} else {
  CatDash2 <- read.csv(file="CatDash03bu.csv", stringsAsFactors = F, na.strings = "")
}


# Merge any other missing columns, e.g.: 
#  NOTE -- (Try to restrict this to 'dash010' script)

DashMMa <- read.csv(file="dashMMa.csv", stringsAsFactors = F)
DashMMbgz <- read.csv(file="dashMMbgz.csv", stringsAsFactors = F)
DashMM <- rbind(DashMMa, DashMMbgz)
DashMM <- unique(DashMM[,3:4])
#DashMM$MulHasMultiMedia <- gsub("N",0,DashMM$MulHasMultiMedia)


if (NROW(CatDash2$MulHasMultiMedia)==0) {
  CatDash2 <- merge(CatDash2, DashMM, by="irn", all.x=T)
}

CatDash2$MulHasMultiMedia <- gsub("Y","1",CatDash2$MulHasMultiMedia)
CatDash2$MulHasMultiMedia <- gsub("N","0",CatDash2$MulHasMultiMedia)
CatDash2$MulHasMultiMedia[which(is.na(CatDash2$MulHasMultiMedia)==T)] <- "0"
CatDash2$DarImageURL <- as.integer(CatDash2$MulHasMultiMedia)


CatDash3 <- unique(CatDash2)
#check <- dplyr::count(CatDash3, irn)


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



# Import Accession data ####

if (exists("IPTaccBL3")==TRUE) {
  AccDash1 <- AccBL3
} else {
  AccDash1 <- read.csv(file="AccBacklogBU.csv", stringsAsFactors = F, na.strings = "")
}


# Map Acc fields to Cat fields
AccDash2 <- as.data.frame(cbind("irn" = AccDash1$irn,
                                "DarCountry" = AccDash1$LocCountry_tab,
                                "DarContinent" = AccDash1$LocContinent_tab,
                                "DarWaterBody" = AccDash1$LocOcean_tab,
                                "DarCollectionCode" = AccDash1$AccCatalogue,
                                # "DesKDescription0" = paste(AccDash1$AccAccessionDescription,"|",AccDash1$AccDescription),
                                "AccDescription" = AccDash1$AccDescription,
                                "AccDescription2" = AccDash1$AccAccessionDescription,
                                "DarIndividualCount"= as.numeric(AccDash1$CatTotal),
                                # "AccTotalObjects"= AccDash1$AccTotalObjects,
                                # "AccTotBothItOb"= as.integer(0),
                                # "AccTotalObjects" = AccDash1$AccTotalObjects,
                                "AccLocality" = AccDash1$AccLocality,
                                "AccGeography" = AccDash1$AccGeography,
                                "AccCatalogueNo" = AccDash1$AccCatalogueNo,
                                "RecordType" = "Accession",
                                "AccTotal" = AccDash1$AccTotal,
                                "Backlog" = AccDash1$backlog), stringsAsFactors=F)

AccDash2$DarIndividualCount <- as.numeric(AccDash2$DarIndividualCount)


library("plyr")

print(paste("... ", substr(date(), 12, 19), "- binding catalogue & accession records..."))

# Combine Accession + Catalogue datasets
FullDash <- plyr::rbind.fill(CatDash3, AccDash2)

print(paste("... ",substr(date(), 12, 19), "- cleaning up full data table..."))

# cleanup import
rm(CatDash2, AccDash1)
FullDash2 <- unique(FullDash)


# Qualilty - rank records ####
FullDash2$Quality <- 9
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$AccTotal>0)] <- 8
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$Quality==8 & (is.na(FullDash2$AccLocality) + is.na(FullDash2$AccGeography) < 2))] <- 7
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$Quality==7 & is.na(FullDash2$AccCatalogueNo)==FALSE)] <- 6
FullDash2$Quality[which(FullDash2$RecordType=="Accession" & FullDash2$Quality<=7 & FullDash2$DarIndividualCount>0)] <- 5

# Set Backlog = 1 for Quality=9 (in order to count minimum #records/backlog)
FullDash2$Backlog[which(FullDash2$Quality==9 & FullDash2$RecordType=="Accession")] <- 1
# Set Backlog = 0 for Catalogue records
FullDash2$Backlog[which(FullDash2$RecordType=="Catalog")] <- 0

# Catalog Partial data measure -- higher = better
FullDash2$DarCountry[which(FullDash2$DarCountry=="NA")] = NA
FullDash2$DarScientificName[which(FullDash2$DarScientificName=="NA")] = NA
FullDash2$DarMonthCollected[which(FullDash2$DarMonthCollected=="NA")] = NA
FullDash2$DarCatalogNumber[which(FullDash2$DarCatalogNumber=="NA")] = NA
FullDash2$DarCollector[which(FullDash2$DarCollector=="NA")] = NA
FullDash2$DarImageURL[which(FullDash2$DarImageURL=="NA")] = NA
FullDash2$DarLatitude[which(FullDash2$DarLatitude=="NA")] = NA
FullDash2$DarLongitude[which(FullDash2$DarLongitude=="NA")] = NA

# Calculate number of Darwin Core fields filled
FullDash2$CatQual <- 5 - (is.na(FullDash2$DarCountry)  # need to update with DarStateProvince
                          +is.na(FullDash2$DarMonthCollected)
                          +is.na(FullDash2$DarCatalogNumber)
                          +is.na(FullDash2$DarCollector)
                          +as.numeric(!FullDash2$TaxIDRank %in% c("Family", "Genus", "Species")))

FullDash2$Quality[which(FullDash2$RecordType=="Catalog")] <- 4
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual>0)] <- 3
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual>2 & (is.na(FullDash2$DarLatitude)+is.na(FullDash2$DarImageURL)<2))] <- 2
FullDash2$Quality[which(FullDash2$RecordType=="Catalog" & FullDash2$CatQual==5 & (is.na(FullDash2$DarLatitude)+is.na(FullDash2$DarImageURL)==0))] <- 1


# Quality Summary Count Export ####
QualityFull <- dplyr::count(FullDash2, Quality)
colnames(QualityFull)[1] <- "QualityRank"

QualityCatDar <- dplyr::count(FullDash2[which(FullDash2$RecordType=="Catalog"),], CatQual)
colnames(QualityCatDar)[1] <- "DarFieldsFilled"

setwd(origdir)
