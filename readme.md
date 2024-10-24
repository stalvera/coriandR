
## About `coriandR`

`coriandR` – ChrOmosomal abeRration Identifier AND Reporter in R – a tool for estimating the calculated karyotype and
the copy number variations in the ultra low-coverage whole-genome sequencing data, which can be used in different aspects of genetic oncological diagnostics by low costs and a high accordance with the “gold standard” method of karyotyping - conventional cytogenetics. For the estimation of the calculated karyotype and the copy number variations of a blood or tumour tissue sample, a panel of normals is generated from sequencing data. The panel of normals samples come from the same tissue type (blood or histological tumor-free tissue samples) and were processed under the same conditions as the tumor samples and have a normal karyotype.

![coriandR workflow](/documentation/images/workflow.png)

After alignment with `Bowtie2`, these sequencing data are counted with `featureCounts` and normalised by the median sequencing depth per bin. The next step is standardization with calculation of the pseudo z-values of the distribution of the reads in the bins. Later they are compared with a theoretical normal distribution of the reads number in the bins. After excluding the bins with an abnormal gc content and/or an abnormal variance, a Panel of Normals (PON) can be used for further calculations.

![PON Overview with masked bins by abnormal variance or abnormal gc-content](/documentation/images/masked_bins_by_variance_or_gccontent.png)

Estimation of the calculated karyotype for the tumour samples is based on a two-tailed normal distribution test. The obtained p-values were adjusted using the Benjamini-Hochberg method in compliance with the false discovery rate. In consideration of the adjusted p-values, the deviating bins are calculated. An overview plot of the distribution of reads in the sample, a calculated karyotype, a list of copy number variations and chromosome plots are shown in `coriandR` report.

`coriandR` can be used for estimation of calculated karyotype and copy number variations in hamatological malignances and solid tumours. For statistical testings, it is nessesary to generate a panel of normals (PON) from sequencing data. The PON samples come from the same tissue type (blood or histological tumor-free tissue samples) and were processed under the same conditions as the tumour samples and have a normal karyotype. Estimation of the calculated karyotype for the tumour samples is based on a two-tailed normal distribution test.

![Calculated karyotype plot of a sample with complete chromosome 7 lost](/documentation/images/complexe_caryotype_overview_aberrations.png)

![Chromosome plot with partial 5q deletion](/documentation/images/chromosome5_q_deletion.png)

For calculated karyotyping with `coriandR`, you can choose between the `standard` and `solid` mode. After estimation of deviating bins (deletions or amplifications) with bin size of 1.000.000 bp, genes of interest located in deviating chromosomal regions can be estimated. In `standard` mode, `coriandR` will use the genes list with cancer driver genes (Bailey et al. 2018) and genes that play an important role in disease development of acute myeloid leukemia (Papaemmanuil et al. 2016), since `coriandR` was originally developed for estimation of calculated karyotype in acute myeloid leukemia samples.

In `solid` mode, only high level amplifications (> 5 copies) and deletions with copy number of < 0.5 are estimated to be changed for enhanced identification of targets for cancer treatment. The list of genes of interest based on the research in germline tumour-detected variants in 49,264 cancer patients (Kuzbari et al. 2023) and genetic dysfunction across all human cancers (Sondka et al. 2018) as well as the database for FDA-recognised human genetic variants `OnkoKB` (Sarah et al. 2024, https://www.oncokb.org/) by the DNPM (German Network for Personalized Medicine, https://dnpm.de/) will be used for calculated karyotyping and can provide researchers with information about potential targets for the treatment of patients with solid tumours.

### `coriandR` publications

Tarawneh, T.S.; Rodepeter, F.R.; Teply-Szymanski, J.; Ross, P.; Koch, V.; Thölken, C.; Schäfer, J.A.; Gremke, N.; Mack, H.I.D.; Gold, J.; et al. Combined Focused Next-Generation Sequencing Assays to Guide Precision Oncology in Solid Tumors: A Retrospective Analysis from an Institutional Molecular Tumor Board. Cancers 2022, 14, 4430. https://doi.org/10.3390/cancers14184430.

Koch, V. Optimierung Und Vergleich Bioinformatischer Methoden Zur Kalkulierten Karyotypisierung Der Akuten Myeloischen Leukämie Mittels Next Generation Sequencing. Philipps-Universität Marburg, 2024. https://doi.org/10.17192/z2024.0288.

_______________

## `coriandR` Installation

### Native Installation

To run calculated karyotyping with `coriandR`, you need following tools to be installed on your computer with UNIX/Linux OS:

 - `Bowtie2` (version 2.3.5.1, Langmead und Salzberg 2012)
 - `SAMtools` (Li et al. 2012) in version 1.20
 - `FeatureCounts` (Liao et al. 2014) in version 2.0.6
 - `RStudio` in version 2024.09.0 and programming language `R` in version 4.3.3 with packages `base` (version 4.3.3), `datasets` (version 4.3.3), `methods` (version 4.3.3), `stats` (version 4.3.3), `utils` (version 4.3.3), `graphics` (version 4.3.3), `grDevises` (version 4.3.3), `knitr` (Xie 2014, version 1.48), `tinytex` (Xie 2019, version 0.53) and `rmarkdown` (Allaire et al. 2014, version 2.28).

1. Install all dependencies.
2. Clone the `coriandR` `git` repository.
3. Open terminal and change into `coriandR` directory with `cd [path to coriandR folder]`.
4. Make `sam2bam.sh` script executable with `chmod +x sam2bam.sh`.
5. You can start calculated karyotyping with `coriandR` with `bash coriander.sh [Sample ID] [path to patient.meta.tsv] [input/[read_1].fastq.gz] [input/[read_2].fastq.gz] [Usage mode: 'standard' or 'solid']`

### Installation as Docker Container

#### Calculated karyotyping

1. Clone the `coriandR` `git` repository.
2. Open terminal and change into `coriandR` directory with `cd [path to coriandR folder]`.
3. Build a `Docker` image of `coriandR` with `sudo docker build .`. `Docker` will use the `Dockerfile` in `coriandR` root directory to install all dependencies and tools. This process will take some time, but you only need to build the image once.
4. Check the ID of your image with `sudo docker image ls`.
5. Copy `IMAGE ID` of `coriandR` image.
6. Create a folder `input` in `coriandR` directory and copy your FASTQ files (read 1 and 2) into it.
7. Finally, you can use `coriandR` container for calculated karyotyping with the command `sudo docker run -v .:/coriandr [IMAGE ID] [Sample ID] [path to patient.meta.tsv] [input/[read_1].fastq.gz] [input/[read_2].fastq.gz] [Usage mode: 'standard' or 'solid']`

#### Generation of a new Panel of Normals

1. Clone the `coriandR` `git` repository.
2. Save the `Dockerfile` for calculated karyotyping in the root directory somewhere else. Put `Dockerfile` from `pon_creator_docker` folder into the `coriandR` root directory.
3. Open terminal and change into `coriandR` directory with `cd [path to coriandR folder]`.
4. Build a `Docker` image of `coriandR` with `sudo docker build .`. `Docker` will use the `Dockerfile` to install all dependencies and tools. This process will take some time, but you only need to build an image once.
5. Check the ID of your image with `sudo docker image ls`.
6. Copy `IMAGE ID` of `coriandR` image.
7. Create a folder `input` in `coriandR` directory and copy your FASTQ files (read 1 and 2) for PON into it + tabl with meta information.
8. Finally, you can use `coriandR` for generation of a new Panel of Normals with the command `sudo docker run -v .:/coriandr [IMAGE ID] [PON ID] input/ [path to pon.meta.csv]`

_______________

## `coriandR` Usage

### What to adapt for your analysis

You need to change the paths in the file `config.txt` to absolute paths in your file system:

- `index` which means the index of the reference genome in `Bowtie2`. You need to create an index of your version of reference genome first.
- `gtf` where you need to set the path to the bin annotation file in your cloned repository like `/home/user/coriandR/tables/genome/bins.gtf`.
- `pon` where you need to set the path to the Panel of normals (PON) table like `/home/user/coriandR/tables/pon.tsv`.
- `gccontent` where you need to set the path to the gc content file of the human reference genome in you cloned repository like `/home/user/coriandR/tables/GRCh38.p13.genome.1M.nucl`.

To use `coriandR` in `Docker`, you need to copy the `Bowtie2` index into the `coriandR` directory, like `index="tables/genome/bowtie_index/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.bowtie_index"`. Likewise for `Bowtie2` index, `coriandR` in `Docker` will only accept relative paths to needed tables and sources: `gtf="tables/genome/bins.gtf"`, `pon="tables/pon.tsv"`, `gccontent="tables/GRCh38.p13.genome.1M.nucl"`.

The file `patient.meta.tsv` contains information about the `sampleID` and patients `gender`. You need to change them according to your data.

### How to Create a Panel of Normals

1. Prepare a table with meta data: this table contains columns "sample" and "gender". The samples with IDs like `sample1.fastq.gz` and the genders of the samples (`M`/`F`) separated by `,` will be used for further calculations. You can use the premade table `pon.meta.csv`.
2. Create a folder with only the paired-end FASTQ PON samples and table with meta information.
3. Open the `coriandR` folder in terminal.
4. To start the tool `pon.creator.sh` enter the following mandatory parameters in terminal: 
  - name of the new panel of normals;
  - path to folder with paired-end FASTQ files; 
  - path to meta table (gender table).

**Example use:** 

`bash pon_creator.sh pon data/sample.pon/ data/sample.pon/pon.meta.csv`

### How to Generate a Calculated Karyotyping Report of a Tumour Sample

You can use `coriandR` native or in a container. The script `coriandr.sh` requires 5 mandatory arguments.

1. Sample ID
2. Path to sample meta file
3. FASTQ1: path to FASTQ file with read 1
4. FASTQ2: a path to FASTQ file with read 2
5. Usage mode: 'standard' for displaying of all aberrations or 'solid' for estimation of only high level amplifications (> 5 copies) and deletions (< 0.5 copies)

**Example use:** 

`bash coriander.sh 101010 /data/101010.meta.tsv /data/Fastq/101010_R1.fastq /data/Fastq/101010_R2.fastq standard`
_______________

## References

Allaire J, Xie Y, Dervieux C, McPherson J, Luraschi J, Ushey K, Atkins A, Wickham H, Cheng J, Chang W, Iannone R (2024). _rmarkdown: Dynamic Documents for R_. R package version 2.28, <https://github.com/rstudio/rmarkdown>.

Bailey, Matthew H.; Tokheim, Collin; Porta-Pardo, Eduard; Sengupta, Sohini; Bertrand, Denis; Weerasinghe, Amila et al. (2018): Comprehensive Characterization of Cancer Driver Genes and Mutations. In: Cell 173 (2), 371-385.e18. DOI: 10.1016/j.cell.2018.02.060.

Ben Langmead; Steven L Salzberg (2012): Fast gapped-read alignment with Bowtie 2. In: Nat Methods 9 (4), S. 357–359. DOI: 10.1038/nmeth.1923.

Cheung, V. G.; Nowak, N.; Jang, W.; Kirsch, I. R.; Zhao, S.; Chen, X. N. et al. (2001): Integration of cytogenetic landmarks into the draft sequence of the human genome. In: Nature 409 (6822), S. 953–958. DOI: 10.1038/35057192.

Koch, V. Optimierung Und Vergleich Bioinformatischer Methoden Zur Kalkulierten Karyotypisierung Der Akuten Myeloischen Leukämie Mittels Next Generation Sequencing. Philipps-Universität Marburg, 2024. https://doi.org/10.17192/z2024.0288. 

Kuzbari Z, Bandlamudi C, Loveday C, Garrett A, Mehine M, George A, Hanson H, Snape K, Kulkarni A, Allen S, Jezdic S, Ferrandino R, Westphalen CB, Castro E, Rodon J, Mateo J, Burghel GJ, Berger MF, Mandelker D, Turnbull C. Germline-focused analysis of tumour-detected variants in 49,264 cancer patients: ESMO Precision Medicine Working Group recommendations. Annals of Oncology. 2023 Mar 1;34(3):215-227. doi: 10.1016/j.annonc.2022.12.003.

Li, Heng (2011): A statistical framework for SNP calling, mutation discovery, association mapping and population genetical parameter estimation from sequencing data. In: Bioinformatics (Oxford, England) 27 (21), S. 2987–2993. DOI: 10.1093/bioinformatics/btr509.

Liao, Y.; Smyth, G. K.; Shi, W. (2014): featureCounts: an efficient general purpose program for assigning sequence reads to genomic features. In: Bioinformatics (Oxford, England) 30 (7). DOI: 10.1093/bioinformatics/btt656.

Papaemmanuil, Elli; Gerstung, Moritz; Bullinger, Lars; Gaidzik, Verena I.; Paschka, Peter; Roberts, Nicola D. et al. (2016): Genomic Classification and Prognosis in Acute Myeloid Leukemia. In: The New England journal of medicine 374 (23), S. 2209–2221. DOI: 10.1056/NEJMoa1516192.

R Core Team (2024). _R: A Language and Environment for Statistical Computing_. R Foundation for Statistical Computing, Vienna, Austria. <https://www.R-project.org/>.

Sarah P. Suehnholz, Moriah H. Nissan, Hongxin Zhang, Ritika Kundra, Subhiksha Nandakumar, Calvin Lu, Stephanie Carrero, Amanda Dhaneshwar, Nicole Fernandez, Benjamin W. Xu, Maria E. Arcila, Ahmet Zehir, Aijazuddin Syed, A. Rose Brannon, Julia E. Rudolph, Eder Paraiso, Paul J. Sabbatini, Ross L. Levine, Ahmet Dogan, Jianjiong Gao, Marc Ladanyi, Alexander Drilon, Michael F. Berger, David B. Solit, Nikolaus Schultz, Debyani Chakravarty; Quantifying the Expanding Landscape of Clinical Actionability for Patients with Cancer. Cancer Discov 1 January 2024; 14 (1): 49–65. https://doi.org/10.1158/2159-8290.CD-23-0467

Sondka Z, Bamford S, Cole CG, Ward SA, Dunham I, Forbes SA. The COSMIC Cancer Gene Census: describing genetic dysfunction across all human cancers. Nat Rev Cancer. 2018 Nov;18(11):696-705. doi: 10.1038/s41568-018-0060-1. PMID: 30293088; PMCID: PMC6450507.

Tarawneh, T.S.; Rodepeter, F.R.; Teply-Szymanski, J.; Ross, P.; Koch, V.; Thölken, C.; Schäfer, J.A.; Gremke, N.; Mack, H.I.D.; Gold, J.; et al. Combined Focused Next-Generation Sequencing Assays to Guide Precision Oncology in Solid Tumors: A Retrospective Analysis from an Institutional Molecular Tumor Board. Cancers 2022, 14, 4430. https://doi.org/10.3390/cancers14184430 

Yihui Xie (2014) knitr: A Comprehensive Tool for Reproducible Research in R. In Victoria Stodden, Friedrich Leisch and Roger D. Peng, editors, Implementing Reproducible Computational Research. Chapman and Hall/CRC. ISBN 978-1466561595

Xie Y (2019). “TinyTeX: A lightweight, cross-platform, and easy-to-maintain LaTeX distribution based on TeX Live.” _TUGboat_, *40*(1), 30-32. <https://tug.org/TUGboat/Contents/contents40-1.html>.
