
coriandR
===========
`coriandR`: ChrOmosomal abeRration Identifier AND Reporter in R is a tool for numerical karyotype and CNAs estimation from lcWGS sequencing (low coverage whole genome sequencing).

`coriandR` is a read-depth based tool for numerical karyotype and CNA estimation from the raw
reads of the low coverage WGS sequencing. We use a panel of normals (PON) to identify and reduce
technical artifacts. The samples for the panel of normals were obtained and sequenced under the
same conditions as the tumor samples.

Tarawneh, T.S.; Rodepeter, F.R.; Teply-Szymanski, J.; Ross, P.; Koch, V.; Thölken, C.; Schäfer, J.A.; Gremke, N.; Mack, H.I.D.; Gold, J.; et al. Combined Focused Next-Generation Sequencing Assays to Guide Precision Oncology in Solid Tumors: A Retrospective Analysis from an Institutional Molecular Tumor Board. Cancers 2022, 14, 4430. https://doi.org/10.3390/cancers14184430 

Dependencies
-----------
- bowtie2 (Langmead and Salzberg 2012)
- samtools (Li 2011)
- featureCounts (Liao et al. 2014)
- sam2bam (https://github.com/thoelken/bioinfo-toolbox)
- RStudio (https://www.rstudio.com/products/rstudio/download/) (knitr, markdown, rmarkdown, tinytex packages) 



Install
============
Install `sam2bam.sh` in folder `~/bin` and make the skript executable with `chmod +x ~/bin/sam2bam.sh` in terminal.

Adjust the paths to the files Bowtie2 index, gc-content, your PON table and bins.gtf in `config.txt` file.

Adjust the paths to Bowtie2, samtools, FeatureCounts and sam2bam.sh script.


Data preparation
============
The sequencing data from Illumina MiSeq was aligned to the reference genome with `Bowtie 2` (Langmead and Salzberg 2012) in paired-end mode (.fastq files). We used version GRCh38.p13 of the
human genome from Genome Reference Consortium as reference genome for alignment. The data
was converted to BAM format using `samtools` (Li 2011). We count the reads in the non-overlapping megabase sized bins using `featureCounts` (Liao et al. 2014).


Running the program
============

Creation of panel of normals
-----------

1. Prepare the table with meta data: the table contains columns with the names "sample", "gender" and rows with the names of the samples `sample1.pon.bam` that make up your PON and the genders of the samples (`M`/`F`). Use the table `pon.meta.csv`.
2. Create a folder with only the paired-end fastq files and the meta table.
3. Open the `~/coriandR/coriandR` folder in terminal.
4. To start the tool `pon.creator.sh` enter the following parameters in terminal: name of panel of normals; Path to folder with paired-end fastq-files; Path to meta table (gender table).
**Example use:**
    `bash pon_creator.sh sample.pon ~/sequence.data/sample.pon/ ~/sequence.data/sample.pon/pon.meta.csv`
5. Copy the file sample.pon.tsv to `~/coriandR/coriandR/tables` folder
6. Now you have to change the path to your new PON in `config.txt` file if you want to use this new PON. The BAM files are automatically deleted.

![PON Overview with masked bins by abnormal variance or abnormal gc-content](masked_bins_by_variance_or_gccontent.png)


Numerical karyotype and CNAs estimation from a tumor sample
-----------

1. First modify the existing `patient.meta.tsv` file. This table contains the parameters "name", "gender", "count_data", "mapping_stats", "pon", "output_prefix". You can edit the existing file by entering the name of the sample and the gender. Save the file in the `~/coriandR/coriandR` folder.
2. Open the `~/coriandR/coriandR` folder in terminal.
3. To start the `coriandr.sh` tool, enter the following parameters in terminal: Sample ID; Path to sample meta file; FASTQ1: a path to the fastq-File with Read 1; FASTQ2: a path to the fastq-File with Read 2.
**Example use:** 
    `bash coriander.sh 101010 /media/data/101010.meta.tsv /media/data/Fastq/101010_R1.fastq /media/data/Fastq/101010_R2.fastq`
4. Thenafter you can find the created report in `./coriandR/output/SampleID` folder. The BAM files are automatically deleted.

![Numerical caryotype overview of a sample with a chromosome 7 lost](complexe_caryotype_overview_aberrations.png)
![Chromosome plot with partial 5q deletion](chromosome5_q_deletion.png)


Numerical Karyotype and CNAs estimation
=================
For the estimation of the calculated karyotype, we used the genomic coordinates of the G-bands from the cytogenetic landmarks (Cheung et al. 2001).
The investigated genes are based on the list of the WHO classification of acute myeloid leukemia (Papaemmanuil et al. 2016) and the cancer driver genes (Bailey et al. 2018).



References
=================
Tarawneh, T.S.; Rodepeter, F.R.; Teply-Szymanski, J.; Ross, P.; Koch, V.; Thölken, C.; Schäfer, J.A.; Gremke, N.; Mack, H.I.D.; Gold, J.; et al. Combined Focused Next-Generation Sequencing Assays to Guide Precision Oncology in Solid Tumors: A Retrospective Analysis from an Institutional Molecular Tumor Board. Cancers 2022, 14, 4430. https://doi.org/10.3390/cancers14184430 

Bailey, Matthew H.; Tokheim, Collin; Porta-Pardo, Eduard; Sengupta, Sohini; Bertrand, Denis; Weerasinghe, Amila et al. (2018): Comprehensive Characterization of Cancer Driver Genes and Mutations. In: Cell 173 (2), 371-385.e18. DOI: 10.1016/j.cell.2018.02.060.

Ben Langmead; Steven L Salzberg (2012): Fast gapped-read alignment with Bowtie 2. In: Nat Methods 9 (4), S. 357–359. DOI: 10.1038/nmeth.1923.

Cheung, V. G.; Nowak, N.; Jang, W.; Kirsch, I. R.; Zhao, S.; Chen, X. N. et al. (2001): Integration of cytogenetic landmarks into the draft sequence of the human genome. In: Nature 409 (6822), S. 953–958. DOI: 10.1038/35057192.

Li, Heng (2011): A statistical framework for SNP calling, mutation discovery, association mapping and population genetical parameter estimation from sequencing data. In: Bioinformatics (Oxford, England) 27 (21), S. 2987–2993. DOI: 10.1093/bioinformatics/btr509.

Liao, Y.; Smyth, G. K.; Shi, W. (2014): featureCounts: an efficient general purpose program for assigning sequence reads to genomic features. In: Bioinformatics (Oxford, England) 30 (7). DOI: 10.1093/bioinformatics/btt656.

Papaemmanuil, Elli; Gerstung, Moritz; Bullinger, Lars; Gaidzik, Verena I.; Paschka, Peter; Roberts, Nicola D. et al. (2016): Genomic Classification and Prognosis in Acute Myeloid Leukemia. In: The New England journal of medicine 374 (23), S. 2209–2221. DOI: 10.1056/NEJMoa1516192.


