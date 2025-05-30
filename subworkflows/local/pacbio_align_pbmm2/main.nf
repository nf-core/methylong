/*
===========================================
 * Import processes from modules
===========================================
 */



include { SAMTOOLS_FLAGSTAT } from '../../../modules/nf-core/samtools/flagstat/main'
include { SAMTOOLS_INDEX    } from '../../../modules/nf-core/samtools/index/main'
include { PBMM2_ALIGN       } from '../../../modules/nf-core/pbmm2/align/main'

/*
===========================================
 * Workflows
===========================================
 */


// for PacBio

workflow PACBIO_ALIGN_PBMM2 {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .multiMap { meta, modbam, ref ->
        reads_in: [meta, modbam]
        ref_in: [meta, ref]
        }
        .set{ ch_pbmm_in }


    PBMM2_ALIGN(ch_pbmm_in.reads_in, ch_pbmm_in.ref_in)

    versions = versions.mix(PBMM2_ALIGN.out.versions.first())

    SAMTOOLS_INDEX(PBMM2_ALIGN.out.bam)

    versions = versions.mix(SAMTOOLS_INDEX.out.versions.first())

    // Prepare input for samtool flagstat and modkit pileup
    PBMM2_ALIGN.out.bam
        .join(SAMTOOLS_INDEX.out.bai)
        .set { ch_flagstat_in }

    PBMM2_ALIGN.out.bam
        .join(SAMTOOLS_INDEX.out.bai)
        .join(ch_pbmm_in.ref_in)
        .map { meta, bam, bai, ref -> [meta, bam, bai, ref] }
        .set { ch_pile_in }

    // check alignment stat
    SAMTOOLS_FLAGSTAT(ch_flagstat_in)

    versions = versions.mix(SAMTOOLS_FLAGSTAT.out.versions.first())
    SAMTOOLS_FLAGSTAT.out.flagstat.set { flagstat_out }

    emit:
    ch_pile_in
    versions
    flagstat_out
}
