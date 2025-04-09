/*
 ===========================================
 * Import processes from modules
 ===========================================
 */

include { MODKIT_BEDGRAPH } from '../../../modules/local/bed2bedgraphs/modkit_bedgraphs/main'
include { PBCPG_BEDGRAPHS } from '../../../modules/local/bed2bedgraphs/pbcpgtools_bedgraphs/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */

workflow BED2BEDGRAPH {
  take:
  in_bed

  main:

  // input bed is different between modkit and pbcpgtool: tuple(meta, bed) or tuple(meta, forward_bed, reverse_bed)

  // Create two input branches
  modkit_input = in_bed.filter { it[0].method == 'ont' || (it[0].method == 'pacbio' && params.pileup_method == 'modkit') }
  pbcpg_input = in_bed.filter { it[0].method == 'pacbio' && params.pileup_method == 'pbcpgtools' }


  MODKIT_BEDGRAPH(modkit_input)
  PBCPG_BEDGRAPHS(pbcpg_input)

  versions = MODKIT_BEDGRAPH.out.versions.mix(PBCPG_BEDGRAPHS.out.versions)

  emit:
  versions
}
