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
