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
    MODKIT_BEDGRAPH(modkit_out)

}
