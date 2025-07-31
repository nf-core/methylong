/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_CALL_MODS                 } from '../../../modules/local/modkit/call_mods'
include { FIBERTOOLS_ADD_NUCLEOSOMES       } from '../../../modules/local/fibertools/add_nucleosomes'
include { FIBERTOOLS_EXTRACT               } from '../../../modules/local/fibertools/extract'


/*
===========================================
 * Workflows
===========================================
 */

workflow ONT_MACALL {
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

    FIBERTOOLS_EXTRACT(FIBERTOOLS_ADD_NUCLEOSOMES.out.modbam)

    versions = versions.mix(FIBERTOOLS_EXTRACT.out.versions.first())

    emit:
    versions
}
