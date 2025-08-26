/*
===========================================
 * Import processes from modules
===========================================
 */

include { JASMINE                       } from '../../../modules/local/jasmine/main'

/*
===========================================
 * Workflows
===========================================
 */

workflow PACBIO_MODCALL_JASMINE {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, bam, _ref -> [meta, bam] }
        .set { ch_bam_in }

    JASMINE(ch_bam_in)

    versions = versions.mix(JASMINE.out.versions.first())

    input
        .join(JASMINE.out.modbam)
        .map { meta, _bam, ref, modbam -> [meta, modbam, ref] }
        .set { ch_pile_in }

    emit:
    ch_pile_in
    versions
}
