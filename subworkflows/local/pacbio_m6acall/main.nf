/*
===========================================
 * Import processes from modules
===========================================
 */

include { FIBERTOOLS_PREDICT               } from '../../../modules/local/fibertools/predict'

/*
===========================================
 * Workflows
===========================================
 */

workflow PACBIO_M6ACALL {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, bam, _ref -> [meta, bam] }
        .set { ch_bam_in }
    
    FIBERTOOLS_PREDICT(ch_bam_in)

    versions = versions.mix(FIBERTOOLS_PREDICT.out.versions.first())

    input
        .join(FIBERTOOLS_PREDICT.out.modbam)
        .map { meta, _bam, ref , modbam -> [meta, modbam, ref] }
        .set { ch_modbam }

    emit:
    ch_modbam
    versions
}
