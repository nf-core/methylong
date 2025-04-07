/*
 ===========================================
 * Import processes from modules
 ===========================================
 */

include { PBCPG_BEDGRAPHS } from '../../../../../modules/local/bed2bedgraphs/pbcpgtools_bedgraphs/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow PROCESS_PB_BED {  
  
  take: 
    pile_out
  
  main: 

    versions        = Channel.empty()

    PBCPG_BEDGRAPHS(pile_out)

    versions = versions.mix(PBCPG_BEDGRAPHS.out.versions.first())

  emit:   
    versions

}

