/*
 ===========================================
 * Import processes from modules
 ===========================================
 */

include { SAMTOOLS_FAIDX } from '../../../../../modules/nf-core/samtools/faidx/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow INDEX_REF {
  
  take:

    input

  main:

  // Prepare inputs for ref index 
  input
      .map{ meta, _bam, _bai, ref -> [meta, ref]}
      .set { ch_ref_in }

  input
      .map{ meta, bam, bai, _ref -> [meta, bam, bai]}
      .set { ch_bam_in }  
  
  // Index ref 
  SAMTOOLS_FAIDX(ch_ref_in, [[],[]])

  // Prepare input for modkit pileup 
  ch_ref_in
          .join(SAMTOOLS_FAIDX.out.fai)
          .join(ch_bam_in)
          .map { meta, ref, fai, bam, bai -> [meta, bam, bai, ref, fai] }
          .set { ch_pileup_in}


  emit: 
    ch_pileup_in  
} 


