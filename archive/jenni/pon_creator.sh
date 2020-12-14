#!/bin/bash
set -e

if [[ $# -lt 3 ]]; then
	printf "$0 \n coriandR: ChrOmosomal abeRration Identifier AND Reporter in R.\n To create a Panel of Normals please enter the following parameters:\n Name of Panel of Normals\n Path to folder with paired-end fastq-files \n Path to gender table\n  Example use: bash pon_creator.sh sample.pon ~/sequence.data/sample.pon/ ~/sequence.data/sample.pon/gender.table.csv\n"
fi

printf "You started pon_creator.sh - a part of coriandR: ChrOmosomal abeRration Identifier AND Reporter in R.\n This skript creates Panel of normals tables from paired-end fastq-files. \n"

cp -p -v config.txt $2
cp -p -v create_a_pon.shell.r $2

printf "PoN data ... "
printf "$1\t" > $2/pon.data.tsv; printf "$2\t" >> $2/pon.data.tsv; printf $3 >> $2/pon.data.tsv
printf "were recorded\n"

cd $2

source config.txt

printf "Mapping with Bowtie2 ... \n"
for f in *_R1_001.fastq.gz; do n=$(echo $f | sed 's/_R1_001.fastq.gz//') ; echo $n; bowtie2 -x $index -p 8 -1 ${n}_R1_001.fastq.gz -2 ${n}_R2_001.fastq.gz | ~/bin/bioinfo-toolbox/sam2bam.sh $n.bam; done 2> logs.bowtie.txt
printf "was successful\n"

printf "PoN samples read-table ... "
featureCounts -a $gtf -o pon.fc.tsv -T $(nproc) *.bam 2> logs.featureCounts.txt
printf "was created with FeatureCounts\n "

printf "The normalisation and calculation of statistical parameters in R ... "
R CMD BATCH create_a_pon.shell.r
printf "was successful\n"

rm create_a_pon.shell.r
rm config.txt
rm *.bam
rm *.bai
rm pon.data.tsv

printf "BAM files have been deleted \n "

printf "You can find the PoN table under $1.tsv in folder $2 \n"
