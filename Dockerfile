# This Dockerfile creates an image for calculated karyotyping part of
# coriandR – ChrOmosomal abeRration Identifier AND Reporter in R – 
# a tool for estimating the calculated karyotype and the copy number variations 
# in the ultra low-coverage whole-genome sequencing data.
# For generation of a new Panel of Normals (PON), you need ToDo.

FROM rstudio/r-base:4.3-jammy
RUN apt-get update && apt-get upgrade
RUN apt-get install -y bowtie2 samtools subread

RUN set -e
RUN Rscript -e "install.packages(c(`knitr`, `tinytex`, `rmarkdown`), repos='https://cran.rstudio.com')"

COPY ./tables/* ./rscripts/* ./config.txt ./coriandr.sh ./sam2bam.sh ./patient.meta.tsv /coriandr
WORKDIR /coriandr

RUN chmod +x /coriandr/coriandr.sh
ENTRYPOINT [ "/coriandr/coriandr.sh" ]
# Docker will pass the arguments from 'docker run' to the CMD line.
# It will override the arguments passed in the Dockerfile.
CMD [ "SampleID", "Path_to_sample_meta_file", "FASTQ1", "FASTQ2", "Usage_mode" ]