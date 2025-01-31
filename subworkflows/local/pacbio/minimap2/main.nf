/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { SAMTOOLS_FASTQ } from '../../../../modules/nf-core/samtools/fastq/main'
include { SAMTOOLS_FLAGSTAT } from '../../../../modules/nf-core/samtools/flagstat/main'
include { MINIMAP2 } from '../../../../modules/local/minimap2/main'

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
      .set{ fastq_in }

    input
        .map{ meta, _modbam, ref -> [meta, ref]}
        .set{ ref_in }

    SAMTOOLS_FASTQ(fastq_in, [])


    // Prepare input for minimap2 
    SAMTOOLS_FASTQ.out.other 
                      .join(ref_in)
                      .map {meta, fastq, ref -> [meta, fastq, ref]}
                      .set {mini_in }
    
    MINIMAP2(mini_in)
    
    // Prepare input for samtool flagstat and modkit pileup
    MINIMAP2.out.bam
                .join(MINIMAP2.out.index) 
                .set { ch_flagstat_in }

    MINIMAP2.out.bam
                .join(MINIMAP2.out.index)
                .join(ref_in)
                .map {meta, bam, bai, ref -> [meta, bam, bai, ref]}
                .set {ch_pile_in}


    SAMTOOLS_FLAGSTAT(ch_flagstat_in)                              
    
  emit:
    ch_pile_in
} 

