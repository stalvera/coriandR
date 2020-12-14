###################################################################################################
# With this script the PoN table is created, which is used directly by coriandR.
# The steps are normalization, calculation of statistical parameters and gender segregation.
###################################################################################################

#Data finding
#setwd("/media/vera/big_data/mr_genoms/test.create.pon")
pon.data = read.table("pon.data.tsv", stringsAsFactors = F)

pon.name = pon.data[1,1]
fastq.dir = pon.data[1,2]
gender.dir = pon.data[1,3]

pon = read.table("pon.fc.tsv", header = TRUE, row.names = 1)
gender_pon = read.table(gender.dir, header = TRUE, sep = ",", row.names = 1)

# The normalisation of Panel of normals by median
panel_of_normals_normalization <- function(pon) {
  pon_norm <- pon[ , 1:5]
  for (c in 6:ncol(pon)) {
    pon_norm[ , c] <- pon[ , c] / median(pon[ , c]) *2
  }
  return(pon_norm)
}


# PoN gender segregation
gendering_pon <- function(pon, gender_pon) {
  # gender_pon ist eine tabelle mit den spaltennamen im PON und mit den dazugehoerigen geschlechtern
  
  # zuerst das X-Chromosom in chrX_F und chrX_M aufteilen
  chrn = "chrX"
  # in eine separate tabelle werden alle zeilen von x-chr reingepackt
  pon.copy = pon[pon$Chr == chrn, ]
  # allen zeilen wird der suffix "_M" zugewiesen
  pon.copy$Chr = paste0(pon.copy$Chr, "_M")
  # nur die maenner sollten die werte fuer chrX_M behalten
  pon.copy[, 6:ncol(pon.copy)][, gender_pon$sex == "F"] = NA
  pon.new = rbind(pon, pon.copy)
  
  pon.copy = pon[pon$Chr == chrn, ]
  pon.copy$Chr = paste0(pon.copy$Chr, "_F")
  pon.copy[, 6:ncol(pon.copy)][, gender_pon$sex == "M"] = NA
  # pon.new ist jetzt um 2 "X-chr" groesser
  pon.new = rbind(pon.new, pon.copy)
  
  # dann Y-Chromosom
  chrn = "chrY"
  pon.copy = pon[pon$Chr == chrn, ]
  pon.copy$Chr = paste0(pon.copy$Chr, "_M")
  pon.copy[, 6:ncol(pon.copy)][, gender_pon$sex == "F"] = NA
  pon.new = rbind(pon.new, pon.copy)
  
  pon.copy = pon[pon$Chr == chrn, ]
  pon.copy$Chr = paste0(pon.copy$Chr, "_F")
  pon.copy[, 6:ncol(pon.copy)][, gender_pon$sex == "M"] = NA
  pon.new = rbind(pon.new, pon.copy)
  
  # zeilen mit den eigentlichen X- und Y-chromosomen loeschen
  pon.new = pon.new[!(pon.new$Chr == "chrX" | pon.new$Chr == "chrY"), ]
  pon = pon.new
}


means_panel_of_normals <- function(pon) {
  
  pon_means <- apply(pon[ , 6:(ncol(pon))], 1, function(x) mean(x, na.rm = TRUE))
  pon_sd <- apply(pon[ , 6:(ncol(pon))], 1, function(x) sd(x, na.rm = TRUE))
  
  return (cbind(pon, 'mean'=pon_means, 'sd'=pon_sd))
}


###################################################################################################
pon = panel_of_normals_normalization(pon)
pon = gendering_pon(pon, gender_pon)
pon = means_panel_of_normals(pon)

write.table(pon, file = paste0(pon.name, ".tsv"), sep = "\t", row.names = TRUE, col.names = NA)

