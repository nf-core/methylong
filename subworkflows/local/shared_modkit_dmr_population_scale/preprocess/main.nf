/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_PILEUP as MODKIT_PILEUP_POPULATION_SCALE } from '../../../../modules/nf-core/modkit/pileup/main'
include { SAMTOOLS_FAIDX                                  } from '../../../../modules/nf-core/samtools/faidx/main'
include { TABIX_TABIX                                     } from '../../../../modules/nf-core/tabix/tabix/main'

/*
===========================================
 * Workflows
===========================================
 */

workflow MODKIT_DMR_POPULATION_SCALE_PREPROCESS {
    take:
    input

    main:

    input
        .map { meta, _bam, _bai, ref -> [meta, ref, []] }
        .set { ch_ref }

    // Index ref
    SAMTOOLS_FAIDX(ch_ref, [])

    // Prepare inputs for modkit pileup
    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .multiMap { meta, bam, bai, ref, fai ->
                bam: [meta, bam, bai]
                ref: [meta, ref, fai]
        }
        .set { ch_pileup_in }

    // modkit pileup
    MODKIT_PILEUP_POPULATION_SCALE(ch_pileup_in.bam, ch_pileup_in.ref, [[], []])

    ch_pileup_in.ref.set { ch_ref_in }

    // tabix
    TABIX_TABIX(MODKIT_PILEUP_POPULATION_SCALE.out.bedgz)

    MODKIT_PILEUP_POPULATION_SCALE.out.bedgz
        .join(TABIX_TABIX.out.index)
        .map { meta, bedgz, index -> [meta, bedgz, index] }
        .set { bed_gz }

    emit:
    ch_ref_in
    bed_gz
}
