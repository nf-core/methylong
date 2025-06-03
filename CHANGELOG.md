# nf-core/methylong: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

### `Deprecated`

## v1.0.0 'Niveous Tiger' - [2025-05-08]

Initial release of nf-core/methylong, created with the [nf-core](https://nf-co.re/) template.

### `Added`

### `Fixed`

### `Dependencies`

### `Deprecated`
