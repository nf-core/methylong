/*
 ===========================================
 * Import processes from modules
 ===========================================
 */

include { PB_CPG_TOOLS } from '../../../../modules/local/pb_cpg_tools/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


// for PacBio 

workflow CPG_PILEUP {
  
  take:
    merged_bam
    ch_pile_in2
  
  main:

  PB_CPG_TOOLS(merged_bam, ch_pile_in2)
  PB_CPG_TOOLS.out.forwardbed
                  .join(PB_CPG_TOOLS.out.reversebed)
                  .set{ pile_out }
  
  emit:
     pile_out

}
