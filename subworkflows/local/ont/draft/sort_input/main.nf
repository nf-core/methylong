/*
 ===========================================
 * Import processes from modules
 ===========================================
 */

include { SAMTOOLS_SORT } from '../../../../../modules/nf-core/samtools/sort/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow SORT_INPUT {
  
  take:

    input

  main:

  // Create samtools sort input 
  input
      .map{ meta, modbam, _ref -> [meta, modbam]}
      .set { ch_sort_in }


  // Create a dummy tuple for samtools sort 
  input
      .map{ meta, _modbam, _ref -> [meta, []]}
      .set { ch_sort_dummy }

  SAMTOOLS_SORT(ch_sort_in, ch_sort_dummy)

  // set input to samtools fastq 
  SAMTOOLS_SORT.out.bam
                   .map { meta, bam -> [meta, bam, []] } 
                   .set { fastq_input }

  emit: 
    fastq_input  
} 


