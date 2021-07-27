#!/bin/bash
set -e

if [[ $# -lt 4 ]]; then
	printf "$0 \n \n \033[1;36m coriandR: ChrOmosomal abeRration Identifier AND Reporter in R \e[0m. \n \n \033[1;31m To use coriandR in pair-end mode please enter the following parameters:\e[0m \n \n Sample ID\n Path to sample meta file \n FASTQ1: a path to the fastq-File with Read 1 \n FASTQ2: a path to the fastq-File with Read 2 \n \n Example use: bash coriander.sh 101010 /media/data/101010.meta.tsv /media/data/Fastq/101010_R1.fastq /media/data/Fastq/101010_R2.fastq \n \n \n"
fi

printf "\n \n You started \033[1;36m coriandr.sh - a part of coriandR: ChrOmosomal abeRration Identifier AND Reporter in R \e[0m.\n This skript identify copy-number variations (CNVs) in low-coverage NGS data and creates a graphic pdf-report on the selected sample from paired-end fastq-files. \n \n \n"

source config.txt

mkdir -p output/$1
cp -p -v $pon output/$1/pon.tsv
cp -p -v $2 output/$1/patient.meta.tsv

printf "\033[1;32m Mapping statistics \e[0m (raw read pairs, average read length, unique mapping pairs) ... \n"
printf "raw_read_pairs\t" > output/$1/mapping.stats.tsv; zcat $3 | awk 'NR%4==2{print}' | sort | uniq -c | wc -l >> output/$1/mapping.stats.tsv; zcat $3 | awk 'NR%4==2{a+=length($1)}END{print "average_read_length\t"(a/NR*4)}' >> output/$1/mapping.stats.tsv
printf "were generated\n \n"

printf "\033[1;32m Mapping with Bowtie2 in pair-end mode \e[0m ... \n"
bowtie2 -x $index -p $(nproc) -1 $3 -2 $4 | sam2bam output/$1/patient.bam 2> output/$1/logs.bowtie.txt
printf "was successful\n \n"

printf "\033[1;32m Sample counts table \e[0m ... \n"
~/bin/subread-2.0.0-source/bin/featureCounts -a $gtf -o output/$1/patient.fc.tsv -T $(nproc) output/$1/patient.bam 2> output/$1/logs.featureCounts.txt
printf "was created with FeatureCounts\n \n"

cp -p -v sample.report.Rmd output/$1/.

printf "\033[1;32m Normalization of the raw reads to the ploidy, calculation of the normal distribution and the application of the Gauss test to determine the p-value, adjustment of the p-value with the Benjamini-Hochberg method, exclusion of the data points with an abnormal GC content and/or abnormal variance in R \e[0m ... \n"
R -e "rmarkdown::render('output/$1/sample.report.Rmd')"
#pandoc --data-dir=pwd sample.report.Rmd
printf "was successful\n \n \n"

printf "You can find the \033[1;33m coriandR sample report under Report_coriandR.pdf in folder ./coriandR/output/$1 \e[0m \n \n"

rm output/$1/patient.bam
rm output/$1/patient.bam.bai
rm output/$1/sample.report.Rmd
rm output/$1/sample.report.tex

printf "Sample BAM file was deleted \n \n"
