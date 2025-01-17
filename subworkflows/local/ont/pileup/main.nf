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
    ch_pileup_in
            .map(row -> [row.meta, ""])
            .set { ch_pile_dummy }

    MODKIT_PILEUP(ch_pile_in1, ch_pile_in2, ch_pile_dummy)

    MODKIT_PILEUP.out.bed
                     .join(ch_pileup_in){modkit_meta, input_data -> modkit_meta.meta == input_data.meta}
                     .map { [it[0].bed, it[1].method] }
                     .set { pileup_out }
                     
  emit: 
    pileup_out

}