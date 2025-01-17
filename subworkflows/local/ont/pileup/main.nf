/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { MODKIT_PILEUP } from '../../../modules/modkit/pileup/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow PILEUP {  
  
  take: 
    ch_pileup_in
  
  main: 

    MODKIT_PILEUP(ch_pileup_in)
    MODKIT_PILEUP.out.bed
                     .join(ch_pileup_in){modkit_meta, input_data -> modkit_meta.meta == input_data.meta}
                     .map { it[0].bed, it[1].method }
                     .set { pileup_out }
                     
  emit: 
    pileup_out

}