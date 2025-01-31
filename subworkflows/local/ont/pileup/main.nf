/*
 ===========================================
 * Import subworkflows
 ===========================================
 */

include { INDEX_REF } from './index_ref/main'
include { PILEUP } from './pileup/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow INDEX_PILEUP {  
  
  take: 
    input
  
  main: 

    input | INDEX_REF | PILEUP
   
   PILEUP.out
         .set { pileup_out }
                     

  emit:
    pileup_out

}