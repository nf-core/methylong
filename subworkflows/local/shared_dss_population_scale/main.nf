/*
===========================================
 * Import processes from modules
===========================================
 */

include { DSS_POPULATION_SCALE_PREPROCESS     as PREPROCESS_A } from './preprocess/main'
include { DSS_POPULATION_SCALE_PREPROCESS     as PREPROCESS_B } from './preprocess/main'
include { DSS        as DSS_POPULATION_SCALE                  } from '../../../modules/local/dss/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow DSS_DMR_POPULATION_SCALE {
    take:
    input
    dmr_a
    dmr_b

    main:

    versions = Channel.empty()

    // Split input into two groups: dmr_a and dmr_b
    input
        .branch { 
            dmr_a: {meta, _bam, _bai, _ref -> meta.group == dmr_a}
            dmr_b: {meta, _bam, _bai, _ref -> meta.group == dmr_b}
        }
    .set { branched_input }

    // Preprocess
    PREPROCESS_A(branched_input.dmr_a)

    versions = versions.mix(PREPROCESS_A.out.versions.first())

    PREPROCESS_B(branched_input.dmr_b)

    versions = versions.mix(PREPROCESS_B.out.versions.first())

    // Prepare inputs for dss
    PREPROCESS_A.out.bed_preprocessed
        .toList()
        .map { sampleList ->
            def metas = sampleList.collect { it[0] }
            def beds  = sampleList.collect { it[1] }
            [metas, beds]
        }
        .set{ dmr_a }

    PREPROCESS_B.out.bed_preprocessed
        .toList()
        .map { sampleList ->
            def metas = sampleList.collect { it[0] }
            def beds  = sampleList.collect { it[1] }
            [metas, beds]
        }
        .set{ dmr_b }

    // dss
    DSS_POPULATION_SCALE( dmr_a, dmr_b )

    versions = versions.mix(DSS_POPULATION_SCALE.out.versions.first())

    DSS_POPULATION_SCALE.out.txt.set { dmr_out }

    emit:
    dmr_out
    versions
}
