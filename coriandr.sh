#!/bin/bash

# $1 - Sample ID
# $2 - Path to sample meta file
# $3 - FASTQ1: path to FASTQ file with read 1
# $4 - FASTQ2: a path to FASTQ file with read 2
# $5 - Usage mode: 'standard' for displaying of all aberrations or 
# 'solid' for estimation of only high level amplifications (> 5 copies) and deletions (< 0.5 copies)

set -e

if [[ $# -lt 5 ]]; then
	printf "$0 \n \n \033[1;36m coriandR: ChrOmosomal abeRration Identifier AND Reporter in R \e[0m. \n \n \033[1;31m To use coriandR in pair-end mode please enter the following parameters:\e[0m \n \n Sample ID\n Path to sample meta file \n FASTQ1: path to the FATSQ file with read 1 \n FASTQ2: path to the FATSQ file with read 2 \n Usage mode: 'standard' for displaying of all aberrations or 'solid' for estimation of only high level amplifications (> 5 copies) and deletions (< 0.5 copies) \n \n Example use: bash coriander.sh 101010 /media/data/101010.meta.tsv /media/data/Fastq/101010_R1.fastq /media/data/Fastq/101010_R2.fastq standard \n \n \n"
fi

source config.txt

mkdir -p output/$1
cp -p -v $pon output/$1/pon.tsv
cp -p -v $2 output/$1/patient.meta.tsv

if [[ $5 = 'standard' ]]; then
	printf "\n \n You started \033[1;36m coriandr.sh - a part of coriandR: ChrOmosomal abeRration Identifier AND Reporter in R in standard mode \e[0m.\n This skript identifies copy number variations (CNVs) in ultra-low coverage whole-genome next generation sequencing data in paired-end FASTQ file format, estimates numerical karyotype and creates a graphical pdf-report of the given sample. \n \n \n"
	cp -p -v rscripts/sample.report.Rmd output/$1/.
fi

if [[ $5 = 'solid' ]]; then
	printf "\n \n You started \033[1;36m coriandr.sh - a part of coriandR: ChrOmosomal abeRration Identifier AND Reporter in R in solid mode for estimation of only high level amplifications (> 5 copies) and deletions (< 0.5 copies) \e[0m.\n This skript identifies copy number variations (CNVs) in ultra-low coverage whole-genome next generation sequencing data in paired-end FASTQ file format, estimates numerical karyotype and creates a graphical pdf-report of the given sample. \n \n \n"
	cp -p -v rscripts/sample_report_solid.Rmd output/$1/.
fi

printf "\033[1;32m Mapping statistics \e[0m (raw read pairs, average read length, unique mapping pairs) ... \n"
printf "raw_read_pairs\t" > output/$1/mapping.stats.tsv; zcat $3 | awk 'NR%4==2{print}' | sort | uniq -c | wc -l >> output/$1/mapping.stats.tsv; zcat $3 | awk 'NR%4==2{a+=length($1)}END{print "average_read_length\t"(a/NR*4)}' >> output/$1/mapping.stats.tsv
printf "have been generated. \n \n"

printf "\033[1;32m Mapping with Bowtie2 in pair-end mode \e[0m ... \n"
bowtie2 -x $index -p $(nproc) -1 $3 -2 $4 | bash sam2bam.sh output/$1/patient.bam 2> output/$1/logs.bowtie.txt
printf "has been successful. \n \n"

printf "\033[1;32m Sample counts table \e[0m ... \n"
featureCounts -a $gtf -o output/$1/patient.fc.tsv output/$1/patient.bam -T $(nproc) --countReadPairs -p 2> output/$1/logs.featureCounts.txt
printf "has been created with FeatureCounts. \n \n"

printf "\033[1;32m Normalisation of the raw reads with the ploidy, Gauss test to determine the p-value, p-values adjustment with the Benjamini-Hochberg method, estimation of calculated karyotyping and CNVs in R \e[0m ... \n"

if [[ $5 = 'standard' ]]; then
	R -e "rmarkdown::render('output/$1/sample.report.Rmd')"
	#pandoc --data-dir=pwd sample.report.Rmd # for manual tests
	rm output/$1/sample.report.Rmd
fi

if [[ $5 = 'solid' ]]; then
	R -e "rmarkdown::render('output/$1/sample_report_solid.Rmd')"
	#pandoc --data-dir=pwd sample_report_solid.Rmd # for manual tests
	rm output/$1/sample_report_solid.Rmd
fi

printf "has been successful. \n \n \n"

printf "You can find the \033[1;33m coriandR sample report under Report_coriandR.pdf in directory ./coriandR/output/$1 \e[0m \n \n"

# clean up
rm output/$1/patient.bam
rm output/$1/patient.bam.bai
rm output/$1/patient.meta.tsv
rm output/$1/pon.tsv

printf "Intermediate files have been deleted. \n \n"