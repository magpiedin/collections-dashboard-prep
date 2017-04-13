## EMu Data Prep Script -- Collections Dashboard
# Setup "When" data

print(paste(date(), "-- ...finished setting up WHEN.   Starting dash024Who.R"))

# point to csv's directory
setwd(paste0(origdir,"/data01raw"))


#  Who ####
#  1-Who: Clean "Who" fields

WhoDashBU <- FullDash3[,c("irn", "RecordType", 
                          "DesEthnicGroupSubgroup_tab", 
                          "AccDescription", "AccDescription2", # might need to cut these?
                          "EcbNameOfObject")]
WhoDash <- WhoDashBU


print(paste("... ",substr(date(), 12, 19), "- cleaning WHO data..."))

date() 
WhoDash[,3:NCOL(WhoDash)] <- sapply(WhoDash[,3:NCOL(WhoDash)], function (x) gsub("^NA$|^'| a |[/()?]|\\[\\]|probably", " ", x, ignore.case = T))
WhoDash[,3:NCOL(WhoDash)] <- sapply(WhoDash[,3:NCOL(WhoDash)], function (x) gsub(", | - |;", " | ", x))
WhoDash[,3:NCOL(WhoDash)] <- sapply(WhoDash[,3:NCOL(WhoDash)], function (x) gsub("\\s+", " ", x))
WhoDash[,3:NCOL(WhoDash)] <- sapply(WhoDash[,3:NCOL(WhoDash)], function (x) gsub("^\\s+|\\s+$", "", x))
WhoDash[,3:NCOL(WhoDash)] <- sapply(WhoDash[,3:NCOL(WhoDash)], function (x) gsub("^NA$|^NANA$", "", x, ignore.case = T))
date()


WhoDash$DesEthnicGroupSubgroup_tab <- gsub("^Na ", "North American ", WhoDash$DesEthnicGroupSubgroup_tab, ignore.case = T)
WhoDash$DesEthnicGroupSubgroup_tab[which(substr(WhoDash$DesEthnicGroupSubgroup_tab,1,1)!="!")] <- sapply(WhoDash$DesEthnicGroupSubgroup_tab[which(substr(WhoDash$DesEthnicGroupSubgroup_tab,1,1)!="!")], simpleCap)

WhoDash$EcbNameOfObject[is.na(WhoDash$EcbNameOfObject)==T] <- ""
WhoDash$EcbNameOfObject <- sapply (WhoDash$EcbNameOfObject, simpleCap)
date()

WhoDash$AccDescription[is.na(WhoDash$AccDescription)==T] <- ""
WhoDash$AccDescription <- gsub("\\|| ", " | ", WhoDash$AccDescription)
WhoDash$AccDescription <- sapply (WhoDash$AccDescription, simpleCap)
date()

WhoDash$AccDescription2[is.na(WhoDash$AccDescription2)==T] <- ""
#WhoDash$AccDescription2 <- gsub("[[:punct:]]", " ", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- gsub("[[:digit:]]+", " ", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- gsub(paste(CutFirst, collapse="|"), " ", WhoDash$AccDescription2, ignore.case = T)
WhoDash$AccDescription2 <- gsub(paste0(CutWords, collapse="|"), " ", WhoDash$AccDescription2, ignore.case = T)
WhoDash$AccDescription2 <- gsub(" [[:alpha:]]{1} ", " ", WhoDash$AccDescription2, ignore.case = T)
WhoDash$AccDescription2 <- gsub("^\\s+|\\s+$", "", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- gsub("\\s+", " ", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- gsub(" ", " | ", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- gsub("(\\|\\s+)+", "| ", WhoDash$AccDescription2)
WhoDash$AccDescription2 <- sapply (WhoDash$AccDescription2, simpleCap)
date()


print(paste("... ",substr(date(), 12, 19), "- building WHO lookup table..."))

#  2-Wh0 LUTs ####
# unsplit = 2907
WhoLUT <- data.frame("WhoLUT" = WhoDash$DesEthnicGroupSubgroup_tab[which(nchar(WhoDash$DesEthnicGroupSubgroup_tab)>1 & is.na(WhoDash$DesEthnicGroupSubgroup_tab)==F )], stringsAsFactors = F)
WhoLUT <- strsplit(WhoLUT$WhoLUT, "\\|")
WhoLUT <- data.frame("WhoLUT" = unlist(WhoLUT), stringsAsFactors = F)
WhoLUT$WhoLUT <- gsub("^\\s+|\\s+$", "", WhoLUT$WhoLUT)
WhoCount <- dplyr::count(WhoLUT, WhoLUT)
WhoCount <- WhoCount[which(WhoCount$n > 2),]
WhoLUT <- data.frame("WhoLUT" = unique(WhoLUT[which((WhoLUT$WhoLUT %in% WhoCount$WhoLUT) &
                                                      nchar(WhoLUT$WhoLUT)>1),]),
                     stringsAsFactors = F)
WhoLUT <- data.frame("WhoLUT"=WhoLUT[order(WhoLUT$WhoLUT),], stringsAsFactors = F)


print(paste("... ",substr(date(), 12, 19), "- uniting WHO data..."))

#  3-Concat 'Who' data ####
WhoDash2 <- unite(WhoDash, "Who", DesEthnicGroupSubgroup_tab:EcbNameOfObject, sep=" | ", remove=TRUE)
WhoDash2$Who <- gsub("(\\|\\s+)+", "| ", WhoDash2$Who)
WhoDash2$Who <- gsub("^\\s+\\|\\s+$", "", WhoDash2$Who)
#FullDash3 <- subset(FullDash3, select=-c(DarCountry, DarContinent, DarContinentOcean, DarWaterBody, AccLocality, AccGeography))


#  4-Merge WHERE+WHAT+WHEN-WHO ####
FullDash7csv <- merge(FullDash6csv, WhoDash2, by=c("irn","RecordType"), all.x=T)


setwd(origdir)
