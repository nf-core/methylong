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
      .map(row -> [row.meta, row.modBam])
      .set { ch_sort_in }


  // Create a dummy tuple for samtools sort 
  input
      .map(row -> [row.meta, "/dev/null"])
      .set { ch_sort_dummy }

  SAMTOOLS_SORT(ch_sort_in, ch_sort_dummy)

  // set input to samtools fastq 
  SAMTOOLS_SORT.out.bam
                   .map { meta, in_bam ->
                          [meta, in_bam, ""] } // Add an empty string to satisfy samtools fastq input requirement 
                   .set { fastq_input }
  
  SAMTOOLS_FASTQ(fastq_input, ch_sort_dummy)


  PORECHOP_PORECHOP(SAMTOOLS_FASTQ.out.other)  // might have problems here, double check 

  SAMTOOLS_IMPORT(PORECHOP_PORECHOP.out.reads)

  // Prepare input for modkit repair 
  SAMTOOLS_SORT.out.bam
                   .join(SAMTOOLS_IMPORT.out.bam) { sort_meta, import_meta -> sort_meta.meta == import_meta.meta }
                   .map{ [it[0].meta, it[0].bam, it[1].bam]}
                   .set { ch_repair_in }

  MODKIT_REPAIR(ch_repair_in)

  // Prepare input for alignment step

  MODKIT_REPAIR.out.bam
                   .join(refs)
                   .join(method)
                   .set { dorado_in }

  MODKIT_REPAIR.out.bam
                   .join(input){ repair_meta, input_meta -> repair_meta.meta == input_meta.meta }
                   .map{ [it[0].meta, it[0].bam, it[1].ref, it[1].method]}
                   .set { dorado_in }


  emit: 
    dorado_in  
} 


