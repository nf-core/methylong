# nf-core/methylong: Output

## Introduction

This document describes the output produced by the pipeline.

Sample-level outputs are under `<platform>/<sample>/`, where `<platform>` is `ont` or `pacbio`. Population-scale comparisons have a separate directory under `<platform>/dmr_population_scale/`. The `multiqc/` and `pipeline_info/` directories are at the top level of the results directory.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [FastQC](#fastqc) - Raw read QC
- [Modcalling](#modcalling) - basecall and modcall
- [Preprocessing reads](#preprocessing-reads) - Adapters and Barcodes removal
- [Alignment](#alignment) - alignment to reference genome
- [Methylation calling](#pileup) - pile up of methylation calls
- [BedGraphs](#bedgraphs) - methylation tracks derived from pileups
- [SNV calling](#snv-calling) - germline small variant calls
- [Phasing](#phasing) - phase genomic variant
- [DMR analysis](#dmr-analysis) - DMR results
- [Fiberseq](#fiberseq) - fiberseq results
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

Modification calling (`modcalling`) includes basecall for ONT pod5 reads and modcall.

<details markdown="1">
<summary>Output files</summary>

- `basecall/`
  - `*_calls.bam`: reads after basecalling.
- `modcall/`
  - `*_modbam.bam`: reads after modcalling with MM/ML tags, if pacbio_modcaller is jasmine.
  - `*_ccsmeth_modbam.bam`: reads after modcalling with MM/ML tags, if pacbio_modcaller is ccsmeth.

</details>

### Preprocessing reads

Preprocessing of reads are only available for ONT reads. Reads are trimmed, then MM/ML tags are repaired.

<details markdown="1">
<summary>Output files</summary>

- `trim/`
  - `*_fastq.gz`: reads after trimming.
  - `*.log`: trimming log
- `repair/`
  - `*_repaired.bam`: reads after repairing MM/ML tags.
  - `*_repaired.log`: repair log

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

The pipeline uses Modkit for ONT pileup. For PacBio, `--pileup_method` selects pb-CpG-tools (default) or Modkit. The PacBio `ccsmeth` branch also writes its own `call_freqb` pileup.

<details markdown="1">
<summary>Output files</summary>

#### modkit output:

- `pileup/`
  - `*.bed.gz`: pileup of methylation calls in compressed bed format
  - `*.bed.gz.tbi` indexes the compressed Modkit pileup.
  - `*_pileup.log`: pileup log

#### pb-CpG-tools output:

- `pileup/`
  - `*.bed.gz`: pileup of methylation calls in compressed bed format
  - `*_pileup.log`: pileup log
  - `*.bw`: bigwig format

#### ccsmeth output

- `pileup/` contains the compressed `*_ccsmeth_freqb*.bed.gz` pileup and its `.tbi` index when the ccsmeth branch runs.

</details>

### Bedgraphs

Use `--bedgraph` to request compressed bedGraph tracks.

<details markdown="1">
<summary>Output files</summary>

- `bedgraphs/*.bedgraph.gz` contains tracks derived from the Modkit or pb-CpG-tools pileup.
- `pacbio/<sample>/bedgraphs/ccsmeth/*.bedgraph.gz` is the output path for the additional ccsmeth conversion when `--pacbio_modcaller ccsmeth` is selected.

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
  - `*_phased.vcf.gz` and `*_phased.vcf.gz.tbi` contain the phased variants and their index.
  - `*_haplotagged.bam` and `*_haplotagged.bam.bai` contain the haplotagged alignments and their index.
  - `*_haplotagged.readlist` lists haplotype assignments for reads.

</details>

### DMR analysis

DMR output paths depend on the analysis level and caller.

<details markdown="1">
<summary>Output files</summary>

#### Haplotype-level DMRs

- `dmr_haplotype_level/phased_pileup/` contains compressed Modkit pileups, including `*_hp1.bed.gz`, `*_hp2.bed.gz` and `*_combined.bed.gz` for 5mC.
- `dmr_haplotype_level/dmr_dss/` contains `*_DSS_DMLtest.txt`, `*_DSS_callDML.txt`, `*_DSS_callDMR.txt` and `*_DSS.log` when DSS produces results.
- `dmr_haplotype_level/dmr_modkit/` contains `*_modkit_dmr_haplotype_level.bed.gz` and the Modkit log when Modkit produces results.

#### Population-scale DMRs

- `<platform>/dmr_population_scale/group_pileup/` contains the compressed per-sample pileups for the selected groups.
- `<platform>/dmr_population_scale/<group_a>_<group_b>/` contains `dss_population_scale_DMLtest.txt`, `dss_population_scale_callDML.txt`, `dss_population_scale_callDMR.txt` and `dss_population_scale.log` for DSS, or `*_modkit_dmr_population_scale.bed.gz` and the Modkit log for Modkit.

</details>

### Fiberseq

<details markdown="1">
<summary>Output files</summary>

- `fiberseq/`
  - `*_m6a_predicted.bam`: PacBio reads after m6a calling.
  - `*_m6acall.bam`: ONT reads after m6a calling.
  - `*_m6a.bed`: pileup of m6a calls.

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
  - Nextflow reports use a run-specific suffix, as in `execution_report_*.html`, `execution_timeline_*.html`, `execution_trace_*.txt` and `pipeline_dag_*.html`.
  - `nf_core_methylong_software_versions.yml` records the software versions collected during the run.
  - `pipeline_report.html` and `pipeline_report.txt` are generated when `--email` or `--email_on_fail` is set.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
