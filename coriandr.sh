#!/bin/bash
set -e

if [[ $# -lt 4 ]]; then
	printf "$0 \n coriandR: ChrOmosomal abeRration Identifier AND Reporter in R. To use coriandR please enter the following parameters:\n Sample ID\n Sample gender: M or F \n FASTQ1: a path to the fastq-File with Read 1 \n FASTQ2: a path to the fastq-File with Read 2 \n Example use: bash coriander.sh 101010 M /media/data/Fastq/101010_R1.fastq /media/data/Fastq/101010_R2.fastq\n"
fi

printf "You started coriandr.sh - a part of coriandR: ChrOmosomal abeRration Identifier AND Reporter in R.\n This skript searches for copy-number variations (CNVs) in low-coverage NGS data and creates a graphic report on the selected sample from paired-end fastq-files. \n"

source config.txt

mkdir -p output/$1
cp -p -v $pon output/$1/pon.tsv

printf "Mapping statistics ... "
printf "raw_read_pairs\t" > output/$1/mapping.stats.tsv; zcat $3 | awk 'NR%4==2{print}' | sort | uniq -c | wc -l >> output/$1/mapping.stats.tsv; zcat $3 | awk 'NR%4==2{a+=length($1)}END{print "average_read_length\t"(a/NR*4)}' >> output/$1/mapping.stats.tsv
printf "were generated\n"

printf "Mapping with Bowtie2 ... "
bowtie2 -x $index -p $(nproc) -1 $3 -2 $4 | sam2bam output/$1/patient.bam 2> output/$1/logs.bowtie.txt
printf "was successful\n"

printf "Sample table ... "
~/bin/subread-2.0.0-source/bin/featureCounts -a $gtf -o output/$1/patient.fc.tsv -T $(nproc) output/$1/patient.bam 2> output/$1/logs.featureCounts.txt
printf "was with FeatureCounts\n"

printf "Sample data ... "
printf "id\t$1" > output/$1/patient.data.tsv; printf "\ngender\t$2\n" >> output/$1/patient.data.tsv
printf "were generated\n"

cp -p -v Report_coriander.Rmd output/$1/.

printf "The normalisation and calculation of statistical parameters in R ... "
R -e "rmarkdown::render('output/$1/Report_coriander.Rmd')"
#pandoc --data-dir=pwd Report_coriander.Rmd
printf "was successful\n"

printf "You can find the report under Report_coriander.pdf in folder ./coriandR/output/$1 \n "

rm output/$1/patient.bam

printf "BAM file was deleted \n "
