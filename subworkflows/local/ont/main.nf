
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

        ont_versions = Channel.empty()

        if (params.no_trim) {
            if (params.bedgraph) {

                ALIGN(ch_ont)
                
                ont_versions    = ont_versions.mix(ALIGN.out.versions)
                map_stat = ALIGN.out.flagstat_out

                INDEX_PILEUP(ALIGN.out.ch_pile_in)

                ont_versions    = ont_versions.mix(INDEX_PILEUP.out.versions)

                PROCESS_MK_BED(INDEX_PILEUP.out.pileup_out)

                ont_versions    = ont_versions.mix(PROCESS_MK_BED.out.versions)

            } else {

                ALIGN(ch_ont)
                
                ont_versions    = ont_versions.mix(ALIGN.out.versions)
                map_stat = ALIGN.out.flagstat_out

                INDEX_PILEUP(ALIGN.out.ch_pile_in)

                ont_versions    = ont_versions.mix(INDEX_PILEUP.out.versions)

            }
        } else {
            if (params.bedgraph) {

                TRIM_REPAIR(ch_ont)

                ont_versions    = ont_versions.mix(TRIM_REPAIR.out.versions)

                ALIGN(TRIM_REPAIR.out.dorado_in)

                ont_versions    = ont_versions.mix(ALIGN.out.versions)
                map_stat = ALIGN.out.flagstat_out

                INDEX_PILEUP(ALIGN.out.ch_pile_in)

                ont_versions    = ont_versions.mix(INDEX_PILEUP.out.versions)

                PROCESS_MK_BED(INDEX_PILEUP.out.pileup_out)

                ont_versions    = ont_versions.mix(PROCESS_MK_BED.out.versions)

            } else {

                TRIM_REPAIR(ch_ont)

                ont_versions    = ont_versions.mix(TRIM_REPAIR.out.versions)

                ALIGN(TRIM_REPAIR.out.dorado_in)

                ont_versions    = ont_versions.mix(ALIGN.out.versions)
                map_stat = ALIGN.out.flagstat_out

                INDEX_PILEUP(ALIGN.out.ch_pile_in)

                ont_versions    = ont_versions.mix(INDEX_PILEUP.out.versions)
                
            }
        }

    emit:

    ont_versions
    map_stat


}


