#!/bin/bash
set -e

if [[ $# -lt 4 ]]; then
	printf "$0 \n coriandR: ChrOmosomal abeRration Identifier AND Reporter in R. \n \n To use coriandR please enter the following parameters:\n Sample ID\n Path to sample meta file \n FASTQ1: a path to the fastq-File with Read 1 \n FASTQ2: a path to the fastq-File with Read 2 \n BAM: Path to sample.bam file\n \n Example use: bash coriander.sh 101010 /media/data/101010.meta.tsv /media/data/Fastq/101010_R1.fastq /media/data/Fastq/101010_R2.fastq /media/data/101010.bam\n \n"
fi

printf "You started coriandr.sh - a part of coriandR: ChrOmosomal abeRration Identifier AND Reporter in R.\n This skript searches for copy-number variations (CNVs) in low-coverage NGS data and creates a graphic report on the selected sample from paired-end fastq-files. \n \n"

source config.txt

mkdir -p output/$1
cp -p -v $pon output/$1/pon.tsv
cp -p -v $2 output/$1/patient.meta.tsv
cp -p -v $cytobands output/$1/cytobands.tsv
cp -p -v $genes output/$1/all_genes.tsv
cp -p -v $cgenes output/$1/cancer_genes.csv
cp -p -v $bandborders output/$1/band.borders.tsv

printf "Mapping statistics ... "
printf "raw_read_pairs\t" > output/$1/mapping.stats.tsv; zcat $3 | awk 'NR%4==2{print}' | sort | uniq -c | wc -l >> output/$1/mapping.stats.tsv; zcat $3 | awk 'NR%4==2{a+=length($1)}END{print "average_read_length\t"(a/NR*4)}' >> output/$1/mapping.stats.tsv
printf "were generated\n \n"

printf "Sample table ... "
~/bin/subread-2.0.0-source/bin/featureCounts -a $gtf -o output/$1/patient.fc.tsv -T $(nproc) $5 2> output/$1/logs.featureCounts.txt
printf "was with FeatureCounts\n \n"

cp -p -v sample.report.Rmd output/$1/.

printf "The normalisation and calculation of statistical parameters in R ... "
R -e "rmarkdown::render('output/$1/sample.report.Rmd')"
#pandoc --data-dir=pwd sample.report.Rmd
printf "was successful\n \n"

printf "You can find the report under Report_coriandR.pdf in folder ./coriandR/output/$1 \n \n"
