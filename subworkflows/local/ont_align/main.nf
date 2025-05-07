/*
===========================================
 * Import processes from modules
===========================================
 */


include { DORADO_ALIGNER                       } from '../../../modules/local/dorado/aligner/main'
include { SAMTOOLS_RESET                       } from '../../../modules/local/samtools/reset/main'
include { MINIMAP2_ALIGN as ONT_MINIMAP2_ALIGN } from '../../../modules/nf-core/minimap2/align/main'
include { SAMTOOLS_FLAGSTAT                    } from '../../../modules/nf-core/samtools/flagstat/main'

/*
===========================================
 * Workflows
===========================================
 */

workflow ONT_ALIGN {
    take:
    align_in

    main:

    versions = Channel.empty()

    align_in
        .multiMap { meta, modbam, ref ->
            bam_in: [meta, modbam]
            ref_in: [meta, ref]
        }
        .set { ch_mini_in }

    if (params.ont_aligner == "minimap2") {

        ONT_MINIMAP2_ALIGN(ch_mini_in.bam_in, ch_mini_in.ref_in, "bam_format", "bai", [], [])
        versions = versions.mix(ONT_MINIMAP2_ALIGN.out.versions.first())

        ONT_MINIMAP2_ALIGN.out.bam
            .join(ONT_MINIMAP2_ALIGN.out.index)
            .set { ch_flagstat_in }

        ONT_MINIMAP2_ALIGN.out.bam
            .join(ONT_MINIMAP2_ALIGN.out.index)
            .join(ch_mini_in.ref_in)
            .map { meta, bam, bai, ref -> [meta, bam, bai, ref] }
            .set { ch_pile_in }
    }
    else {
            if (params.reset) {

                SAMTOOLS_RESET(ch_mini_in.bam_in)
                SAMTOOLS_RESET.out.unaligned_bam
                                    . set { ch_reset_bam }

                versions = versions.mix(SAMTOOLS_RESET.out.versions.first())

                DORADO_ALIGNER(ch_reset_bam, ch_mini_in.ref_in)

            } else {

                DORADO_ALIGNER(ch_mini_in.bam_in, ch_mini_in.ref_in)
            }

        versions = versions.mix(DORADO_ALIGNER.out.versions.first())
        // Preapre inputs for downstream
        DORADO_ALIGNER.out.bam
            .join(DORADO_ALIGNER.out.bai)
            .map { meta, bam, bai -> [meta, bam, bai] }
            .set { ch_flagstat_in }

        DORADO_ALIGNER.out.bam
            .join(DORADO_ALIGNER.out.bai)
            .join(ch_mini_in.ref_in)
            .map { meta, alignedbam, index, ref -> [meta, alignedbam, index, ref] }
            .set { ch_pile_in }
    }

    // check alignment stat
    SAMTOOLS_FLAGSTAT(ch_flagstat_in)

    versions = versions.mix(SAMTOOLS_FLAGSTAT.out.versions.first())
    SAMTOOLS_FLAGSTAT.out.flagstat.set { flagstat_out }

    emit:
    ch_pile_in
    versions
    flagstat_out
}
