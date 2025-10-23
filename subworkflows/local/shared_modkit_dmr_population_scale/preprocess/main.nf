/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_PILEUP as MODKIT_PILEUP_POPULATION_SCALE } from '../../../../modules/nf-core/modkit/pileup/main'
include { SAMTOOLS_FAIDX                                  } from '../../../../modules/nf-core/samtools/faidx/main'
include { TABIX_BGZIPTABIX                                } from '../../../../modules/nf-core/tabix/bgziptabix/main'

/*
===========================================
 * Workflows
===========================================
 */

workflow MODKIT_DMR_POPULATION_SCALE_PREPROCESS {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, _bam, _bai, ref -> [meta, ref] }
        .set { ch_ref }

    // Index ref
    SAMTOOLS_FAIDX(ch_ref, [[], []], [])

    versions = versions.mix(SAMTOOLS_FAIDX.out.versions.first())

    // Prepare inputs for modkit pileup
    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .map { meta, bam, bai, _ref, _fai -> [meta, bam, bai] }
        .set { ch_bam_in }

    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .map { meta, _bam, _bai, ref, fai -> [meta, ref, fai] }
        .set { ch_ref_in }

    // modkit pileup
    MODKIT_PILEUP_POPULATION_SCALE(ch_bam_in, ch_ref_in, [[], []])

    versions = versions.mix(MODKIT_PILEUP_POPULATION_SCALE.out.versions.first())

    // bgzip and tabix
    TABIX_BGZIPTABIX(MODKIT_PILEUP_POPULATION_SCALE.out.bed)

    versions = versions.mix(TABIX_BGZIPTABIX.out.versions.first())

    TABIX_BGZIPTABIX.out.gz_tbi.set { bed_gz }

    emit:
    ch_ref_in
    bed_gz
    versions
}
