# nf-core/methylong: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v2.0.0 - [2025-08-25]

### `Updated`
- Update the input samplesheet structure

### `Added`

| New Content                        | Descriptio                               |
| ---------------------------------- | ---------------------------------------- |
| `dorado basecaller` module         | basecalling for pod5 reads               |
| `jasmine` and `ccsmeth` module     | modcalling for raw PacBio HiFi bam reads |
| `fibertools` modules               | m6A modification calling                 |
| `DMR_haplotype_level` subworkflow  | haplotype-level DMR analysis             |
| `DMR_population_scale` subworkflow | population-scale DMR analysis            |

### `Fixed`

### `Dependencies`

| Dependency   | Old version | New version |
| ------------ | ----------- | ----------- |
| `dorado`     | 0.9.5       | 1.1.1       |
| `jasmine`    |             | 2.4.0       |
| `ccsmeth`    |             | 0.5.0       |
| `DSS`        |             | 2.54.0      |
| `fibertools` |             | 0.6.4       |

### `Deprecated`

## v1.1.0 - [2025-05-28]

### `Added`

| New Content                        | Descriptio                               |
| ---------------------------------- | ---------------------------------------- |
| `clair3` module                    | germline small variant calling           |
| `whatshap` module                  | genomic variant phasing                  |

### `Fixed`

- The `methylong` workflow now filters out null values from process outputs.

### `Dependencies`

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `clair3`   | 1.0.10      | 1.1.1       |
| `whatshap` |             | 2.6         |
| `gawk`     |             | 5.3.0       |

### `Deprecated`

## v1.0.0 'Niveous Tiger' - [2025-05-08]

Initial release of nf-core/methylong, created with the [nf-core](https://nf-co.re/) template.

### `Added`

### `Fixed`

### `Dependencies`

### `Deprecated`
