/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


iinclude { SAMTOOLS_FLAGSTAT } from '../../../../modules/nf-core/samtools/flagstat/main'
include { MINIMAP2_ALIGN } from '../../../../modules/nf-core/minimap2/align/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


// for PacBio 

workflow MAP_MINI {
  
  take: 
    input

  main:

    // Prepare input for samtools fastq 
    input
      .map{ meta, modbam, _ref -> [meta, modbam]}
      .set{ mini_in }

    input
        .map{ meta, _modbam, ref -> [meta, ref]}
        .set{ ref_in }


    MINIMAP2_ALIGN(mini_in, ref_in, "bam_format", "bai", [], [])

    
    // Prepare input for samtool flagstat and modkit pileup
    MINIMAP2_ALIGN.out.bam
                .join(MINIMAP2_ALIGN.out.index) 
                .set { ch_flagstat_in }

    MINIMAP2_ALIGN.out.bam
                .join(MINIMAP2_ALIGN.out.index)
                .join(ref_in)
                .map {meta, bam, bai, ref -> [meta, bam, bai, ref]}
                .set {ch_pile_in}


    SAMTOOLS_FLAGSTAT(ch_flagstat_in)                              
    
  emit:
    ch_pile_in
} 

