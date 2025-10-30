/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_DMR_POPULATION_SCALE_PREPROCESS as PREPROCESS_A } from './preprocess/main'
include { MODKIT_DMR_POPULATION_SCALE_PREPROCESS as PREPROCESS_B } from './preprocess/main'
include { MODKIT_DMRPAIR as DMR_POPULATION_SCALE                 } from '../../../modules/local/modkit/dmrpair/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow MODKIT_DMR_POPULATION_SCALE {
    take:
    input

    main:

    versions = Channel.empty()

    // Split input into two groups: dmr_a and dmr_b
    input
        .filter { meta, _bam, _bai, _ref -> meta.group == params.dmr_a }
        .set { ch_dmr_a }

    input
        .filter { meta, _bam, _bai, _ref -> meta.group == params.dmr_b }
        .set { ch_dmr_b }

    // Preprocess
    PREPROCESS_A(ch_dmr_a)

    versions = versions.mix(PREPROCESS_A.out.versions.first())

    PREPROCESS_B(ch_dmr_b)

    versions = versions.mix(PREPROCESS_B.out.versions.first())

    // Prepare inputs for modkit dmr

    PREPROCESS_A.out.bed_gz
        .toList()
        .map { sampleList ->
            def metas = sampleList.collect { it[0] }
            def beds  = sampleList.collect { it[1] }
            def tbis  = sampleList.collect { it[2] }
            tuple(metas, beds, tbis)
        }
        .set{ dmr_a }

    PREPROCESS_B.out.bed_gz
        .toList()
        .map { sampleList ->
            def metas = sampleList.collect { it[0] }
            def beds  = sampleList.collect { it[1] }
            def tbis  = sampleList.collect { it[2] }
            [metas, beds, tbis]
        }
        .set{ dmr_b }
    PREPROCESS_A.out.ch_ref_in.take(1).set{ ch_ref }

    // Modkit dmr
    DMR_POPULATION_SCALE(dmr_a, dmr_b, ch_ref)

    versions = versions.mix(DMR_POPULATION_SCALE.out.versions.first())

    DMR_POPULATION_SCALE.out.bed.set { dmr_out }

    emit:
    dmr_out
    versions
}
