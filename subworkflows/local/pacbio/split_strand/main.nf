/*
 ===========================================
 * Import processes from modules
 ===========================================
 */

include { SAMTOOLS_SPLIT_STRAND } from '../../../../modules/local/samtools/split_strands/main'
include { SAMTOOLS_MERGE } from '../../../../modules/local/samtools/merge/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


// for PacBio 

workflow SPLIT_STRAND {
  
  take:
    ch_pile_in1
    ch_pile_in2
  
  main:

  SAMTOOLS_SPLIT_STRAND(ch_pile_in1) 
  SAMTOOLS_SPLIT_STRAND.out.forwardbam
                           .join(SAMTOOLS_SPLIT_STRAND.out.reversebam)
                           .set{ stranded_out }
  
  SAMTOOLS_MERGE(stranded_out)


  // Prepare inputs for pbcpgtools
  SAMTOOLS_MERGE.out.bam
                    .join(SAMTOOLS_MERGE.out.index)
                    .set{ merged_bam }

  emit:
     merged_bam
     ch_pile_in2

}
