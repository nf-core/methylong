/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { SAMTOOLS_FASTQ } from '../../../modules/samtools/fastq/main'
include { SAMTOOLS_SORT } from '../../../modules/samtools/sort/main'
include { PORECHOP } from '../../../modules/porechop/main'
include { SAMTOOLS_IMPORT } from '../../../modules/samtools/import/main'
include { MODKIT_REPAIR } from '../../../modules/modkit/repair/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


workflow TRIM_REPAIR {
  take:
    input

  main:

  /*
  Sort modBam, convert to fastq, trim adapters and barcode, then convert back to bam and repair the MM/ML tags using modkit repair 
  then align to reference assembly, and pileup to create bedMethyl using modkit pileup
  */

  input
      .map(row -> [row.sample, row.ref])
      .set{ refs }

  input
      .map(row -> [row.sample, row.method])
      .set{ method }

  input
      .map(row -> [row.sample, row.modBam])
      .set { reads_in }


  ch_in | SAMTOOLS_SORT | SAMTOOLS_FASTQ | PORECHOP

  SAMTOOLS_SORT(reads_in)
  SAMTOOLS_FASTQ(SAMTOOLS_SORT.out.bam)
  PORECHOP(SAMTOOLS_FASTQ.out.fastq)
  SAMTOOLS_IMPORT(PORECHOP.out.reads)
  ch_modkit_in = SAMTOOLS_SORT.out.bam.join(SAMTOOLS_IMPORT.out.bam) 
  MODKIT_REPAIR(ch_modkit_in)
  MODKIT_REPAIR.out.bam
                   .join(refs)
                   .join(method)
                   .set { dorado_in }

  emit: 
    dorado_in  
    refs
    method
} 


// rewrite the workflow 

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
  
  SAMTOOLS_FASTQ(fastq_input)


  PORECHOP(SAMTOOLS_FASTQ.out.other)
  
  SAMTOOLS_IMPORT(PORECHOP.out.reads)
  ch_modkit_in = SAMTOOLS_SORT.out.bam.join(SAMTOOLS_IMPORT.out.bam) 
  MODKIT_REPAIR(ch_modkit_in)
  MODKIT_REPAIR.out.bam
                   .join(refs)
                   .join(method)
                   .set { dorado_in }

  emit: 
    dorado_in  
    refs
    method
} 
