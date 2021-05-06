pon = read.table("pon.marburg.fc.tsv", header=TRUE, row.names=1, stringsAsFactors=T)
pon.cols = grep("bam", names(pon))
pon$bin = 1:nrow(pon)
contigs = t(tapply(pon$bin, pon$Chr, mean))

pon$sum = rowSums(pon[, pon.cols])
pon$sd = c(apply(pon[, pon.cols], 1, sd, na.rm=T))

# GC-bias based on bedtools nucl statistics for same genome and same bins
gc = read.table("GRCh38.p13.genome.1M.nucl", stringsAsFactors=T)
pon$gc = gc[gc$V1 != 'chrM', 5]
pat = read.table("patient.fc.tsv", header=TRUE, row.names=1, stringsAsFactors=T)
pon$pat = pat[, 6]

# Unnormalized data
plot(c(t(pon[,pon.cols])), rep(1:length(pon.cols), nrow(pon)),
     log="x", xlab="#Reads", ylab="Subjects", yaxt="n", col=hsv(1:length(pon.cols)/length(pon.cols), alpha=0.1), pch=20)
plot(rep(pon$bin, length(pon.cols)), c(t(pon[,pon.cols])), ylim=c(0, qnorm(0.999, mean(as.matrix(pon[,pon.cols])), sd(as.matrix(pon[,pon.cols])))),
     col=hsv(1:length(pon.cols)/length(pon.cols), alpha=0.1), pch=20,
     xaxt="n", xlab="Genome", ylab="#Reads")
abline(v=pon$bin[pon$Start == 1])
axis(1, contigs, colnames(contigs))
lines(pon$bin, pon$pat)

# Cumulative PON
plot(pon$bin, pon$sum, ylim=c(0, qnorm(0.99, mean(pon$sum), sd(pon$sum))),
     col=ifelse(pon$sum < qnorm(0.01, mean=mean(pon$sum), sd=sd(pon$sum)) | pon$sum > qnorm(0.99, mean=mean(pon$sum), sd=sd(pon$sum), lower.tail=T), "#ff000055", "#55555522"), pch=20,
     xaxt="n", xlab="Genome", ylab="#Reads")
abline(v=c(pon$bin[pon$Start == 1], nrow(pon)))
axis(1, contigs, colnames(contigs))

# cumulative PON with SD
plot(pon$bin, pon$sum, ylim=c(0, qnorm(0.99, mean(pon$sum), sd(pon$sum))), type="n",
     xaxt="n", xlab="Genome", ylab="#Reads")
polygon(c(pon$bin, rev(pon$bin)), c(pon$sum+pon$sd, rev(pon$sum-pon$sd)), border=F, col="#55555555")
abline(v=c(pon$bin[pon$Start == 1], nrow(pon)))
axis(1, contigs, colnames(contigs))

# Normalizing PON by median
pon.norm = pon[, pon.cols]
pon.norm = data.frame(t(t(pon.norm)/apply(pon.norm, 2, sum, na.rm=T)))
pon.norm = data.frame(pon.norm/apply(pon.norm, 1, median, na.rm=T)*2)
pon$norm.var = c(apply(pon.norm, 1, var, na.rm=T))
pon$norm.pat = pon$pat/median(pon$pat)*2
plot(c(t(pon.norm)), rep(1:length(pon.cols), nrow(pon)), xlab="#Reads", ylab="Subjects", yaxt="n",
     col=hsv(1:length(pon.cols)/length(pon.cols), alpha=0.1), pch=20, xlim=c(0, 6))
plot(rep(pon$bin, length(pon.cols)), c(as.matrix(pon.norm)), ylim=c(0, 6),
     col=rep(hsv(1:length(pon.cols)/length(pon.cols), alpha=0.1), each=nrow(pon)), pch=20,
     xaxt="n", xlab="Genome", ylab="#Reads")
abline(v=c(pon$bin[pon$Start == 1], nrow(pon)))
axis(1, contigs, colnames(contigs))
lines(pon$bin, pon$norm.pat)
points(pon$bin, pon$gc*4, col=rgb(pon$gc, 0.5, 1-pon$gc, 0.7), pch="-")

# GC-Bias
plot(rep(pon$gc, ncol(pon.norm)), c(as.matrix(pon.norm)), pch=19, xlim=c(0.2, 0.7), ylim=c(0, 4),
     col=hsv(1:length(pon.cols)/length(pon.cols), alpha=0.1), xlab="GC-content", ylab="Normalized Abundance")

library(robust)
pon$norm.var = c(apply(pon.norm, 1, var, na.rm=T))
plot(pon$gc, pon$norm.var, col="#33ff3311", pch=19, ylim=c(0.0001, 0.3), xlim=c(0.3, 0.6), xlab="GC-content", ylab="Variance of normalized abundance")
gc.var = predict(loess(norm.var ~ gc, pon[pon$gc > 0.3 & pon$gc < 0.6,]), 350:550/1000)
lines(350:550/1000, gc.var)
#lines(predict(glmRob(norm.var ~ gc, pon[pon$gc > 0.35 & pon$gc < 0.6,], family="poisson"), newdata=data.frame(gc=350:550/1000)), col="red")

# Cleaning the PON
# clear single bins of single PON subjects where depth is below 90% of other subjects
pon.norm.clean = data.frame(t(apply(pon.norm, 1, function(x) {x[x < qnorm(0.01, mean(x), sd(x)) | x > qnorm(0.99, mean(x), sd(x))] = NA; x})))
plot(rep(pon$bin, length(pon.cols)), c(as.matrix(pon.norm)), ylim=c(0, 6),
     col=ifelse(is.na(c(as.matrix(pon.norm.clean))), "#ff000055", "#55555522"), pch=20,
     xaxt="n", xlab="Genome", ylab="#Reads")
abline(v=c(pon$bin[pon$Start == 1], nrow(pon)))
axis(1, contigs, colnames(contigs))

pon$gc_blocked = pon$gc < qnorm(0.1, mean(pon$gc, na.rm=T), sd(pon$gc, na.rm=T)) |
  pon$gc > qnorm(0.9, median(pon$gc, na.rm=T), sd(pon$gc, na.rm=T), lower.tail=T)
plot(rep(pon$bin, length(pon.cols)), c(as.matrix(pon.norm.clean)), ylim=c(0, 6),
     col=ifelse(pon$gc_blocked, "#ff000055", "#55555522"), pch=20,
     xaxt="n", xlab="Genome", ylab="#Reads")
abline(v=c(pon$bin[pon$Start == 1], nrow(pon)))
axis(1, contigs, colnames(contigs))

pon$norm.clean.var = c(apply(pon.norm.clean, 1, var, na.rm=T))
pon$var_blocked = pon$sum < 1 | pon$norm.clean.var > qnorm(0.5, mean(pon$norm.clean.var[!pon$gc_blocked], na.rm=T), sd(pon$norm.clean.var[!pon$gc_blocked], na.rm=T))


plot(rep(pon$bin, length(pon.cols)), c(as.matrix(pon.norm.clean)), ylim=c(0, 6),
     col=ifelse(pon$var_blocked, "#ff000055", "#55555522"), pch=ifelse(pon$gc_blocked, 4, 20),
     xaxt="n", xlab="Genome", ylab="#Reads")
abline(v=c(pon$bin[pon$Start == 1], nrow(pon)))
axis(1, contigs, colnames(contigs))
pon$norm.clean.var[pon$gc_blocked | pon$var_blocked] = NA
pon.norm.clean[pon$gc_blocked | pon$var_blocked, ] = rep(NA, ncol(pon.norm))

pon$norm.pat[pon$var_blocked | pon$gc_blocked] = NA

plot(pon$gc, pon$norm.clean.var, col="#33ff3311", pch=19, ylim=c(0.00001, 0.3), xlim=c(0.3, 0.6), xlab="GC-content", ylab="Variance of normalized abundance")
gc.var.clean = predict(loess(norm.clean.var ~ gc, pon[pon$gc > 0.35 & pon$gc < 0.6,]), 350:550/1000)
lines(350:550/1000, gc.var.clean)
#lines(pon$gc[pon$gc > 0.35 & pon$gc < 0.6], c(robust::glmRob(norm.clean.var ~ gc, pon[pon$gc > 0.35 & pon$gc < 0.6,], family="poisson")$fitted.values), col="red")
#plot(robust::glmRob(norm.clean.var ~ gc, pon, family="poisson"))

plot(rep(pon$gc, ncol(pon.norm)), c(as.matrix(pon.norm.clean)), pch=19, xlim=c(0.2, 0.7), ylim=c(0, 4),
     col=hsv(1:length(pon.cols)/length(pon.cols), alpha=0.1), xlab="GC-content", ylab="Normalized Abundance")


plot(c(t(pon.norm.clean)), rep(1:length(pon.cols), nrow(pon)), xlab="#Reads", ylab="Subjects", yaxt="n",
     col=hsv(1:length(pon.cols)/length(pon.cols), alpha=0.1), pch=20, xlim=c(0, 4))
plot(rep(pon$bin, length(pon.cols)), c(as.matrix(pon.norm.clean)), ylim=c(0, 4),
     col=rep(hsv(1:length(pon.cols)/length(pon.cols), alpha=0.1), each=nrow(pon)), pch=20, cex=0.5,
     xaxt="n", xlab="Genome", ylab="#Reads")
abline(v=c(pon$bin[pon$Start == 1], nrow(pon)))
axis(1, contigs, colnames(contigs))
lines(pon$bin, pon$norm.pat, lwd=0.5)

rate = with(pon[!(pon$gc_blocked | pon$var_blocked), ], sum(pat)/sum(sum))
sd = sd(unlist(pon.norm.clean)/2, na.rm=T)
pon$pat.z = (pon$norm.pat-2)/2 / sd
pon$binom = apply(pon[, c("pat", "sum")], 1, function(x) ifelse(x[2] > 0, binom.test(x[1], x[2], rate)$p.value, 1))
pon$binom.adjust = p.adjust(pon$binom, method="hochberg")
pon$ttest = ifelse(pon$gc_blocked | pon$var_blocked, 1, 2*pnorm(q=-abs(pon$pat.z)))

plot(seq(from=-10, to=10, by=0.1), dnorm(seq(from=-10, to=10, by=0.1)), type='l', col="gray",
     main="Patien z-values compared to estimated PON distribution", ylab="Density", xlab="z-value")
lines(density(pon$pat.z, na.rm=T), col="red")
legend("topright", legend=c("Estimated PON", "Patient"), col=c("gray", "red"), lty=1)

