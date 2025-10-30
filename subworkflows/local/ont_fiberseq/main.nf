/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_CALLMODS                  } from '../../../modules/nf-core/modkit/callmods'
include { FIBERTOOLSRS_ADDNUCLEOSOMES      } from '../../../modules/nf-core/fibertoolsrs/addnucleosomes'
include { FIBERTOOLSRS_EXTRACT             } from '../../../modules/nf-core/fibertoolsrs/extract'

/*
===========================================
 * Workflows
===========================================
 */

workflow ONT_FIBERSEQ {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, bam, _bai, _ref -> [meta, bam] }
        .set { ch_bam_in }

    MODKIT_CALLMODS(ch_bam_in)

    versions = versions.mix(MODKIT_CALLMODS.out.versions.first())

    FIBERTOOLSRS_ADDNUCLEOSOMES(MODKIT_CALLMODS.out.bam)

    versions = versions.mix(FIBERTOOLSRS_ADDNUCLEOSOMES.out.versions.first())

    FIBERTOOLSRS_EXTRACT(FIBERTOOLSRS_ADDNUCLEOSOMES.out.bam, 'm6a')

    versions = versions.mix(FIBERTOOLSRS_EXTRACT.out.versions.first())

    emit:
    versions
}
