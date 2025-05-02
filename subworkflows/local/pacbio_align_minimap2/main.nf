/*
===========================================
 * Import processes from modules
===========================================
 */


include { SAMTOOLS_FLAGSTAT                       } from '../../../modules/nf-core/samtools/flagstat/main'
include { MINIMAP2_ALIGN as PACBIO_MINIMAP2_ALIGN } from '../../../modules/nf-core/minimap2/align/main'

/*
===========================================
 * Workflows
===========================================
 */


// for PacBio

workflow PACBIO_ALIGN_MINI {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .multiMap { meta, modbam, ref ->
            mini_in: [meta, modbam]
            ref_in: [meta, ref]
        }
        .set { ch_mini_in }

    PACBIO_MINIMAP2_ALIGN(ch_mini_in.mini_in, ch_mini_in.ref_in, "bam_format", "bai", [], [])

    versions = versions.mix(PACBIO_MINIMAP2_ALIGN.out.versions.first())


    // Prepare input for samtool flagstat and modkit pileup
    PACBIO_MINIMAP2_ALIGN.out.bam
        .join(PACBIO_MINIMAP2_ALIGN.out.index)
        .set { ch_flagstat_in }

    PACBIO_MINIMAP2_ALIGN.out.bam
        .join(PACBIO_MINIMAP2_ALIGN.out.index)
        .join(ch_mini_in.ref_in)
        .map { meta, bam, bai, ref -> [meta, bam, bai, ref] }
        .set { ch_pile_in }


    SAMTOOLS_FLAGSTAT(ch_flagstat_in)

    versions = versions.mix(SAMTOOLS_FLAGSTAT.out.versions.first())
    SAMTOOLS_FLAGSTAT.out.flagstat.set { flagstat_out }

    emit:
    ch_pile_in
    versions
    flagstat_out
}
