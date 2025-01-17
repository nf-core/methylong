/*
 ===========================================
 * Import processes from modules
 ===========================================
 */

include { MODKIT_BEDGRAPH } from '../../../modules/bed2bedgraph/modkit_bedgraphs/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow PROCESS_BED {  
  
  take: 
    modkit_out

  
  main: 
    MODKIT_BEDGRAPH(modkit_out)

}
