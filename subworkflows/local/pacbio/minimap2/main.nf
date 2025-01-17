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
      .map(row -> [row.meta, row.modBam])
      .set { fastq_in }

    SAMTOOLS_FASTQ(fastq_in)

    // Prepare input for minimap2 
    SAMTOOLS_FASTQ.out.other 
                      .join(input){fastq_meta, input_meta -> fastq_meta.meta == input_meta.meta}
                      .map {[it[0].meta, it[0]].other, it[1].ref}
                      .set{ mini_in }

    MINIMAP2(mini_in)
    
    // Prepare input for samtool flagstat and modkit pileup
    MINIMAP2.out.bam
                .join(MINIMAP2.out.index)
                .set { ch_pile_in1 }

    input
        .join(MINIMAP2.out.bam) { input_meta, mini_meta -> input_meta.meta == mini_meta.meta }
        .map {[it[0].meta, it[0].ref]}
        .set { ch_pile_in2 }

    
    SAMTOOLS_FLAGSTAT(ch_pile_in1)                              
    
 

  emit:
    ch_pile_in1
    ch_pile_in2
} 

