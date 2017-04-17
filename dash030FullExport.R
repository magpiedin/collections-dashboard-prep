## EMu Data Prep Script -- Collections Dashboard
# Final prep & export of full dashboard dataset

print(paste(date(), "-- ...finished setting up WHO.    Starting final prep - dash030FullExport.R"))

# point to csv's directory
setwd(paste0(origdir,"/data01raw"))


# Merge Department column
Depts <- read.csv(file="Departments.csv", stringsAsFactors = F)
FullDash8csv <- merge(FullDash7csv, Depts, by=c("DarCollectionCode"), all.x=T)
rm(Depts)


# Merge DarIndividualCount to count # catalogged items in results
DarIndivCount <- CatDash3[,c("irn","RecordType", "DarIndividualCount")]
FullDash8csv <- merge(FullDash8csv, DarIndivCount, by=c("irn","RecordType"), all.x=T)
FullDash8csv$DarIndividualCount[which(FullDash8csv$RecordType=="Catalog" & is.na(FullDash8csv$DarIndividualCount)==T)] <- 1
FullDash8csv$DarIndividualCount[which(FullDash8csv$RecordType=="Accession")] <- 0
rm(DarIndivCount)


# Setup final data frame for export
FullDash9csv <- FullDash8csv[,c("irn","DarLatitude","DarLongitude","Where",
                                "Quality","RecordType","Backlog","TaxIDRank",
                                "What","DarCollectionCode", "HasMM", "URL",
                                "WhenAge", "WhenAgeFrom", "WhenAgeTo","DarYearCollected",
                                "WhenOrder", "WhenTimeLabel", "WhenAgeMid",
                                "Department", "DarIndividualCount", "Who"
)]

FullDash9csv$DarYearCollected <- as.numeric(FullDash9csv$DarYearCollected)


# Last Check/Clean ####
FullDash9csv$What <- gsub("\\|\\s+NA\\s+\\||\\|\\s+NANA\\s+\\|", "|", FullDash9csv$What, ignore.case = T)
FullDash9csv$What <- gsub("NANA", "", FullDash9csv$What, ignore.case = F)
FullDash9csv$What <- gsub("^NA\\s+|\\s+NA$|^NANA\\s+|\\s+NANA$|\\s+\\|\\s+$", "", FullDash9csv$What, ignore.case = T)
FullDash9csv$What <- gsub("\\|\\s+NA\\s+|\\s+NA\\s+\\|", "", FullDash9csv$What, ignore.case = T)
FullDash9csv$What <- gsub("(\\|\\s+)+", "| ", FullDash9csv$What, ignore.case = T)
FullDash9csv$What <- gsub("(\\s+\\|)+", " |", FullDash9csv$What, ignore.case = T)
FullDash9csv$Where <- gsub("(\\|\\s+)+", "| ", FullDash9csv$Where, ignore.case = T)
FullDash9csv$Where <- gsub("(\\s+\\|)+", " |", FullDash9csv$Where, ignore.case = T)
FullDash9csv$Where <- gsub(" Usa ", " U.S.A. ", FullDash9csv$Where, ignore.case = T)
FullDash9csv$What <- gsub("\\| and \\|", "", FullDash9csv$What, ignore.case = T)
FullDash9csv$Who <- gsub("^ $|^NA$", "", FullDash9csv$Who, ignore.case = T)
FullDash9csv$Who <- gsub("^NA\\s+\\|\\s+", "", FullDash9csv$Who, ignore.case = F)
FullDash9csv$Who <- gsub("\\s+\\|\\s+NA$|\\s+\\|\\s+NA\\s+|^\\s+\\|\\s+|\\s+\\|\\s+$", "", FullDash9csv$Who, ignore.case = F)
FullDash9csv$WhenAge <- gsub("^NA$", "", FullDash9csv$WhenAge, ignore.case = F)

FullDash9csv$WhenAge[which(is.na(FullDash9csv$WhenAge)==T)] <- ""
FullDash9csv$Who[which(is.na(FullDash9csv$Who)==T)] <- ""
FullDash9csv$Where[which(is.na(FullDash9csv$Where)==T)] <- ""


# Setup sample dataset

#SampleGroupC <- c(1321,1:5,656944:656946,537448:537450,867365:867370,2099480,2099482,2668290:2668296,54463,50771,136283,2788069,2388945)
#SampleGroupA <- c(10576,44071,38855,46333,47764,31971,26200,20714,29028,26226,24962,20453,36113,11339)

#AccBacklogSamp1 <- AccDash1[which(AccDash1$irn %in% SampleGroupA),]
#CatDash03Samp1 <- CatDash2[which(CatDash2$irn %in% SampleGroupC),]

FullDashSample1 <- FullDash9csv[which(((FullDash9csv$irn %in% SampleGroupC) & FullDash9csv$RecordType=="Catalog") |
                                       ((FullDash9csv$irn %in% SampleGroupA) & FullDash9csv$RecordType=="Accession")),]

# Scrub out irn's and other identifiers
ScrubCat <- CatDash03Samp1[,c("irn","DarGlobalUniqueIdentifier")]
colnames(ScrubCat)[2] <- "DarGUIDorig"
ScrubCat$irnScrub <- seq(12345,by=1,length.out = NROW(ScrubCat))
ScrubCat$GUIDScrub <- seq(1234,by=1,length.out = NROW(ScrubCat))
ScrubCat$GUIDScrub <- paste0("a",ScrubCat$irnScrub,"bc-1234-5a67-a123-a1bc23de", ScrubCat$GUIDScrub)

ScrubAcc <- data.frame("irn" = AccBacklogSamp1[,c("irn")])
ScrubAcc$irnScrub <- seq(54321,by=1,length.out = NROW(ScrubAcc))

ScrubFull <- rbind(ScrubCat[,c("irn","irnScrub")], ScrubAcc[,c("irn","irnScrub")])

# merge
AccBacklogSamp <- merge(AccBacklogSamp1, ScrubAcc, by="irn", all.x=T)
CatDash03Samp <- merge(CatDash03Samp1, ScrubCat, by="irn", all.x=T)
FullDashSample <- merge(FullDashSample1, ScrubFull, by="irn", all.x=T)

# scrub id #s
AccBacklogSamp$irn <- AccBacklogSamp$irnScrub
AccBacklogSamp <- select(AccBacklogSamp, -irnScrub)
AccBacklogSamp$AccAccessionDescription <- gsub("[[:digit:]]","5",AccBacklogSamp$AccAccessionDescription)
AccBacklogSamp$AccCatalogueNo <- gsub("[[:digit:]]","5",AccBacklogSamp$AccCatalogueNo)
AccBacklogSamp$AccDescription <- gsub("[[:digit:]]","5",AccBacklogSamp$AccDescription)

CatDash03Samp$irn <- CatDash03Samp$irnScrub
CatDash03Samp$DarGlobalUniqueIdentifier <- CatDash03Samp$GUIDScrub
CatDash03Samp <- select(CatDash03Samp, -c(irnScrub,GUIDScrub,DarGUIDorig))
CatDash03Samp$DarCatalogNumber <- gsub("[[:digit:]]","5",CatDash03Samp$DarCatalogNumber)
CatDash03Samp$DarImageURL <- gsub("[[:digit:]]","5",CatDash03Samp$DarImageURL)
CatDash03Samp$DarLatitude <- as.integer(CatDash03Samp$DarLatitude)
CatDash03Samp$DarLongitude <- as.integer(CatDash03Samp$DarLongitude)

FullDashSample$irn <- FullDashSample$irnScrub
FullDashSample <- select(FullDashSample, -irnScrub)
FullDashSample$DarLatitude <- as.integer(FullDashSample$DarLatitude)
FullDashSample$DarLongitude <- as.integer(FullDashSample$DarLongitude)


print(paste(date(), "-- ...finished final prep; starting export of final dataset & LUTs."))


# Export full dataset CSV ####
setwd(paste0(origdir,"/output"))

write.csv(FullDash9csv, file = "FullDash13.csv", na="", row.names = FALSE)


# Export sample dataset CSV ####
setwd(paste0(origdir,"/outputSample"))

write.csv(AccBacklogSamp, file = "SampleInput_AccBacklogBU.csv", na="", row.names = FALSE)
write.csv(CatDash03Samp, file = "SampleInput_CatDash03bu.csv", na="", row.names = FALSE)
write.csv(FullDashSample, file = "FullDash_Sample.csv", na="", row.names = FALSE)


#  Who-Staff LUTs ####
setwd(paste0(origdir,"/data01raw"))

Who <- read.csv(file="DirectorsCutWho.csv", stringsAsFactors = F)

Who2 <- gather(Who, "Staff", "count", 2:4)

Who2$Staff <- gsub("\\.1", "", Who2$Staff)
Who2$count <- as.integer(Who2$count)

Who2 <- Who2[order(Who2$Collections),]

setwd(paste0(origdir,"/output"))
write.csv(Who2, file="WhoDash.csv", na = "0", row.names = F)


## To fix column data-types:
#non_numerics <- plyr::adply(1:ncol(FullDash5), 1, function(x) print(is.numeric(FullDash5[,x])))
#non_numerics[(grep("Where", colnames(FullDash5))), 2] <- TRUE
#non_numerics[1:3,2] <- FALSE
##non_numerics[!(grep("Where", colnames(FullDash5))), 2] <- FALSE
#quote_val <- as.numeric(array(non_numerics[which(!non_numerics$V1), 1]))


# write cleaned lookup tables ####
write.csv(WhereLUTall, file="WhereLUT.csv", row.names=F)
write.csv(WhatLUTB, file="WhatLUTB.csv", row.names=F)
write.csv(WhenAgeLUT, file="WhenAgeLUT.csv", row.names = F)
write.csv(WhoLUT, file="WhoLUT.csv", row.names = F)


setwd(paste0(origdir,"/data03check"))
# write datasets to check ####
write.csv(WhenAgeLUTcheck, "WhenAgeLUTcheck.csv", row.names=F)

# write summary stats
write.csv(QualityFull, file="QualityStatsFull.csv", row.names=F)
write.csv(QualityCatDar, file="QualityStatsCatDar.csv", row.names=F)

setwd(origdir)

print(paste(date(), "-- Finished exporting full dataset for dashboard."))
