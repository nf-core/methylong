/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { DORADO_ALIGNER } from '../../../modules/dorado/aligner/main'
include { SAMTOOLS_FLAGSTAT } from '../../../modules/samtools/flagstat/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow ALIGN {
  
  take: 
    ch_ont

  main:

  // Alignment with dorado 
  DORADO_ALIGNER(ch_ont)
  bam_file = DORADO_ALIGNER.out.bam
  bai_file = DORADO_ALIGNER.out.bai
  
  // Prepare input for samtool flagstat 
  bam_file
    .join(ch_ont) { bam_meta, ont_meta -> bam_meta.meta == ont_meta.meta }
    .map { it[0].bam, it[1].method, "alignment" }
    .set { flagstat_in }

  // check alignment stat 
  SAMTOOLS_FLAGSTAT(flagstat_in)
  
  // Prepare input for modkit pileup 
  bam_file
    .join(bai_file) { bam_meta, bai_meta -> bam_meta.meta == bai_meta.meta }
    .join(ch_ont) { bam_meta, ont_meta -> bam_meta.meta == ont_meta.meta }
    .map { it[0].bam, it[1].bai, it[2].ref, it[2].method}
    .set { ch_pileup_in }

  emit:

    ch_pileup_in

}