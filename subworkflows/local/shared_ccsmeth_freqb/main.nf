/*
===========================================
 * Import processes from modules
===========================================
 */

include { CCSMETH_CALLFREQB  } from '../../../modules/local/ccsmeth/callfreqb/main'
include { PIGZ_COMPRESS      } from '../../../modules/nf-core/pigz/compress/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow CCSMETH_CALLFREQB_PIGZ {
    take:
    input

    main:

    versions = Channel.empty()

    // Prepare inputs for call_freqb

    input
        .multiMap { meta, bam, _bai, ref ->
                bam_in: [meta, bam]
                ref_in: [meta, ref]
        }
        .set { ch_ccsmeth_in }

    // ccsmeth call_freqb
    CCSMETH_CALLFREQB( ch_ccsmeth_in.bam_in, ch_ccsmeth_in.ref_in )

    versions = versions.mix(CCSMETH_CALLFREQB.out.versions.first())

    CCSMETH_CALLFREQB.out.bed.set { pileup_out }

    PIGZ_COMPRESS(CCSMETH_CALLFREQB.out.bed)
    versions = versions.mix(PIGZ_COMPRESS.out.versions.first())

    emit:
    pileup_out
    versions
}
