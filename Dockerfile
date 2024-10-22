# This Dockerfile creates an image for calculated karyotyping part of
# coriandR – ChrOmosomal abeRration Identifier AND Reporter in R – 
# a tool for estimating the calculated karyotype and the copy number variations 
# in the ultra low-coverage whole-genome sequencing data.
# For generation of a new Panel of Normals (PON), you need ToDo.

FROM rstudio/r-base:4.3-jammy
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y bowtie2 samtools subread

RUN set -e
RUN Rscript -e "install.packages('knitr',repos='https://cran.rstudio.com')"
RUN Rscript -e "install.packages('tinytex',repos='https://cran.rstudio.com')"
RUN Rscript -e "install.packages('rmarkdown',repos='https://cran.rstudio.com')"

RUN mkdir /coriandr
COPY ./coriandr.sh ./sam2bam.sh /coriandr
WORKDIR /coriandr
RUN chmod +x sam2bam.sh
RUN chmod +x coriandr.sh

ENTRYPOINT [ "bash", "coriandr.sh" ]
# Docker will pass the arguments from 'docker run' to the CMD line.
# It will override the arguments passed in the Dockerfile.
CMD [ "SampleID", "Path_to_sample_meta_file", "FASTQ1", "FASTQ2", "Usage_mode" ]