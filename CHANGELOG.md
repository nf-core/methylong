# nf-core/methylong: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v2.0.0 - [2025-08-25]

### `Added`

- Add `DMR_haplotype_level` subworkflow for DMR analysis in haplotype level
- Add `DMR_population_scale` subworkflow for DMR analysis in population scale
- Add `dorado basecaller` module to basecall pod5 reads
- Add `jasmine` and `ccsmeth` module to modcall raw PacBio HiFi bam reads
- Add `fibertools` modules for m6A call
- Change the input samplesheet structure

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

- Add `clair3` module to call germline small variant
- Add `whatshap` module to phase genomic variant

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
