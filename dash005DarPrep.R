# # # Test-importing Naturalis dataset for colldash

setwd(paste0(origdir,"/data01raw/emuCatNaturalis"))


# retrieved simple CSV of Hymenoptera dataset from IPT here:
#   http://www.gbif.org/installation/d4a25886-6cb1-43b2-b5c2-e4f131396fd8

Naturalis2 <- read.csv(file="0092969-160910150852091.csv", 
                       head=T,
                       sep="\t",
                       quote="",
                       strip.white=T,
                       fill = T,
                       stringsAsFactors = F,
                       comment.char = "",
                       encoding = "UTF-8")  # "latin1" alternatively

## if need to check colnames against CatDash df:
#colnames(Naturalis2)
#write.table(colnames(Naturalis2), file="IPTcolnames.csv", row.names = F, col.names = F, sep=",")
#write.table(head(Naturalis2), file="IPThead.csv", row.names = F, col.names = T, sep=",")


# ALT'LY: pull all data they publish directly from gbif:
#install.packages("rgbif")
library(rgbif)

#file.edit(".Rprofile")

# NEED A KEY?
GBIF <- occ_download(##"datasetKey = 306f61f2-9ff0-404e-8aa6-a525a7fae369")  # odonata
                     ##"basisOfRecord = PRESERVED_SPECIMEN", #FOSSIL_SPECIMEN,LIVING_SPECIMEN,PRESERVED_SPECIMEN",
                     ##"institutionCode = naturalis",
                     #"datasetKey = 889c91a3-614f-4355-8df8-b6d0260a118c"  # aves
                     "datasetKey = 4fe47a52-2b8e-4a5a-aa08-498cab9858a1")  # paleo-inverts
                     #"collectionCode = lepidoptera")
                     ##basisOfRecord="Specimen", #,FOSSIL_SPECIMEN,LIVING_SPECIMEN,PRESERVED_SPECIMEN",
                     ##collectionCode=""
                     ##publisher="396d5f30-dea9-11db-8ab4-b8a03c50a862")

occ_download_meta(GBIF)

GBIF1 <- occ_download_get(GBIF, overwrite = T)
GBIF2ave <- occ_download_import(GBIF1)

GBIF3 <- data.frame("irn" = GBIF2ave$gbifID,
                    "DarGlobalUniqueIdentifier" = GBIF2ave$occurrenceID,
                    "DarOrder" = GBIF2ave$order,
                    "ClaRank" = GBIF2ave$taxonRank,
                    "DarScientificName" = GBIF2ave$scientificName,
                    "DarLatitude" = GBIF2ave$decimalLatitude,
                    "DarLongitude" = GBIF2ave$decimalLongitude,
                    "DarMonthCollected" = GBIF2ave$month,
                    "DarYearCollected" = GBIF2ave$year,
                    "DarBasisOfRecord" = GBIF2ave$basisOfRecord,
                    "DarInstitutionCode" = GBIF2ave$institutionCode,
                    "DarCollectionCode" = GBIF2ave$collectionCode,
                    "DarCatalogNumber" = GBIF2ave$catalogNumber,
                    "AdmDateModified" = GBIF2ave$lastInterpreted,
                    "DarImageURL" = 1-as.integer(is.na(GBIF2ave$mediaType)),
                    "AdmDateInserted" = "",
                    "DarIndividualCount" = GBIF2ave$individualCount,
                    "DarCountry" = GBIF2ave$countryCode, # map to country
                    "DarContinent"= GBIF2ave$continent,
                    "DarContinentOcean" = "",
                    "DarWaterBody" = GBIF2ave$waterBody,
                    "DarEarliestAge" = GBIF2ave$earliestAgeOrLowestStage,
                    "DarEarliestEon" = GBIF2ave$earliestEonOrLowestEonothem,
                    "DarEarliestEpoch" = GBIF2ave$earliestEpochOrLowestSeries,
                    "DarEarliestEra" = GBIF2ave$earliestEraOrLowestErathem,
                    "DarEarliestPeriod" = GBIF2ave$earliestPeriodOrLowestSystem,
                    "AttPeriod_tab" = "",
                    "DesEthnicGroupSubgroup_tab" = "",
                    "DesMaterials_tab" = "",
                    "ComName_tab" = "",
                    "DarRelatedInformation" = "",
                    "CatProject_tab" = "",
                    "EcbNameOfObject" = "",
                    "CatLegalStatus" = "",
                    "DarCollector" = GBIF2ave$recordedBy,
                    "MulHasMultiMedia" = 1-as.integer(is.na(GBIF2ave$mediaType)),
                    stringsAsFactors = F)

setwd(origdir)