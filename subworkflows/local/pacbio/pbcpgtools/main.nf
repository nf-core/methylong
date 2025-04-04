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
    ch_pile_in
  
  main:

  versions = Channel.empty()

  ch_pile_in
          .map { meta, mergedbam, index, _ref -> [meta, mergedbam, index] }
          .set { merged_bam }

  ch_pile_in
          .map { meta, _mergedbam, _index, ref -> [meta, ref] }
          .set { ch_pile_in2 }


  PB_CPG_TOOLS(merged_bam, ch_pile_in2)

  versions = versions.mix(PB_CPG_TOOLS.out.versions.first())

  PB_CPG_TOOLS.out.forwardbed
                  .join(PB_CPG_TOOLS.out.reversebed)
                  .set{ pile_out }
  
  emit:
     pile_out
     versions

}
