/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { MODKIT_PILEUP } from '../../../../modules/nf-core/modkit/pileup/main'

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
    

    MODKIT_PILEUP(ch_pile_in1, ch_pile_in2, ch_pile_dummy)

    MODKIT_PILEUP.out.bed
                 .set { pileup_out }

    
                     
  emit: 
    pileup_out

}