#!/bin/bash
set -e

if [[ $# -lt 3 ]]; then
	printf "$0 \n coriandR: ChrOmosomal abeRration Identifier AND Reporter in R.\n To create a Panel of Normals please enter the following parameters:\n Name of Panel of Normals\n Path to folder with paired-end fastq-files \n Path to gender table\n  Example use: bash pon_creator.sh sample.pon ~/sequence.data/sample.pon/ ~/sequence.data/sample.pon/gender.table.csv\n"
fi

source config.txt

printf "PoN data ... "
$1 > $2/pon.data.tsv; $3 >> $2/pon.data.tsv
printf "were recorded\n"

cd $2

printf "Mapping with Bowtie2 ... "
for f in *_R1_001.fastq.gz; do n=$(echo $f | sed 's/_R1_001.fastq.gz//') ; echo $n; bowtie2 -x $index -p 8 -1 ${n}_R1_001.fastq.gz -2 ${n}_R2_001.fastq.gz | bash sam2bam.sh $n.bam; done 2> output/$1/logs.bowtie.txt
printf "was successful\n"

printf "Patient table ... "
~/bin/subread-2.0.0-source/bin/featureCounts -a $gtf -o $1.fc.tsv -T $(nproc) *.bam 2> output/$1/logs.featureCounts.txt
printf "was created with FeatureCounts\n "
