###################################################################################################
# Mit dieser Datei wird ein PON erstellt und gespeichert, so dass
# es dem CORIANDER so ohne Weiteres übergeben werden kann
###################################################################################################

path.to.programm = "/media/vera/big_data/coriandR"
path.output = "/media/vera/big_data/coriandR/tables"
pon.table.name = "pon.muenchen.tsv"


setwd(path.to.programm)
pon = read.table("./tables/pon.muenchen.fc.tsv", header = TRUE, row.names = 1)
# grep('.bam', colnames(pon))
gender_pon = read.table("./tables/gender.muenchen.pon.tsv.csv",
                        header = TRUE, sep = ",", row.names = 1)


panel_of_normals_normalization <- function(pon) {
  pon_norm <- t(t(pon[ , 6:ncol(pon)]) / colSums(pon[ , 6:ncol(pon)])) * (pon[1, 3] - pon[1, 2] + 1)
  pon_norm <- cbind(pon[ , 1:5], pon_norm)
  # Die laenge der bins wird aus der Differenz automatisch ermittelt
  return(pon_norm)
}


# PON nach den Geschlechtern trennen
# Hierbei werden die X- und Y-Chromosome in 4 Chromosomen (chrX_F, chrX_M, chrY_F, chrY_M) aufgeteilt
# diese werden je nach Geschlecht mit den Werten aus der eigentlichen Patiententabelle gefüllt
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


# Der PON-Tabelle Spalten mit mean und sd  zur weiteren Berechnungen geben
# "na.rm = TRUE", um die NA's, die durch die Geschlechter-Aufteilung entstehen,
# nicht in die Berechnung miteinzubeziehen
means_panel_of_normals <- function(pon) {
  
  pon_means <- apply(pon[ , 6:(ncol(pon))], 1, function(x) mean(x, na.rm = TRUE))
  pon_sd <- apply(pon[ , 6:(ncol(pon))], 1, function(x) sd(x, na.rm = TRUE))
  
  return (cbind(pon, 'mean'=pon_means, 'sd'=pon_sd))
}



###################################################################################################
pon = panel_of_normals_normalization(pon)
pon = gendering_pon(pon, gender_pon)
pon = means_panel_of_normals(pon)

setwd(path.output)
write.table(pon, file = pon.table.name, sep = "\t", row.names = TRUE, col.names = NA)

