/*
===========================================
 * Import processes from modules
===========================================
 */

include { DORADO_BASECALLER                       } from '../../../modules/local/dorado/basecaller/main'

/*
===========================================
 * Workflows
===========================================
 */

workflow ONT_BASECALL {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, pod5, _ref -> [meta, pod5] }
        .set { ch_pod5 }

    DORADO_BASECALLER(ch_pod5)

    versions = versions.mix(DORADO_BASECALLER.out.versions.first())

    input
        .join(DORADO_BASECALLER.out.bam)
        .map { meta, _pod5, ref, modbam -> [meta, modbam, ref] }
        .set { ch_pile_in }

    emit:
    ch_pile_in
    versions
}
