/*
 ===========================================
 * Import processes from modules
 ===========================================
 */

include { MODKIT_BEDGRAPH } from '../../../../../modules/local/bed2bedgraphs/modkit_bedgraphs/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */

workflow PROCESS_MK_BED {  
  
  take: 
    modkit_out

  
  main: 
  
    versions        = Channel.empty()
    
    MODKIT_BEDGRAPH(modkit_out)
    
    versions = versions.mix(MODKIT_BEDGRAPH.out.versions.first())

    emit:   
    versions


}
