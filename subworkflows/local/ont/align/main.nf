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

  // prepare refrence for downstream
  dorado_in
          .map { meta, _modbam, ref -> [meta, ref] }
          .set { ref_in }

  // Alignment with dorado 
  DORADO_ALIGNER(dorado_in)

  // Preapre inputs for downstream
  DORADO_ALIGNER.out.bam
                    .join(DORADO_ALIGNER.out.bai)
                    .map { meta, bam, bai -> [meta, bam, bai]}
                    .set { ch_flagstat_in }

  DORADO_ALIGNER.out.bam
                    .join(DORADO_ALIGNER.out.bai)
                    .join(ref_in)
                    .map { meta, alignedbam, index, ref -> [meta, alignedbam, index, ref]}
                    .set { ch_pile_in }


  // check alignment stat 
  SAMTOOLS_FLAGSTAT(ch_flagstat_in)

  emit:

    ch_pile_in

}