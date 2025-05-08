/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_PILEUP  } from '../../../modules/nf-core/modkit/pileup/main'
include { SAMTOOLS_FAIDX } from '../../../modules/nf-core/samtools/faidx/main'
include { PIGZ_COMPRESS  } from '../../../modules/nf-core/pigz/compress/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow INDEX_MODKIT_PILEUP {
    take:
    input

    main:

    versions = Channel.empty()

    // Prepare inputs for pileup

    input
        .map { meta, _bam, _bai, ref -> [meta, ref] }
        .set { ch_ref_in }

    // Index ref
    SAMTOOLS_FAIDX(ch_ref_in, [[], []], [])

    versions = versions.mix(SAMTOOLS_FAIDX.out.versions.first())

    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .map { meta, bam, bai, _ref, _fai -> [meta, bam, bai] }
        .set { ch_bam_in }

    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .map { meta, _bam, _bai, ref, fai -> [meta, ref, fai] }
        .set { ch_index_ref }


    // Modkit pileup
    MODKIT_PILEUP(ch_bam_in, ch_index_ref, [[], []])

    versions = versions.mix(MODKIT_PILEUP.out.versions.first())


    MODKIT_PILEUP.out.bed.set { pileup_out }

    PIGZ_COMPRESS(MODKIT_PILEUP.out.bed)
    versions = versions.mix(PIGZ_COMPRESS.out.versions.first())

    emit:
    pileup_out
    versions
}
