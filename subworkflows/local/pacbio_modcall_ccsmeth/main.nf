/*
===========================================
 * Import processes from modules
===========================================
 */

include { CCSMETH_CALL_MODS            } from '../../../modules/local/ccsmeth/call_mods/main'

/*
===========================================
 * Workflows
===========================================
 */

workflow PACBIO_MODCALL_CCSMETH {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, bam, _ref -> [meta, bam] }
        .set { ch_bam_in }
    
    CCSMETH_CALL_MODS(ch_bam_in)

    versions = versions.mix(CCSMETH_CALL_MODS.out.versions.first())

    input
        .join(CCSMETH_CALL_MODS.out.modbam)
        .map { meta, _bam, ref, modbam -> [meta, modbam, ref] }
        .set { ch_pile_in }

    emit:
    ch_pile_in
    versions
}
