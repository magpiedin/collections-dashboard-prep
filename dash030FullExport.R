## EMu Data Prep Script -- Collections Dashboard
# Final prep & export of full dashboard dataset


print(paste(date(), "-- started final prep to export full dataset."))


# point to csv's directory
setwd(paste0(getwd(),"/data01raw"))


# Merge Department column
Depts <- read.csv(file="Departments.csv", stringsAsFactors = F)
FullDash6csv <- merge(FullDash6csv, Depts, by=c("DarCollectionCode"), all.x=T)
rm(Depts)


# Merge DarIndividualCount to count # catalogged items in results
DarIndivCount <- CatDash3[,c("irn","RecordType", "DarIndividualCount")]
FullDash6csv <- merge(FullDash6csv, DarIndivCount, by=c("irn","RecordType"), all.x=T)
FullDash6csv$DarIndividualCount[which(FullDash6csv$RecordType=="Catalog" & is.na(FullDash6csv$DarIndividualCount)==T)] <- 1
FullDash6csv$DarIndividualCount[which(FullDash6csv$RecordType=="Accession")] <- 0
rm(DarIndivCount)


# Setup final data frame for export
FullDash7csv <- FullDash6csv[,c("irn","DarLatitude","DarLongitude","Where",
                                "Quality","RecordType","Backlog","TaxIDRank",
                                "What","DarCollectionCode", "HasMM", "URL",
                                "WhenAge", "WhenAgeFrom", "WhenAgeTo","DarYearCollected",
                                "WhenOrder", "WhenTimeLabel", "WhenAgeMid",
                                "Department", "DarIndividualCount"
                                )]

FullDash7csv$DarYearCollected <- as.numeric(FullDash7csv$DarYearCollected)


# Last Check/Clean ####
FullDash7csv$What <- gsub("\\|\\s+NA\\s+\\||\\|\\s+NANA\\s+\\|", "|", FullDash7csv$What, ignore.case = T)
FullDash7csv$What <- gsub("NANA", "", FullDash7csv$What, ignore.case = F)
FullDash7csv$What <- gsub("^NA\\s+|\\s+NA$|^NANA\\s+|\\s+NANA$", "", FullDash7csv$What, ignore.case = T)
FullDash7csv$What <- gsub("\\|\\s+NA\\s+|\\s+NA\\s+\\|", "", FullDash7csv$What, ignore.case = T)
FullDash7csv$What <- gsub("(\\|\\s+)+", "| ", FullDash7csv$What, ignore.case = T)
FullDash7csv$What <- gsub("(\\s+\\|)+", " |", FullDash7csv$What, ignore.case = T)
FullDash7csv$Where <- gsub("(\\|\\s+)+", "| ", FullDash7csv$Where, ignore.case = T)
FullDash7csv$Where <- gsub("(\\s+\\|)+", " |", FullDash7csv$Where, ignore.case = T)
FullDash7csv$Where <- gsub(" Usa ", " U.S.A. ", FullDash7csv$Where, ignore.case = T)
FullDash7csv$What <- gsub("\\| and \\|", "", FullDash7csv$What, ignore.case = T)


print(paste(date(), "-- finished final prep; starting export of final dataset & LUTs."))


# Export dataset CSV ####
setwd("../output")

write.csv(FullDash7csv, file = "FullDash10.csv", na="NULL", row.names = FALSE)


#  Who LUTs ####
setwd("../data01raw/")

Who <- read.csv(file="DirectorsCutWho.csv", stringsAsFactors = F)

Who2 <- gather(Who, "Staff", "count", 2:4)

Who2$Staff <- gsub("\\.1", "", Who2$Staff)
Who2$count <- as.integer(Who2$count)

Who2 <- Who2[order(Who2$Collections),]

setwd("../output")
write.csv(Who2, file="WhoDash2.csv", na = "0", row.names = F)


## To fix column data-types:

#non_numerics <- plyr::adply(1:ncol(FullDash5), 1, function(x) print(is.numeric(FullDash5[,x])))
#non_numerics[(grep("Where", colnames(FullDash5))), 2] <- TRUE
#non_numerics[1:3,2] <- FALSE
##non_numerics[!(grep("Where", colnames(FullDash5))), 2] <- FALSE
#quote_val <- as.numeric(array(non_numerics[which(!non_numerics$V1), 1]))


# write cleaned lookup tables ####
#setwd("../output")
write.csv(WhereLUTall, file="WhereLUT2.csv", row.names=F)
write.csv(WhatLUTB, file="WhatLUTB2.csv", row.names=F)
write.csv(WhenAgeLUT, file="WhenAgeLUT2.csv", row.names = F)


# write summary stats ####
write.csv(QualityFull, file="QualityStatsFull.csv", row.names=F)
write.csv(QualityCatDar, file="QualityStatsCatDar.csv", row.names=F)


# write datasets to check
write.csv(WhenAgeLUTcheck, "WhenAgeLUTcheck.csv", row.names=F)

setwd("..")


print(paste(date(), "-- finished exporting full dataset for dashboard."))
