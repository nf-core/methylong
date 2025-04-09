/*
 ===========================================
 * Import processes from modules
 ===========================================
 */


include { SAMTOOLS_FLAGSTAT } from '../../../modules/nf-core/samtools/flagstat/main'
include { MINIMAP2_ALIGN    } from '../../../modules/nf-core/minimap2/align/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */


// for PacBio 

workflow PACBIO_ALIGN_MINI {
  take:
  input

  main:

  versions = Channel.empty()

  // Prepare input for samtools fastq 
  input
    .map { meta, modbam, _ref -> [meta, modbam] }
    .set { mini_in }

  input
    .map { meta, _modbam, ref -> [meta, ref] }
    .set { ref_in }


  MINIMAP2_ALIGN(mini_in, ref_in, "bam_format", "bai", [], [])

  versions = versions.mix(MINIMAP2_ALIGN.out.versions.first())


  // Prepare input for samtool flagstat and modkit pileup
  MINIMAP2_ALIGN.out.bam
    .join(MINIMAP2_ALIGN.out.index)
    .set { ch_flagstat_in }

  MINIMAP2_ALIGN.out.bam
    .join(MINIMAP2_ALIGN.out.index)
    .join(ref_in)
    .map { meta, bam, bai, ref -> [meta, bam, bai, ref] }
    .set { ch_pile_in }


  SAMTOOLS_FLAGSTAT(ch_flagstat_in)

  versions = versions.mix(SAMTOOLS_FLAGSTAT.out.versions.first())
  SAMTOOLS_FLAGSTAT.out.flagstat.set { flagstat_out }

  emit:
  ch_pile_in
  versions
  flagstat_out
}
