# Output for global collections summary


# Institution Localities & URLs
setwd(paste0(origdir,"/supplementary"))

# retrieved from http://grbio.org/content/data-download-grbio
#GRBioRaw <- read.csv("GRBIObiorepositories.csv", # CURRENT DATASET EXCLUDES 'COOL' URI
GRBioRaw <- read.csv("archived_grbio_institutions.csv", 
                      stringsAsFactors = F,
                      encoding = "UTF-8") # alt'ly, "latin1"

GRBioFull <- GRBioRaw[,c("Institution.Code", "Institution.Name",
                         "Physical.Address.1","Physical.Address.2","Physical.Address.3",
                         "City.Town.1", "State.Province.1", "Country.1", "Postal.Zip.Code.1",
                         "Mailing.Address.1", "Mailing.Address.2", "Mailing.Address.3",
                         "City.Town", "State.Province", "Country", "Postal.Zip.Code",
                         "Cool.URI")]

GRBioFull$fullAddress <- paste0(GRBioFull$Physical.Address.1,
                               GRBioFull$Physical.Address.2, GRBioFull$Physical.Address.3, ", ",
                               GRBioFull$City.Town.1, ", ",
                               GRBioFull$State.Province.1)
                               # GRBioFull$Country.1)

GRBioFull$fullAddressALT <- paste(GRBioFull$Mailing.Address.1,
                                  GRBioFull$Mailing.Address.2, GRBioFull$Mailing.Address.3, ", ",
                                  GRBioFull$City.Town, ", ",
                                  GRBioFull$State.Province, ", ",
                                  GRBioFull$Country)

GRBioFull$NameCityCtry <- paste(GRBioFull$Institution.Name,
                                GRBioFull$City.Town.1,
                                GRBioFull$Country.1)

# clean Address Search fields
GRBioFull$fullAddress <- gsub("\\s+", " ", GRBioFull$fullAddress)
GRBioFull$fullAddress <- gsub("(,\\s+)+", ", ", GRBioFull$fullAddress)
GRBioFull$fullAddress <- gsub("\\s+,", ",", GRBioFull$fullAddress)
GRBioFull$fullAddressALT <- gsub("\\s+", " ", GRBioFull$fullAddressALT)
GRBioFull$fullAddressALT <- gsub("(,\\s+)+", ", ", GRBioFull$fullAddressALT)
GRBioFull$fullAddressALT <- gsub("\\s+,", ",", GRBioFull$fullAddressALT)
GRBioFull$NameCityCtry <- gsub("\\s+", " ", GRBioFull$NameCityCtry)
GRBioFull$NameCityCtry <- gsub(" ", "+", GRBioFull$NameCityCtry)

GRBioFull$fullAddress[which(nchar(GRBioFull$fullAddress)<6)] <- GRBioFull$fullAddressALT[which(nchar(GRBioFull$fullAddress)<6)]

InstitutionCodes <- c("AMNH", "DMNS", "FMNH", "LACM", "MFN", "MNHN",
                      "NHMD", "NHMUK", "NMNH", "NNM", "RBINS", "RMNHD", "ROM")

#GRBioPart <- GRBioFull[which(GRBioFull$Institution.Code %in% InstitutionCodes),] 
GRBioPart <- GRBioFull

#install.packages("devtools")
library(devtools)

# Note - Lat/Long Data (c) OpenStreetMap constributors, ODbL 1.0. http://www.openstreetmap.org/copyright
# limit use to 1 request per second
#devtools::install_github("hrbrmstr/nominatim")
library(nominatim)

OSMkey = "RqkvMEluAkr4srmZQ2FA7xVJRriCMl6J"

# setup dataframe for Lat Longs
GRBioLatLonA <- data.frame("place_id"=character(),
                           "lat"=numeric(),
                           "lon"=numeric(),
                           "licence"=character(),
                           "type"=character(),
                           "Institution.Code"=character(),
                           stringsAsFactors = F)

# setup dataframe for Errors
GRBioError <- c()

# Search by Institution.Name ####
## First try searching by institution name :
# Loop through each institution
for (i in 1:NROW(GRBioPart)) {
  GRBioLatLonB <- osm_search(GRBioPart$Institution.Name[i],
                              email = "magpiedin@gmail.com", 
                              key = OSMkey, 
                              limit = 1)
  
  if (NROW(GRBioLatLonB)==1) {
    GRBioLatLonB <- GRBioLatLonB[,c("place_id","lat","lon","licence","type")]
    GRBioLatLonB$Institution.Code <- GRBioPart$Institution.Code[i]
    GRBioLatLonA <- rbind(GRBioLatLonA, GRBioLatLonB)
    print(paste(GRBioPart$Institution.Code[i], "lat/long added"))
  } else {
    GRBioError <- c(GRBioError, GRBioPart$Institution.Code[i])
    print(paste("error:", NROW(GRBioLatLonB), "lat/long found for", GRBioPart$Institution.Code[i]))
  }
  Sys.sleep(3)
}

#backup
write.csv(GRBioLatLonA, file="GRBioLatLonA.csv", row.names = F)

#GRBioError <- GRBioError[which(nchar(GRBioError$Institution.Code)>0),]

# ...by City.Town ####
GRBioPart2 <- GRBioPart[which(GRBioPart$Institution.Code %in% GRBioError),]

# Setup df for Lat Longs
GRBioLatLonA2 <- data.frame("place_id"=character(),
                           "lat"=numeric(),
                           "lon"=numeric(),
                           "licence"=character(),
                           "type"=character(),
                           "Institution.Code"=character(),
                           stringsAsFactors = F)

# setup dataframe for Errors
GRBioError2 <- c()

# Loop through each institution
for (i in 1:NROW(GRBioPart2)) {
  GRBioLatLonB2 <- osm_geocode(GRBioPart2$City.Town[i],
                              email = "magpiedin@gmail.com", 
                              key = OSMkey, 
                              limit = 1)
  if (NROW(GRBioLatLonB2)==1) {
    GRBioLatLonB2 <- GRBioLatLonB2[,c("place_id","lat","lon","licence","type")]
    GRBioLatLonB2$Institution.Code <- GRBioPart2$Institution.Code[i]
    GRBioLatLonA2 <- rbind(GRBioLatLonA2, GRBioLatLonB2)
    print(paste(GRBioPart2$Institution.Code[i], "lat/long added"))
  }
  else {
    GRBioError2 <- c(GRBioError2, GRBioPart2$Institution.Code[i])
    print(paste("error:", NROW(GRBioLatLonB2), "lat/long found for", GRBioPart2$Institution.Code[i]))
  }
  Sys.sleep(3)
}


# ...by Country ####
GRBioPart3 <- GRBioPart2[which(GRBioPart2$Institution.Code %in% GRBioError2),]

# Setup df for Lat Longs
GRBioLatLonA3 <- data.frame("place_id"=character(),
                            "lat"=numeric(),
                            "lon"=numeric(),
                            "licence"=character(),
                            "type"=character(),
                            "Institution.Code"=character(),
                            stringsAsFactors = F)

# setup dataframe for Errors
GRBioError3 <- c()

for (i in 1:NROW(GRBioPart3)) {
  GRBioLatLonB3 <- osm_geocode(GRBioPart3$Country[i],
                               email = "magpiedin@gmail.com", 
                               key = OSMkey, 
                               limit = 1)
  
  if (NROW(GRBioLatLonB3)==1) {
    GRBioLatLonB3 <- GRBioLatLonB3[,c("place_id","lat","lon","licence","type")]
    GRBioLatLonB3$Institution.Code <- GRBioPart3$Institution.Code[i]
    GRBioLatLonA3 <- rbind(GRBioLatLonA3, GRBioLatLonB3)
    print(paste(GRBioPart3$Institution.Code[i], "lat/long added"))
  }
  else {
    GRBioError3 <- c(GRBioError3, GRBioPart3$Institution.Code[i])
    print(paste("error:", NROW(GRBioLatLonB3), "lat/long found for", GRBioPart3$Institution.Code[i]))
  }
  Sys.sleep(1.4)
}

# # # # #

# paused & restarted with just unique list of country names
GRBioPart3ctry <- unique(GRBioPart3$Country)
GRBioPart3cX <- unique(GRBioPart3$Country[which(GRBioPart3$Institution.Code %in% GRBioError3)])
GRBioPart3ctry <- GRBioPart3ctry[which(!GRBioPart3ctry %in% GRBioPart3cX)]

#GRBioLatLonA3b <- GRBioLatLonA3

# Setup df for Lat Longs
GRBioLatLonA3c <- data.frame("place_id"=character(),
                            "lat"=numeric(),
                            "lon"=numeric(),
                            "licence"=character(),
                            "type"=character(),
                            "Country"=character(),
                            stringsAsFactors = F)

# setup dataframe for Errors
GRBioError3c <- c()


for (i in 1:NROW(GRBioPart3ctry)) {
  GRBioLatLonB3 <- osm_geocode(GRBioPart3ctry[i],
                               email = "magpiedin@gmail.com", 
                               key = OSMkey, 
                               limit = 1)
  
  if (NROW(GRBioLatLonB3)==1) {
    GRBioLatLonB3 <- GRBioLatLonB3[,c("place_id","lat","lon","licence","type")]
    GRBioLatLonB3$Country <- GRBioPart3ctry[i]
    GRBioLatLonA3c <- rbind(GRBioLatLonA3c, GRBioLatLonB3)
    print(paste(GRBioPart3ctry[i], "lat/long added"))
  }
  else {
    GRBioError3 <- c(GRBioError3, GRBioPart3ctry[i])
    print(paste("error:", NROW(GRBioLatLonB3), "lat/long found for", GRBioPart3ctry[i]))
  }
  Sys.sleep(1.4)
}



GRBioPart3c <- GRBioPart3[which(!GRBioPart3$Institution.Code %in% GRBioLatLonA3b$Institution.Code),c("Institution.Code","Country")]

GRBioLatLonB3c <- merge(GRBioPart3c, GRBioLatLonA3c)
GRBioLatLonB3c <- GRBioLatLonB3c[,-1]

GRBioLatLonAll <- rbind(GRBioLatLonA,GRBioLatLonA2,GRBioLatLonA3b,GRBioLatLonB3c, GRBioLatLonAll10)
GRBioLatLonAll <- unique(GRBioLatLonAll)

# merge all searches ####
# # # If new search for-loops are added, add them here
GRBioLatLonAll <- rbind(GRBioLatLonA, GRBioLatLonA2, GRBioLatLonA3)  # add GRBioLatLonAll10 HERE + dedup
# GRBioLatLonAll10 <- GRBioLatLonAll  # BU

# merge LatLong with other Institution Data ####
GRBioExport <- merge(GRBioPart, GRBioLatLonAll, by="Institution.Code", all.y=T)

GRBioExport <- GRBioExport[,c("Institution.Code",
                              "Institution.Name",
                              "lat", "lon", "Cool.URI")]

GRcheck <- count(GRBioExport, Institution.Code)
GRcheck <- GRcheck[which(GRcheck$n>1),]
GRBioExport2 <- GRBioExport[which(!GRBioExport$Institution.Code %in% GRcheck$Institution.Code),]

#GRBioExport2$latlon <- paste(GRBioExport2$lat, GRBioExport2$lon)
#GRcheck2 <- count(GRBioExport2, latlon)
#GRcheck2 <- GRcheck2[which(GRcheck2$n>1),]


write.csv(GRBioExport2, file="GRBioInstitutions.csv", row.names = F, na="")
