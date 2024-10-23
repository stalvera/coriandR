#!/bin/bash
set -e

if [[ $# -lt 3 ]]; then
	printf "$0 \n coriandR: ChrOmosomal abeRration Identifier AND Reporter in R.\n \n To create a Panel of Normals please enter the following parameters:\n \n Name of Panel of Normals\n Path to folder with paired-end FASTQ files \n Path to meta table (gender table) for PON \n \n  Example use: bash pon_creator.sh sample.pon ~/sequence.data/sample.pon/ ~/sequence.data/sample.pon/pon.meta.csv\n \n"
fi

printf "You started pon_creator.sh - a part of coriandR: ChrOmosomal abeRration Identifier AND Reporter in R.\n This skript creates a Panel of normals table from paired-end FASTQ files which can be used for estimation of calculated karyotype with coriandR as well as creates a graphical report in PDF file format. \n \n"

cp -p -v rscripts/report.create.a.pon.and.stats.Rmd $2

printf "PON data ... "
printf "$1\t" > $2/pon.data.tsv; printf "$2\t" >> $2/pon.data.tsv; printf $3 >> $2/pon.data.tsv
printf "have been generated. \n \n"

cd $2

source ../config.txt

printf "Mapping with Bowtie2 ... \n"
for f in *_R1_001.fastq.gz; do n=$(echo $f | sed 's/_R1_001.fastq.gz//') ; echo $n; bowtie2 -x ../$index -p $(nproc) -1 ${n}_R1_001.fastq.gz -2 ${n}_R2_001.fastq.gz | bash ../sam2bam.sh $n.bam; done 2> logs.bowtie.txt
printf "has been successful. \n \n"

printf "PON subjects read-table ... "
featureCounts -a ../$gtf -o pon.fc.tsv -T $(nproc) --countReadPairs -p *.bam 2> logs.featureCounts.txt
printf "has been created with FeatureCounts. \n \n "

printf "GC content of the PON subjects ... "
cp -p -v ../$gccontent .
printf "has been calculated with Bedtools. \n \n"

printf "The normalisation and calculation of statistical parameters in R ... "
R -e "rmarkdown::render('report.create.a.pon.and.stats.Rmd')"
#pandoc --data-dir=pwd report.create.a.pon.and.stats.Rmd
printf "have been successful. \n \n"

printf "You can find the report under report.create.a.pon.and.stats.pdf in folder $2 \n \n "

# clean up
rm report.create.a.pon.and.stats.Rmd
rm pon.data.tsv
rm *.bam
rm *.bai
rm GRCh38.p13.genome.sizes
rm GRCh38.p13.genome.1M.bed
rm GRCh38.p13.genome.1M.nucl

printf "BAM files have been deleted. \n \n "

printf "You can find the PON table under $1.tsv in folder $2 \n \n"
