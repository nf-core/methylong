
/*
 ===========================================
 * Import subworkflows
 ===========================================
 */

include { TRIM_REPAIR } from './trim_repair/main'
include { ALIGN } from './align/main'
include { INDEX_PILEUP } from './pileup/main'
include { PROCESS_MK_BED } from '../shared/bed2bedgraphs/modkit/main'


/*
 ===========================================
 * Workflows
 ===========================================
 */



// for ONT 

workflow ONT {
    take: 
        ch_ont

    main:
        if (params.no_trim) {
            if (params.bedgraph) {

                ch_ont | ALIGN | INDEX_PILEUP | PROCESS_MK_BED

            } else {

                ch_ont | ALIGN | INDEX_PILEUP

            }
        } else {
            if (params.bedgraph) {

                ch_ont | TRIM_REPAIR | ALIGN | INDEX_PILEUP | PROCESS_MK_BED

            } else {

                ch_ont | TRIM_REPAIR | ALIGN | INDEX_PILEUP
                
            }
        }
}


