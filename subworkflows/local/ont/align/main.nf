/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { DORADO_ALIGNER } from '../../../../modules/local/dorado/aligner/main'
include { SAMTOOLS_FLAGSTAT } from '../../../../modules/nf-core/samtools/flagstat/main'

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

  // Preapre inputds for downstream 
  DORADO_ALIGNER.out.bam
                    .set{bam_file}

  DORADO_ALIGNER.out.bai
                    .set{bai_file}
  
  // Prepare input for samtool flagstat and modkit pileup
  bam_file
    .join(bai_file) { bam_meta, bai_meta -> bam_meta.meta == bai_meta.meta }
    .map { [it[0].meta, it[0].bam, it[1].bai] }
    .set { ch_pile_in1 }

  ch_ont
    .join(bam_file) { ont_meta, bam_meta -> ont_meta.meta == bam_meta.meta }
    .map {[it[0].meta, it[0].ref]}
    .set { ch_pile_in2 }

  // check alignment stat 
  SAMTOOLS_FLAGSTAT(ch_pile_in1)


  emit:

    ch_pile_in1
    ch_pile_in2

}