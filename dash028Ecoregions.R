# Setup to map countries/continents/oceans to Ecoregions

print(paste(date(), "-- ...finished setting up Visitor data.   Starting dash028Ecoregions.R"))


# Add separate columns for DarCountry & DarContinentOcean
DarCtryContOcean <- FullDash2[,c("irn","RecordType",
                                 "cleanDarCountry","cleanDarContinentOcean",
                                 "cleanAccGeography", "cleanAccLocality"
                                 )]

DarCtryContOcean[,3:NCOL(DarCtryContOcean)] <- sapply(DarCtryContOcean[,3:NCOL(DarCtryContOcean)],
                                                      function(x) gsub("(NA)+","",x))

DarCtryContOcean <- unite(DarCtryContOcean, Bioregion, cleanDarCountry:cleanAccLocality, sep=" | ")
DarCtryContOcean$Bioregion <- gsub("(\\|\\s+)+", "| ", DarCtryContOcean$Bioregion)
DarCtryContOcean$Bioregion <- gsub("^\\s+\\|\\s+$|^\\s+\\||\\|\\s+$", "", DarCtryContOcean$Bioregion)
DarCtryContOcean$Bioregion <- gsub("^\\s+|\\s+$", "", DarCtryContOcean$Bioregion)


FullDash8 <- merge(FullDash7csv, DarCtryContOcean, by=c("irn","RecordType"))


#install.packages("curl")
library(curl)
curl::curl_download("http://assets.worldwildlife.org/publications/15/files/original/official_teow.zip?1349272619", destfile = "official.zip")
unzip("official.zip")
shpfile <- "official/wwf_terr_ecos.shp"

#install.packages("geojsonio")
#install.packages("rgdal")
library(geojsonio)
shp <- geojsonio::geojson_read("official/wwf_terr_ecos.shp", method = "local", what = "sp")

