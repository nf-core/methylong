/*
===========================================
 * Import processes from modules
===========================================
 */

include { FIBERTOOLS_EXTRACT               } from '../../../modules/local/fibertools/extract'

/*
===========================================
 * Workflows
===========================================
 */

workflow SHARED_FIBERTOOLS_EXTRACT {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, bam, _bai, _ref -> [meta, bam] }
        .set { ch_bam_in }

    FIBERTOOLS_EXTRACT(ch_bam_in)

    versions = versions.mix(FIBERTOOLS_EXTRACT.out.versions.first())

    emit:
    versions
}
