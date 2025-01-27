<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/nf-core-methylong_logo_dark.png">
    <img alt="nf-core/methylong" src="docs/images/nf-core-methylong_logo_light.png">
  </picture>
</h1>

[![GitHub Actions CI Status](https://github.com/nf-core/methylong/actions/workflows/ci.yml/badge.svg)](https://github.com/nf-core/methylong/actions/workflows/ci.yml)
[![GitHub Actions Linting Status](https://github.com/nf-core/methylong/actions/workflows/linting.yml/badge.svg)](https://github.com/nf-core/methylong/actions/workflows/linting.yml)[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?labelColor=000000&logo=Amazon%20AWS)](https://nf-co.re/methylong/results)[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A524.04.2-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/nf-core/methylong)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23methylong-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/methylong)

## Introduction

**nf-core/methylong** is a bioinformatics pipeline that processes modification basecalled ONT reads or PacBio HiFi reads (modBam) by performing preprocessing steps (including trimming and tag repair), aligning them to the provided genome assembly, and extracting methylation calls into BED/BEDGraph format, ready for direct downstream analysis.

<p align="center">
  <img src="docs/images/methylong_workflow.png">

</p>

### ONT workflow: 

1. trim and repair tags of input modBam 

    - trim and repair workflow:
        1. sort modBam - `samtools sort`
        2. convert modBam to fastq - `samtools fastq`
        3. trim barcode and adapters - `porechop`
        4. convert trimmed modfastq to modBam - `samtools import`
        5. repair MM/ML tags of trimmed modBam - `modkit repair`

2. align to reference (plus sorting and indexing) - `dorado aligner` 
    - include alignment summary - `samtools flagstat`

3. create bedMethyl - `modkit pileup`
4. create bedgraphs (optional)


### PacBio workflow: 

1. align to reference - `pbmm2` (default) or `minimap2` 

    - minimap workflow: 
        1. convert modBam to fastq - `samtools convert`
        2. alignment - `minimap2`
        3. sort and index - `samtools sort`
        4. alignment summary - `samtools flagstat`

    - pbmm2 workflow: 
        1. alignment and sorting - `pbmm2`
        2. index - `samtools index`
        3. alignment summary - `samtools flagstat`

2. create bedMethyl - `pb-CpG-tools` (default) or `modkit pileup` 
    - 2 pile up methods available from `pb-CpG-tools`:
        1. default using `model` 
        2. or `count` (differences describe here: https://github.com/PacificBiosciences/pb-CpG-tools)

3. create bedgraph (optional)



## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

<!-- TODO nf-core: Describe the minimum required steps to execute the pipeline, e.g. how to prepare samplesheets.
     Explain what rows and columns represent. For instance (please edit as appropriate):

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
```

Each row represents a fastq file (single-end) or a pair of fastq files (paired end).

-->

Now, you can run the pipeline using:

<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->

```bash
nextflow run nf-core/methylong \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --outdir <OUTDIR>
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/docs/usage/getting_started/configuration#custom-configuration-files).

For more details and further functionality, please refer to the [usage documentation](https://nf-co.re/methylong/usage) and the [parameter documentation](https://nf-co.re/methylong/parameters).

## Pipeline output

To see the results of an example test run with a full size dataset refer to the [results](https://nf-co.re/methylong/results) tab on the nf-core website pipeline page.
For more details about the output files and reports, please refer to the
[output documentation](https://nf-co.re/methylong/output).

## Credits

nf-core/methylong was originally written by Jin Yan Khoo.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#methylong` channel](https://nfcore.slack.com/channels/methylong) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use nf-core/methylong for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
