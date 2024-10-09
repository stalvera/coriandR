**Table of Contents**
- [About `coriandR`](#about-coriandr)
  - [`coriandR` publications](#coriandr-publications)
- [`coriandR` Installation](#coriandr-installation)
  - [Native Installation](#native-installation)
  - [Installation as Docker Container](#installation-as-docker-container)
- [`coriandR` Usage](#coriandr-usage)
- [References](#references)

_______________

## About `coriandR`

`coriandR` – ChrOmosomal abeRration Identifier AND Reporter in R – a tool for estimating the calculated karyotype and
the copy number variations in the ultra low-coverage whole-genome sequencing data, which can be used in different aspects of genetic oncological diagnostics by low costs and a high accordance with the “gold standard” method of karyotyping - conventional cytogenetics. For the estimation of the calculated karyotype and the copy number variations of a blood or tumour tissue sample, a panel of normals is generated from sequencing data. The panel of normals samples come from the same tissue type (blood or histological tumor-free tissue samples) and were processed under the same conditions as the tumor samples and have a normal karyotype.

![coriandR workflow](/documentation/images/workflow.png)

After alignment with `Bowtie2`, these sequencing data are counted with `featureCounts` and normalised by the median sequencing depth per bin. The next step is standardization with calculation of the pseudo z-values of the distribution of the reads in the bins. Later they are compared with a theoretical normal distribution of the reads number in the bins. After excluding the bins with an abnormal GC-content and/or an abnormal variance, a panel of normals can be used for further calculations.

![PON Overview with masked bins by abnormal variance or abnormal gc-content](/documentation/images/masked_bins_by_variance_or_gccontent.png)

Estimation of the calculated karyotype for the tumour samples is based on a two-tailed normal distribution test. The obtained p-values were adjusted using the Benjamini-Hochberg method in compliance with the false discovery rate. In consideration of the adjusted p-values, the deviating bins are calculated. An overview plot of the distribution of reads in the sample, a calculated karyotype, a list of copy number variations and chromosome plots are shown in `coriandR` report.

`coriandR` can be used for estimation of calculated karyotype and copy number variations in hamatological malignances and solid tumours. For statistical testings, it is nessesary to generate a panel of normals (PON) from sequencing data. The PON samples come from the same tissue type (blood or histological tumor-free tissue samples) and were processed under the same conditions as the tumour samples and have a normal karyotype. Estimation of the calculated karyotype for the tumour samples is based on a two-tailed normal distribution test.

![Calculated karyotype plot of a sample with complete chromosome 7 lost](/documentation/images/complexe_caryotype_overview_aberrations.png)

![Chromosome plot with partial 5q deletion](/documentation/images/chromosome5_q_deletion.png)

After estimation of deviating bins (deletions or amplifications) with bin size of 1.000.000 bp, genes of interest located in deviating chromosomal regions can be estimated. The first version of `coriandR` contained a genes list with cancer driver genes (Bailey et al. 2018) and genes that play an important role in disease development of acute myeloid leukemia (Papaemmanuil et al. 2016), since `coriandR` was originally developed for estimation of calculated karyotype in acute myeloid leukemia samples.

The DNPM (German Network for Personalized Medicine, ger. *Deutsches Netzwerk für Personalisierte Medizin*, https://dnpm.de/, accessed September 23, 2024) created a list of genes of interest based on the research in germline tumour-detected variants in 49,264 cancer patients (Kuzbari et al. 2023) and genetic dysfunction across all human cancers (Sondka et al. 2018) as well as the database for FDA-recognised human genetic variants `OnkoKB` (Sarah et al. 2024, https://www.oncokb.org/, accessed September 23, 2024) which can be used in the search for potential targets for the treatment of patients with solid tumours.

### `coriandR` publications

Tarawneh, T.S.; Rodepeter, F.R.; Teply-Szymanski, J.; Ross, P.; Koch, V.; Thölken, C.; Schäfer, J.A.; Gremke, N.; Mack, H.I.D.; Gold, J.; et al. Combined Focused Next-Generation Sequencing Assays to Guide Precision Oncology in Solid Tumors: A Retrospective Analysis from an Institutional Molecular Tumor Board. Cancers 2022, 14, 4430. https://doi.org/10.3390/cancers14184430.

Koch, V. Optimierung Und Vergleich Bioinformatischer Methoden Zur Kalkulierten Karyotypisierung Der Akuten Myeloischen Leukämie Mittels Next Generation Sequencing. Philipps-Universität Marburg, 2024. https://doi.org/10.17192/z2024.0288.

_______________

## `coriandR` Installation

### Native Installation

**Dependencies**

- bowtie2 (Langmead and Salzberg 2012)
- samtools (Li 2011)
- featureCounts (Liao et al. 2014)
- sam2bam (https://github.com/thoelken/bioinfo-toolbox)
- RStudio (https://www.rstudio.com/products/rstudio/download/) (knitr, markdown, rmarkdown, tinytex packages) 



**Install**

Install `sam2bam.sh` in folder `~/bin` and make the skript executable with `chmod +x ~/bin/sam2bam.sh` in terminal.

Adjust the paths to the files Bowtie2 index, gc-content, your PON table and bins.gtf in `config.txt` file.

Adjust the paths to Bowtie2, samtools, FeatureCounts and sam2bam.sh script.


### Installation as Docker Container

_______________

## `coriandR` Usage

**Running the program**

**Creation of panel of normals**

1. Prepare the table with meta data: the table contains columns with the names "sample", "gender" and rows with the names of the samples `sample1.pon.bam` that make up your PON and the genders of the samples (`M`/`F`). Use the table `pon.meta.csv`.
2. Create a folder with only the paired-end fastq files and the meta table.
3. Open the `~/coriandR/coriandR` folder in terminal.
4. To start the tool `pon.creator.sh` enter the following parameters in terminal: name of panel of normals; Path to folder with paired-end fastq-files; Path to meta table (gender table).
**Example use:**
    `bash pon_creator.sh sample.pon ~/sequence.data/sample.pon/ ~/sequence.data/sample.pon/pon.meta.csv`
5. Copy the file sample.pon.tsv to `~/coriandR/coriandR/tables` folder
6. Now you have to change the path to your new PON in `config.txt` file if you want to use this new PON. The BAM files are automatically deleted.


**Numerical karyotype and CNAs estimation from a tumor sample**

1. First modify the existing `patient.meta.tsv` file. This table contains the parameters "name", "gender", "count_data", "mapping_stats", "pon", "output_prefix". You can edit the existing file by entering the name of the sample and the gender. Save the file in the `~/coriandR/coriandR` folder.
2. Open the `~/coriandR/coriandR` folder in terminal.
3. To start the `coriandr.sh` tool, enter the following parameters in terminal: Sample ID; Path to sample meta file; FASTQ1: a path to the fastq-File with Read 1; FASTQ2: a path to the fastq-File with Read 2.
**Example use:** 
    `bash coriander.sh 101010 /media/data/101010.meta.tsv /media/data/Fastq/101010_R1.fastq /media/data/Fastq/101010_R2.fastq`
4. Now, you can find the created report in `./coriandR/output/SampleID` folder. The BAM files are automatically deleted.


**Numerical Karyotype and CNAs estimation**

For the estimation of the calculated karyotype, we used the genomic coordinates of the G-bands from the cytogenetic landmarks (Cheung et al. 2001).
The investigated genes are based on the list of the WHO classification of acute myeloid leukemia (Papaemmanuil et al. 2016) and the cancer driver genes (Bailey et al. 2018).

_______________

## References

ToDo update the references

Tarawneh, T.S.; Rodepeter, F.R.; Teply-Szymanski, J.; Ross, P.; Koch, V.; Thölken, C.; Schäfer, J.A.; Gremke, N.; Mack, H.I.D.; Gold, J.; et al. Combined Focused Next-Generation Sequencing Assays to Guide Precision Oncology in Solid Tumors: A Retrospective Analysis from an Institutional Molecular Tumor Board. Cancers 2022, 14, 4430. https://doi.org/10.3390/cancers14184430 

Bailey, Matthew H.; Tokheim, Collin; Porta-Pardo, Eduard; Sengupta, Sohini; Bertrand, Denis; Weerasinghe, Amila et al. (2018): Comprehensive Characterization of Cancer Driver Genes and Mutations. In: Cell 173 (2), 371-385.e18. DOI: 10.1016/j.cell.2018.02.060.

Ben Langmead; Steven L Salzberg (2012): Fast gapped-read alignment with Bowtie 2. In: Nat Methods 9 (4), S. 357–359. DOI: 10.1038/nmeth.1923.

Cheung, V. G.; Nowak, N.; Jang, W.; Kirsch, I. R.; Zhao, S.; Chen, X. N. et al. (2001): Integration of cytogenetic landmarks into the draft sequence of the human genome. In: Nature 409 (6822), S. 953–958. DOI: 10.1038/35057192.

Li, Heng (2011): A statistical framework for SNP calling, mutation discovery, association mapping and population genetical parameter estimation from sequencing data. In: Bioinformatics (Oxford, England) 27 (21), S. 2987–2993. DOI: 10.1093/bioinformatics/btr509.

Liao, Y.; Smyth, G. K.; Shi, W. (2014): featureCounts: an efficient general purpose program for assigning sequence reads to genomic features. In: Bioinformatics (Oxford, England) 30 (7). DOI: 10.1093/bioinformatics/btt656.

Papaemmanuil, Elli; Gerstung, Moritz; Bullinger, Lars; Gaidzik, Verena I.; Paschka, Peter; Roberts, Nicola D. et al. (2016): Genomic Classification and Prognosis in Acute Myeloid Leukemia. In: The New England journal of medicine 374 (23), S. 2209–2221. DOI: 10.1056/NEJMoa1516192.


