/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { SAMTOOLS_FASTQ } from '../../../../modules/nf-core/samtools/fastq/main'
include { SAMTOOLS_SORT } from '../../../../modules/nf-core/samtools/sort/main'
include { PORECHOP_PORECHOP } from '../../../../modules/nf-core/porechop/porechop/main'
include { SAMTOOLS_IMPORT } from '../../../../modules/nf-core/samtools/import/main'
include { MODKIT_REPAIR } from '../../../../modules/local/modkit/repair/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow TRIM_REPAIR {
  
  take:

    input

  main:

  // Create samtools sort input 
  input
      .map{ meta, modbam, _ref -> [meta, modbam]}
      .set { ch_sort_in }


  // Create inputs for ref 
  input
    .map{ meta, _modbam, ref -> [meta, ref]}
    .set { ch_ref_in }

  // Create a dummy tuple for samtools sort 
  input
      .map{ meta, _modbam, _ref -> [meta, []]}
      .set { ch_sort_dummy }

  SAMTOOLS_SORT(ch_sort_in, ch_sort_dummy)

  // set input to samtools fastq 
  SAMTOOLS_SORT.out.bam
                   .map { meta, bam -> [meta, bam] } 
                   .set { fastq_input }
  
  SAMTOOLS_FASTQ(fastq_input, [])


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
                   .join(ch_ref_in)
                   .map { meta, trimmed_bam, ref -> [ meta, trimmed_bam, ref]}
                   .set {dorado_in}

  emit: 
    dorado_in  
} 


