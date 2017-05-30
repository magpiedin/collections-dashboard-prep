# # # Import & Prep DarwinCore Archive dataset from GBIF
#
# 1) Setup GBIF account.
#
# 2) Make a ".Rprofile" text file in the main project folder containing these R-scripts.
#
# 3) In ".Rprofile" include the following text (without the hashes):
#
#     GBIF_user = [GBIF username]
#     GBIF_pwd = [GBIF password]
#     GBIF_email = [email address]
#
#
# 4) Run this script  
#       - NOTE: May need to re-set working directory to folder containing "Group" csv's
#         (see lines 23 & 24)

print(paste(date(), "-- Starting DwC data import -- dash005DarPrep.R"))

if(!file.exists(paste0(origdir,"/.Rprofile"))) { 
  print("Save your GBIF username, pwd, and email-contact in '.Rprofile'")
  file.create(".Rprofile")  # Store GBIF username, pwd, and email-contact here
  GBIFrprof <- file(".Rprofile")
  writeLines(c("# GBIF options",
               "",
               "library('rgbif')",
               "",
               "options(gbif_email = 'your@email.com',",
               "        gbif_user = 'your-GBIF-user-name',",
               "        gbif_pwd = 'your-GBIF-password')"), 
             GBIFrprof)
}

if (dir.exists(paste0(origdir,"/data01raw/catDwC"))==F) {
  setwd(paste0(origdir,"/data01raw"))
  dir.create("./catDwC", showWarnings = T)
  print("DwC data directory created: '/data01raw/catDwC'")
}

# point to the directory for DwC Archive Zip file/s
setwd(paste0(origdir,"/data01raw/catDwC"))


#install.packages("rgbif")
library(rgbif)

if (Sys.glob(file.path(paste0(origdir,"/data01raw/catDwC"), "*.zip"))==0) {
  print("For acceptable GBIF parameters, see 'Acceptable arguments' - https://www.rdocumentation.org/packages/rgbif/versions/0.9.4/topics/occ_download")
  print("(Alternatively, save datasets as DwC Archive Zip files in the '/data01raw/catDwC' folder)")
  GBIFarg <- readline(prompt="Type a GBIF parameter, e.g. 'datasetKey = abc123'")

  DWCdl <- occ_download(GBIFarg)
                         #"basisOfRecord = PRESERVED_SPECIMEN,FOSSIL_SPECIMEN,LIVING_SPECIMEN",
                         #user = # DWC userID, pw, and email in a ".Rprofile" text file in this working directory,
                         #pwd = # see above,
                         #email = # see above)
  
  DWCmeta <- occ_download_meta(DWCdl)

  # from https://discuss.ropensci.org/t/queueing-DWC-download-requests/718
  stillRunning <- TRUE
  
  while (stillRunning) {
    DWCmeta <- occ_download_meta(DWCdl)
    stillRunning <- !all(tolower(DWCmeta$status) %in% c("succeeded","killed"))
    Sys.sleep(2)
  }
  
  if (tolower(DWCmeta$status)=="succeeded") {
    DWC1 <- occ_download_get(DWCdl, overwrite=T) %>% occ_download_import()
  }
  
  DWCdl[1] # GBIF download key
  
  DWC1a <- occ_download_get(DWCdl)
  
  DWC1 <- occ_download_import(DWC1a, key = DWCdl[1])
  
} else {
  
  DWC1 = list.files(pattern="*.zip$")

  DWC1b <- occ_download_import(as.download(DWC1[1]))

  #lapply(DWC1, occ_download_import(as.download))
  for (i in 2:NROW(DWC1)){
    DWC1c <- occ_download_import(as.download(DWC1[i]))
    DWC1b <- rbind(DWC1b, DWC1c)
  }
  
  DWC1 <- DWC1b
  rm(DWC1b, DWC1c)
  
}

# Retrieve/Map Country Codes (iso2) to Country Names (title)

#install.packages("jsonlite")
library(jsonlite)

GBIFcountries <- "http://api.gbif.org/v1/enumeration/country"
GBIFcountries <- jsonlite::fromJSON(paste(readLines(GBIFcountries), collapse = "")) # error about "incomplete final line" seems ok

GBIFcountries1 <- GBIFcountries[,c("iso2","title")]
colnames(GBIFcountries1) <- c("countryCode","country")

DWC1 <- merge(DWC1, GBIFcountries1, by="countryCode", all.x=T)

DWC2 <- data.frame("irn" = DWC1$gbifID,
                    "DarGlobalUniqueIdentifier" = DWC1$occurrenceID,
                    "DarOrder" = DWC1$order,
                    "ClaRank" = DWC1$taxonRank,
                    "DarScientificName" = DWC1$scientificName,
                    "DarLatitude" = DWC1$decimalLatitude,
                    "DarLongitude" = DWC1$decimalLongitude,
                    "DarMonthCollected" = DWC1$month,
                    "DarYearCollected" = DWC1$year,
                    "DarBasisOfRecord" = DWC1$basisOfRecord,
                    "DarInstitutionCode" = DWC1$institutionCode,
                    "DarCollectionCode" = DWC1$collectionCode,
                    "DarCatalogNumber" = DWC1$catalogNumber,
                    "AdmDateModified" = DWC1$lastInterpreted,
                    "DarImageURL" = DWC1$mediaType,
                    "AdmDateInserted"="",
                    "DarIndividualCount" = DWC1$individualCount,
                    "DarCountry" = DWC1$country, # map to country
                    "DarContinent"= DWC1$continent,
                    "DarContinentOcean" = "",
                    "DarWaterBody" = DWC1$waterBody,
                    "DarEarliestAge" = DWC1$earliestAgeOrLowestStage,
                    "DarEarliestEon" = DWC1$earliestEonOrLowestEonothem,
                    "DarEarliestEpoch" = DWC1$earliestEpochOrLowestSeries,
                    "DarEarliestEra" = DWC1$earliestEraOrLowestErathem,
                    "DarEarliestPeriod" = DWC1$earliestPeriodOrLowestSystem,
                    "AttPeriod_tab" = "",
                    "DesEthnicGroupSubgroup_tab" = "",
                    "DesMaterials_tab" = "",
                    "ComName_tab" = "",
                    "DarRelatedInformation" = "",
                    "CatProject_tab" = "",
                    "EcbNameOfObject" = "",
                    "CatLegalStatus" = "",
                    "DarCollector" = DWC1$recordedBy,
                    "MulHasMultiMedia" = 1-as.integer(is.na(DWC1$mediaType)),
                    stringsAsFactors = F)


setwd(origdir)
