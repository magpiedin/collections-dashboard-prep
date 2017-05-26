# # # Test-importing Naturalis dataset for colldash

setwd(paste0(origdir,"/data01raw/emuCatNaturalis"))


# retrieved simple CSv of Hymenoptera dataset from IPT here:
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


# ALT'LY!  pull all data they publish directly from gbif:
install.packages("rgbif")
library(rgbif)

# NEED A KEY?
occ_download(basisOfRecord="Specimen|FOSSIL_SPECIMEN|LIVING_SPECIMEN|PRESERVED_SPECIMEN",
             institutionCode="Naturalis")
             #collectionCode=""
             #publisher="396d5f30-dea9-11db-8ab4-b8a03c50a862")

GBIF1 <- occ_download_get(stuff)

GBIF2 <- data.frame("irn" = GBIF1$gbifid,
                    "DarGlobalUniqueIdentifier" = GBIF1$occurrenceid,
                    "DarOrder" = GBIF1$order,
                    "ClaRank" = GBIF1$taxonrank,
                    "DarScientificName" = GBIF1$scientificname,
                    "DarLatitude" = GBIF1$decimallatitude,
                    "DarLongitude" = GBIF1$decimallongitude,
                    "DarMonthCollected" = GBIF1$month,
                    "DarYearCollected" = GBIF1$year,
                    "DarBasisOfRecord" = GBIF1$basisofrecord,
                    "DarInstitutionCode" = GBIF1$institutioncode,
                    "DarCollectionCode" = GBIF1$collectioncode,
                    "DarCatalogNumber" = GBIF1$catalognumber,
                    "AdmDateModified" = GBIF1$lastinterpreted,
                    "DarImageURL" = GBIF1$mediatype,
                    "AdmDateInserted"="",
                    "DarIndividualCount"="",
                    "DarCountry"="",
                    "DarContinent"="",
                    "DarContinentOcean"="",
                    "DarWaterBody"="",
                    "DarEarliestAge"="",
                    "DarEarliestEon"="",
                    "DarEarliestEpoch"="",
                    "DarEarliestEra"="",
                    "DarEarliestPeriod"="",
                    "AttPeriod_tab"="",
                    "DesEthnicGroupSubgroup_tab"="",
                    "DesMaterials_tab"="",
                    "ComName_tab"="",
                    "DarRelatedInformation"="",
                    "CatProject_tab"="",
                    "EcbNameOfObject"="",
                    "CatLegalStatus"="",
                    "DarCollector"="",
                    stringsAsFactors = F)

