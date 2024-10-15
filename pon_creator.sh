#!/bin/bash
set -e

if [[ $# -lt 3 ]]; then
	printf "$0 \n coriandR: ChrOmosomal abeRration Identifier AND Reporter in R.\n \n To create a Panel of Normals please enter the following parameters:\n \n Name of Panel of Normals\n Path to folder with paired-end fastq-files \n Path to meta table (gender table)\n \n  Example use: bash pon_creator.sh sample.pon ~/sequence.data/sample.pon/ ~/sequence.data/sample.pon/pon.meta.csv\n \n"
fi

printf "You started pon_creator.sh - a part of coriandR: ChrOmosomal abeRration Identifier AND Reporter in R.\n This skript creates a Panel of normals tables from paired-end fastq-files and create a report. \n \n"

cp -p -v config.txt $2
cp -p -v rscripts/report.create.a.pon.and.stats.Rmd $2

printf "PON data ... "
printf "$1\t" > $2/pon.data.tsv; printf "$2\t" >> $2/pon.data.tsv; printf $3 >> $2/pon.data.tsv
printf "were generated\n \n"

cd $2

source config.txt

printf "Mapping with Bowtie2 ... \n"
for f in *_R1_001.fastq.gz; do n=$(echo $f | sed 's/_R1_001.fastq.gz//') ; echo $n; bowtie2 -x $index -p 8 -1 ${n}_R1_001.fastq.gz -2 ${n}_R2_001.fastq.gz | bash sam2bam.sh $n.bam; done 2> logs.bowtie.txt
printf "was successful\n \n"

printf "PON subjects read-table ... "
featureCounts -a $gtf -o pon.fc.tsv -T $(nproc) *.bam 2> logs.featureCounts.txt
printf "was created with FeatureCounts\n \n "

printf "GC content of the PON subjects ... "
cp -p -v $gccontent $2 
printf "was calculated with bedtools \n \n"

printf "The normalisation of PON and calculation of statistical parameters in R ... "
R -e "rmarkdown::render('report.create.a.pon.and.stats.Rmd')"
#pandoc --data-dir=pwd report.create.a.pon.and.stats.Rmd
printf "was successful\n \n"

printf "You can find the report under report.create.a.pon.and.stats.pdf in folder $2 \n \n "

rm report.create.a.pon.and.stats.Rmd
rm config.txt
rm pon.data.tsv
rm *.bam
rm *.bai
rm GRCh38.p13.genome.sizes
rm GRCh38.p13.genome.1M.bed
rm GRCh38.p13.genome.1M.nucl

printf "BAM files have been deleted \n \n "

printf "You can find the PoN table under $1.tsv in folder $2 \n \n"
