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
    dorado_in

  main:

  // Alignment with dorado 
  DORADO_ALIGNER(dorado_in)

  // Preapre inputs for downstream
  DORADO_ALIGNER.out.bam
                    .join(DORADO_ALIGNER.out.bai)
                    .map { meta, bam, bai -> [meta, bam, bai]}
                    .set { ch_pile_in1 }

  DORADO_ALIGNER.out.bam
                    .join(dorado_in)
                    .map { meta, _aligned_bam, _inbam, ref -> [meta, ref]}
                    .set { ch_pile_in2 }


  // check alignment stat 
  SAMTOOLS_FLAGSTAT(ch_pile_in1)


  emit:

    ch_pile_in1
    ch_pile_in2

}