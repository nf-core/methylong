/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_EXTRACT   as MODKIT_EXTRACT_1     } from '../../../modules/local/modkit/extract/main'
include { MODKIT_EXTRACT   as MODKIT_EXTRACT_2     } from '../../../modules/local/modkit/extract/main'
include { POREMETH2                                } from '../../../modules/local/poremeth2/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow POREMETH2_POPULATION_SCALE {
    take:
    input1
    input2

    main:

    versions = Channel.empty()
    
    input1
        .multiMap { meta, bam, bai, ref, fai ->
                bam_in: [meta, bam, bai]
                ref_in: [meta, ref, fai]
        }
        .set { ch_input1 }
    
    input2
        .multiMap { meta, bam, bai, ref, fai ->
                bam_in: [meta, bam, bai]
                ref_in: [meta, ref, fai]
        }
        .set { ch_input2 }

    // Modkit extract
    MODKIT_EXTRACT_1(ch_input1.bam_in, ch_input1.ref_in)

    versions = versions.mix(MODKIT_EXTRACT_1.out.versions.first())

    MODKIT_EXTRACT_2(ch_input2.bam_in, ch_input2.ref_in)
    
    versions = versions.mix(MODKIT_EXTRACT_2.out.versions.first())

    // PoreMeth2 dmr
    POREMETH2(MODKIT_EXTRACT_1.out.tsv, MODKIT_EXTRACT_2.out.tsv)

    versions = versions.mix(POREMETH2.out.versions.first())

    emit:
    versions
}
