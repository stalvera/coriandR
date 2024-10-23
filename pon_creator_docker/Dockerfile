# This Dockerfile creates an image for geberation of a Panel of Normals (PON) with
# coriandR – ChrOmosomal abeRration Identifier AND Reporter in R – 
# a tool for estimating the calculated karyotype and the copy number variations 
# in the ultra low-coverage whole-genome sequencing data.

FROM rstudio/r-base:4.3-jammy
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y bowtie2 samtools subread

RUN set -e
RUN Rscript -e "install.packages('knitr',repos='https://cran.rstudio.com')"
RUN Rscript -e "install.packages('tinytex',repos='https://cran.rstudio.com')"
RUN Rscript -e "install.packages('rmarkdown',repos='https://cran.rstudio.com')"

RUN mkdir /coriandr
COPY ./pon_creator.sh ./sam2bam.sh /coriandr
WORKDIR /coriandr
RUN chmod +x sam2bam.sh
RUN chmod +x pon_creator.sh

ENTRYPOINT [ "bash", "pon_creator.sh" ]
# Docker will pass the arguments from 'docker run' to the CMD line.
# It will override the arguments passed in the Dockerfile.
CMD [ "PON_name", "Path_to_samples_for_PON", "Path_to_PON_meta_file" ]