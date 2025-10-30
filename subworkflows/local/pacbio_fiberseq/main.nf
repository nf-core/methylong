/*
===========================================
 * Import processes from modules
===========================================
 */

include { FIBERTOOLSRS_PREDICTM6A          } from '../../../modules/nf-core/fibertoolsrs/predictm6a'
include { FIBERTOOLSRS_EXTRACT             } from '../../../modules/nf-core/fibertoolsrs/extract'

/*
===========================================
 * Workflows
===========================================
 */

workflow PACBIO_FIBERSEQ {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, bam, _bai, _ref -> [meta, bam] }
        .set { ch_bam_in }

    FIBERTOOLSRS_PREDICTM6A(ch_bam_in)

    versions = versions.mix(FIBERTOOLSRS_PREDICTM6A.out.versions.first())

    FIBERTOOLSRS_EXTRACT(FIBERTOOLSRS_PREDICTM6A.out.bam,'m6a')

    versions = versions.mix(FIBERTOOLSRS_EXTRACT.out.versions.first())

    emit:
    versions
}
