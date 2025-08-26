# nf-core/methylong: Output

## Introduction

This document describes the output produced by the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [FastQC](#fastqc) - Raw read QC
- [Modcalling](#modcalling) - basecall and modcall
- [Preprocessing reads](#preprocessing-reads) - Adapters and Barcodes removal
- [Alignment](#alignment) - alignment to reference genome
- [Methylation calling](#pileup) - pile up of methylation calls
- [Bed to bedgraph conversion](#bedgraph) - convert bed to bedgraph
- [SNV calling](#snv-calling) - germline small variant calls
- [Phasing](#phasing) - phase genomic variant
- [DMR analysis](#dmr-analysis) - DMR results
- [MultiQC](#multiqc) - Aggregate report describing triming and alignment results and QC from the whole pipeline
- [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

### FastQC

<details markdown="1">
<summary>Output files</summary>

- `fastqc/`
  - `*_fastqc.html`: FastQC report containing quality metrics.
  - `*_fastqc.zip`: Zip archive containing the FastQC report, tab-delimited data file and plot images.

</details>

[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) gives general quality metrics about your sequenced reads. It provides information about the quality score distribution across your reads, per base sequence content (%A/T/G/C), adapter contamination and overrepresented sequences. For further reading and documentation see the [FastQC help pages](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/).

### Modcalling

Modcalling includes basecall for ONT pod5 reads and modcall for PacBio raw bam reads.

<details markdown="1">
<summary>Output files</summary>


- `basecall/`
  - `*_calls.bam`: reads after basecalling.
- `modcall/`
  - `*_modbam.bam`: reads after modcalling with MM/ML tags.
  - `*_m6a_predicted.bam`: reads after m6a calling.
  - `*_m6a.bed`: pileup of m6a calls.

</details>

### Preprocessing reads

Preprocessing of reads are only available for ONT reads. Reads are trimmed, then MM/ML tags are repaired.

<details markdown="1">
<summary>Output files</summary>

- `trim/`
  - `*_fastq.gz`: reads after trimming.
  - `*.log`: trimming log
  
- `repair/`
  - `*_repaired_.bam`: reads after repairing MM/ML tags.
  - `*.log`: repair log

</details>

### Alignment

<details markdown="1">
<summary>Output files</summary>

- `alignment/`
  - `*.bam`: aligned modBAM.
  - `*.bam.bai`: alignment index
  - `*.flagstat`: alignment summary

</details>

### Pileup

Methylation pile up for PacBio data can be preformed by either modkit or pb-CpG-tools.

<details markdown="1">
<summary>Output files</summary>

#### modkit output:

- `pileup/`
  - `*.bed.gz`: pileup of methylation calls in compressed bed format
  - `*_pileup.log`: pileup log

#### pb-CpG-tools output:

- `pileup/`
  - `*.bed.gz`: pileup of methylation calls in compressed bed format
  - `*_pileup.log`: pileup log
  - `*.bw`: bigwig format

</details>

### Bedgraphs

<details markdown="1">
<summary>Output files</summary>

- `bedgraphs/`
  - `*.bedgraph`: context specific bedgraph output

</details>

### SNV calling

<details markdown="1">
<summary>Output files</summary>

- `snvcall/`
  - `*.vcf.gz`: snv calls
  - `*.vcf.gz.tbi`: snv-call index
  - `*_SNV_PASS.vcf`: pass-filtered snv calls

</details>

### Phasing

<details markdown="1">
<summary>Output files</summary>

- `phase/`
  - `*phased.vcf`: phased vcf
  - `*.bam`: haplotagged bam
  - `*.readlist`: haplotagged readlist

</details>

### DMR analysis

DMR analysis includes haplotype level and population scale, and can be preformed by either DSS or modkit.

<details markdown="1">
<summary>Output files</summary>

#### DSS output:


- `dmr_haplotype_level/dss/`
  - `*_preprocessed_<1|2|etc>.bed`: partitioned reads based on HP tag
  - `*_DSS_DMLtest.txt`: DML test results
  - `*_DSS_callDML.txt`: DML
  - `*_DSS_callDMR.txt`: DMR
  - `*_DSS.log`: DSS log

#### modkit dmr output:

- `dmr_haplotype_level/modkit/`
  - `*_<1|2|etc>.bed`: partitioned reads based on HP tag
  - `*_modkit_dmr_haplotype_level.bed`: differential methylation output

- `dmr_population_scale/`
  - `*_DSS_DMLtest.txt`: DML test results
  - `*_DSS_callDML.txt`: DML
  - `*_DSS_callDMR.txt`: DMR
  - `*_DSS.log`: DSS log

</details>

### MultiQC

<details markdown="1">
<summary>Output files</summary>

- `multiqc/`
  - `multiqc_report.html`: a standalone HTML file that can be viewed in your web browser.
  - `multiqc_data/`: directory containing parsed statistics from the different tools used in the pipeline.
  - `multiqc_plots/`: directory containing static images from the report in various formats.

</details>

[MultiQC](http://multiqc.info) is a visualization tool that generates a single HTML report summarising all samples in your project. Most of the pipeline QC results are visualised in the report and further statistics are available in the report data directory.

Results generated by MultiQC collate pipeline QC from supported tools e.g. FastQC. The pipeline has special steps which also allow the software versions to be reported in the MultiQC output for future traceability. For more information about how to use MultiQC reports, see <http://multiqc.info>.

### Pipeline information

<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.
  - Parameters used by the pipeline run: `params.json`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
