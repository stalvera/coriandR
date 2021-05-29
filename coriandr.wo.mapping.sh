#!/bin/bash
set -e

if [[ $# -lt 4 ]]; then
	printf "$0 \n coriandR: ChrOmosomal abeRration Identifier AND Reporter in R. \n \n To use coriandR please enter the following parameters:\n Sample ID\n Sample gender: 'M' or 'F' \n FASTQ1: a path to the fastq-File with Read 1 \n FASTQ2: a path to the fastq-File with Read 2 \n \n Example use: bash coriander.sh 101010 M /media/data/Fastq/101010_R1.fastq /media/data/Fastq/101010_R2.fastq\n \n"
fi

printf "You started coriandr.sh - a part of coriandR: ChrOmosomal abeRration Identifier AND Reporter in R.\n This skript searches for copy-number variations (CNVs) in low-coverage NGS data and creates a graphic report on the selected sample from paired-end fastq-files. \n \n"

source config.txt

mkdir -p output/$1
cp -p -v $pon output/$1/pon.tsv

printf "Mapping statistics ... "
printf "raw_read_pairs\t" > output/$1/mapping.stats.tsv; zcat $3 | awk 'NR%4==2{print}' | sort | uniq -c | wc -l >> output/$1/mapping.stats.tsv; zcat $3 | awk 'NR%4==2{a+=length($1)}END{print "average_read_length\t"(a/NR*4)}' >> output/$1/mapping.stats.tsv
printf "were generated\n \n"

printf "Sample table ... "
~/bin/subread-2.0.0-source/bin/featureCounts -a $gtf -o output/$1/patient.fc.tsv -T $(nproc) output/$1/patient.bam 2> output/$1/logs.featureCounts.txt
printf "was with FeatureCounts\n \n"

printf "GC content of the sample subject ... "
samtools faidx $reference -o GRCh38.p13.genome.fa.fai
cut -f 1,2 $reference.fai | sed -n '/chr/p' > GRCh38.p13.genome.sizes
bedtools makewindows -g GRCh38.p13.genome.sizes -w 1000000 > GRCh38.p13.genome.1M.bed
bedtools nuc -fi $reference -bed GRCh38.p13.genome.1M.bed > GRCh38.p13.genome.1M.nucl 
printf "was calculated with bedtools \n \n"

printf "Sample data ... "
printf "id\t$1" > output/$1/patient.data.tsv; printf "\ngender\t$2\n" >> output/$1/patient.data.tsv
printf "were generated\n \n"

cp -p -v sample.report.Rmd output/$1/.

printf "The normalisation and calculation of statistical parameters in R ... "
R -e "rmarkdown::render('output/$1/sample.report.Rmd')"
#pandoc --data-dir=pwd sample.report.Rmd
printf "was successful\n \n"

printf "You can find the report under Report_coriandR.pdf in folder ./coriandR/output/$1 \n \n"

