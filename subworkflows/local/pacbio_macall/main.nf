/*
===========================================
 * Import processes from modules
===========================================
 */

include { FIBERTOOLS_PREDICT               } from '../../../modules/local/fibertools/predict'
include { FIBERTOOLS_EXTRACT               } from '../../../modules/local/fibertools/extract'


/*
===========================================
 * Workflows
===========================================
 */

workflow PACBIO_MACALL {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, bam, _ref -> [meta, bam] }
        .set { ch_bam_in }
    
    FIBERTOOLS_PREDICT(ch_bam_in)

    versions = versions.mix(FIBERTOOLS_PREDICT.out.versions.first())

    FIBERTOOLS_EXTRACT(FIBERTOOLS_PREDICT.out.modbam)

    versions = versions.mix(FIBERTOOLS_EXTRACT.out.versions.first())

    emit:
    versions
}
