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
        .map{ meta, modbam, _ref -> [meta, modbam]}
        .set{ reads_in }

    input
        .map{ meta, _modbam, ref -> [meta, ref]}
        .set{ ref_in }


    PBMM2_ALIGN(reads_in, ref_in)

    SAMTOOLS_INDEX(PBMM2_ALIGN.out.bam)

    // Prepare input for samtool flagstat and modkit pileup
    PBMM2_ALIGN.out.bam
                .join(SAMTOOLS_INDEX.out.bai)
                .set { ch_flagstat_in }
    
    PBMM2_ALIGN.out.bam
                .join(SAMTOOLS_INDEX.out.bai)
                .join(ref_in)
                .map { meta, bam, bai, ref -> [meta, bam, bai, ref]}
                .set { ch_pile_in}
  
  // check alignment stat 
    SAMTOOLS_FLAGSTAT(ch_flagstat_in)
                                  

  emit:
    ch_pile_in
    
 } 

