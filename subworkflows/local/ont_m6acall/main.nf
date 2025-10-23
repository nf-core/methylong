/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_CALL_MODS                 } from '../../../modules/local/modkit/call_mods'
include { FIBERTOOLS_ADD_NUCLEOSOMES       } from '../../../modules/local/fibertools/add_nucleosomes'


/*
===========================================
 * Workflows
===========================================
 */

workflow ONT_M6ACALL {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, bam, _ref -> [meta, bam] }
        .set { ch_bam_in }

    MODKIT_CALL_MODS(ch_bam_in)

    versions = versions.mix(MODKIT_CALL_MODS.out.versions.first())

    FIBERTOOLS_ADD_NUCLEOSOMES(MODKIT_CALL_MODS.out.call_mod_bam)

    versions = versions.mix(FIBERTOOLS_ADD_NUCLEOSOMES.out.versions.first())

    input
        .join(FIBERTOOLS_ADD_NUCLEOSOMES.out.modbam)
        .map { meta, _bam, ref , modbam -> [meta, modbam, ref] }
        .set { ch_modbam }

    emit:
    ch_modbam
    versions
}
