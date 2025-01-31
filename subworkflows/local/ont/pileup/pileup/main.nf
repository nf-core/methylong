/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { MODKIT_PILEUP } from '../../../../../modules/local/modkit/pileup/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow PILEUP {
  
  take:

    input

  main:

  // Prepare inputs for pileup
  input
      .map{ meta, _bam, _bai, ref, fai -> [meta, ref, fai]}
      .set { ch_ref_in }

  input
      .map{ meta, bam, bai, _ref, _fai -> [meta, bam, bai]}
      .set { ch_bam_in }  
  
  // Modkit pileup 
  MODKIT_PILEUP(ch_bam_in, ch_ref_in, [[],[]])

  MODKIT_PILEUP.out.bed
                 .set { pileup_out }

  emit: 
    pileup_out  
} 


