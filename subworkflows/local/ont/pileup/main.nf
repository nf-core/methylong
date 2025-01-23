/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { MODKIT_PILEUP } from '../../../../modules/local/modkit/pileup/main'
include { SAMTOOLS_FAIDX } from '../../../../modules/nf-core/samtools/faidx/main'
include { GUNZIP } from '../../../../modules/nf-core/gunzip/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow PILEUP {  
  
  take: 
    ch_pile_in1
    ch_pile_in2
  
  main: 

    // Prepare dummy inputs for modkit pileup 
    ch_pile_in1
            .map{meta, _bam, _bai -> [meta, []]}
            .set { ch_pile_dummy }

  
    // Then, index 
    SAMTOOLS_FAIDX(ch_pile_in2, ch_pile_dummy)

    ch_pile_in2
              .join(SAMTOOLS_FAIDX.out.fai)
              .map { meta, ref, index -> [meta, ref, index]}
              .set { ch_pile_index }


    MODKIT_PILEUP(ch_pile_in1, ch_pile_index, ch_pile_dummy)

    MODKIT_PILEUP.out.bed
                 .set { pileup_out }
  
                     
  emit: 
    pileup_out

}