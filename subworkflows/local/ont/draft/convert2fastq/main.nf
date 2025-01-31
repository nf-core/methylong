/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { SAMTOOLS_FASTQ } from '../../../../../modules/nf-core/samtools/fastq/main'
include { SAMTOOLS_SORT } from '../../../../../modules/nf-core/samtools/sort/main'
include { PORECHOP_PORECHOP } from '../../../../../modules/nf-core/porechop/porechop/main'
include { SAMTOOLS_IMPORT } from '../../../../../modules/nf-core/samtools/import/main'
include { MODKIT_REPAIR } from '../../../../../modules/local/modkit/repair/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow CONVERT2FASTQ {
  
  take:

    fastq_input

  main:

  // Create samtools sort input 
  fastq_input
      .map{ meta, modbam, _dummy -> [meta, modbam]}
      .set { ch_fastq_in }


  // Create a dummy tuple for samtools sort 
  fastq_input
      .map{ meta, _modbam, dummy -> [meta, dummy]}
      .set { ch_fastq_dummy }

  
  SAMTOOLS_FASTQ(ch_fastq_in, ch_fastq_dummy)


  PORECHOP_PORECHOP(SAMTOOLS_FASTQ.out.other)  

  SAMTOOLS_IMPORT(PORECHOP_PORECHOP.out.reads)

  // Prepare input for modkit repair 
  SAMTOOLS_SORT.out.bam
                   .join(SAMTOOLS_IMPORT.out.bam)
                   .map { meta, before_trim, after_trim -> [meta, before_trim, after_trim]}
                   .set { ch_repair_in }

  MODKIT_REPAIR(ch_repair_in)

  // Prepare input for alignment step


  MODKIT_REPAIR.out.bam
                   .join(input)
                   .map { meta, trimmed_bam, _inbam, ref -> [ meta, trimmed_bam, ref]}
                   .set {dorado_in}

  emit: 
    dorado_in  
} 


