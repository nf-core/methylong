# nf-core/methylong: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v2.1.0 - [Unreleased]

### `Added`

- Add bedGraph output for PacBio `ccsmeth` pileups when `--bedgraph` is enabled.

### `Fixed`

- Fix a caching issue in the `WHATSHAP_HAPLOTAG` workflow.
- Fix haplotype-level DMR input matching for Modkit 0.6.x phased pileups in the DSS and Modkit workflows.
- Fix bedGraph conversion for compressed Modkit and ccsmeth pileups.
- Honor the DSS `--smoothing_flag` setting in `DMLtest()`. Smoothing is now applied by default.
- Check that the input data (`path`) and reference genome (`ref`) in the samplesheet exist when the workflow starts.

### `Updated`

- Update DSS defaults. The merge distance (`dis_merge`) increases from 50 to 1500 bp, the minimum DMR length (`minlen`) from 50 to 100 bp, and the minimum CpG count (`minCG`) from 3 to 15. `equal_disp` changes from `TRUE` to `FALSE` and `delta_cutoff` from 0.05 to 0.
- Use `modkit dmr pair` for haplotype-level and population-scale DMR calling when `--all_contexts` is enabled.
- Keep CpG counts separate by strand in Modkit pileups for haplotype-level and population-scale DMR analysis by omitting `--combine-strands`.
- Pass `--modified-bases 5mC` to the Modkit pileups used for haplotype-level and population-scale DMR analyses to limit the data processed by DSS.
- Write `whatshap phase` output as `.vcf.gz` and `modkit dmr pair` and `modkit pileup` outputs as `.bed.gz`.
- Rename the software versions report in `pipeline_info/` from `nf_core_methylong_software_mqc_versions.yml` to `nf_core_methylong_software_versions.yml`.
- Update the workflow diagram and Zenodo link, and expand the README with installation, input format, and testing instructions.
- Harden GitHub Actions workflows for pull request comments and automated lint fixes.

### `Dependencies`

| Dependency      | Old version | New version |
| --------------- | ----------- | ----------- |
| `clair3`        | 1.2.0       | 2.0.0       |
| `dorado`        | 1.1.1       | 2.0.0       |
| `fibertools-rs` | 0.7.1       | 0.8.2       |
| `gawk`          | 5.3.0       | 5.3.1       |
| `modkit`        | 0.5.0       | 0.6.1       |
| `multiqc`       | 1.32        | 1.33        |
| `nf-schema`     | 2.5.1       | 2.7.0       |
| `pbjasmine`     | 2.4.0       | 26.1.3      |
| `samtools`      | 1.22.1      | 1.23.1      |

### Requirements

- Nextflow `>=25.10.4` (previously `>=25.04.0`).

### Contributors

- @YiJin-Xiong for DMR, `ccsmeth`, and dependency updates ([#85](https://github.com/nf-core/methylong/pull/85)).
- @jkh00 for workflow fixes and version reporting ([#78](https://github.com/nf-core/methylong/pull/78)).
- @PengNi for DSS fixes, input validation, and docs ([#90](https://github.com/nf-core/methylong/pull/90), [#93](https://github.com/nf-core/methylong/pull/93)).
- @nschan for reviewing the DSS changes ([#85](https://github.com/nf-core/methylong/pull/85)).
- @sateeshperi for test maintenance ([#78](https://github.com/nf-core/methylong/pull/78)).
- @mashehu for merging CI security patches ([#89](https://github.com/nf-core/methylong/pull/89), [#94](https://github.com/nf-core/methylong/pull/94)).

## v2.0.0 - [2025-08-25]

### `Updated`

- Update the input samplesheet structure

### `Added`

| New Content                        | Description                              |
| ---------------------------------- | ---------------------------------------- |
| `dorado basecaller` module         | basecalling for pod5 reads               |
| `jasmine` and `ccsmeth` module     | modcalling for raw PacBio HiFi bam reads |
| `fibertools` modules               | m6A modification calling                 |
| `DMR_haplotype_level` subworkflow  | haplotype-level DMR analysis             |
| `DMR_population_scale` subworkflow | population-scale DMR analysis            |

### `Dependencies`

| Dependency   | Old version | New version |
| ------------ | ----------- | ----------- |
| `dorado`     | 0.9.5       | 1.1.1       |
| `jasmine`    |             | 2.4.0       |
| `ccsmeth`    |             | 0.5.0       |
| `DSS`        |             | 2.54.0      |
| `fibertools` |             | 0.6.4       |
| `modkit`     | 0.4.4       | 0.5.0       |
| `samtools`   | 1.21        | 1.22.1      |

### Requirements

- Nextflow `>=25.04.0`

### Contributors

- @YiJin-Xiong for implementing `fiberseq`, `dmr calling` subworkflows.
- @jkh00 for code review, suggestions and template updates.

## v1.1.0 - [2025-05-28]

### `Added`

| New Content       | Description                    |
| ----------------- | ------------------------------ |
| `clair3` module   | germline small variant calling |
| `whatshap` module | genomic variant phasing        |

### `Fixed`

- The `methylong` workflow now filters out null values from process outputs.

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `clair3`   | 1.0.10      | 1.1.1       |
| `whatshap` |             | 2.6         |
| `gawk`     |             | 5.3.0       |

### New Contributors

- New subworkflows were created by @YiJin-Xiong

## v1.0.0 'Niveous Tiger' - [2025-05-08]

Initial release of nf-core/methylong, created with the [nf-core](https://nf-co.re/) template.

### `Added`

### `Fixed`

### `Dependencies`

### `Deprecated`

### Credits

- special thanks to @fellen31 for valuable code review and feedback on the pipeline structure.
