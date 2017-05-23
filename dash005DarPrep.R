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


# # # # to do:
#
# 1 - check header against fields in each of the What/Where/When/Who scripts... 
# 2 - map away

colnames(Naturalis2)

write.table(colnames(Naturalis2), file="IPTcolnames.csv", row.names = F, col.names = F, sep=",")
write.table(head(Naturalis2), file="IPThead.csv", row.names = F, col.names = T, sep=",")

