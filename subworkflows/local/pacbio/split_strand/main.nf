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
    input
  
  main:

  // prepare input 

  input 
      .map { meta, bam, bai, _ref -> [meta, bam, bai]}
      .set { ch_split_in}

  input 
      .map { meta, _bam, _bai, ref -> [meta, ref]}
      .set { ch_ref_in}


  SAMTOOLS_SPLIT_STRAND(ch_split_in) 

  SAMTOOLS_SPLIT_STRAND.out.forwardbam
                           .join(SAMTOOLS_SPLIT_STRAND.out.reversebam)
                           .set{ stranded_out }
  
  SAMTOOLS_MERGE(stranded_out)


  // Prepare inputs for pbcpgtools
  SAMTOOLS_MERGE.out.bam
                    .join(SAMTOOLS_MERGE.out.index)
                    .join(ch_ref_in)
                    .map{ meta, mergedbam, index, ref -> [meta, mergedbam, index, ref]}
                    .set{ ch_pile_in }

  emit:
     ch_pile_in

}
