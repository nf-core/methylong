/*
 ===========================================
 * Import processes from modules
 ===========================================
 */



include { SAMTOOLS_FLAGSTAT } from '../../../../modules/nf-core/samtools/flagstat/main'
include { SAMTOOLS_INDEX } from '../../../../modules/nf-core/samtools/index/main'
include { PBMM2_ALIGN } from '../../../../modules/nf-core/pbmm2/align/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


// for PacBio 

workflow MAP_PBMM2 {
  
  take: 
    input

  main:

    input
      .map{row -> [row.id, row.modbam]}
      .set{ reads_in }

    input
      .map{row -> [row.id, row.ref]}
      .set{ ref_in }

    PBMM2_ALIGN(reads_in, ref_in)

    SAMTOOLS_INDEX(PBMM2_ALIGN.out.bam)

    // Prepare input for samtool flagstat and modkit pileup
    PBMM2_ALIGN.out.bam
                .join(SAMTOOLS_INDEX.out.bai)
                .set { ch_pile_in1 }

    input
        .join(PBMM2_ALIGN.out.bam) { input_meta, pbmm_meta -> input_meta.meta == pbmm_meta.meta }
        .map {[it[0].meta, it[0].ref]}
        .set { ch_pile_in2 }


    SAMTOOLS_FLAGSTAT(ch_pile_in1)
                                  

  emit:
    ch_pile_in1
    ch_pile_in2

 } 

