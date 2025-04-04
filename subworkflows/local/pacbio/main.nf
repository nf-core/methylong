/*
 ===========================================
 * Import subworkflows
 ===========================================
 */

include { MAP_MINI } from './minimap2/main'
include { INDEX_PILEUP as MODK_PILEUP} from '../ont/pileup/main'
include { CPG_PILEUP } from './pbcpgtools/main'
include { MAP_PBMM2 } from './pbmm2/main'
include { SPLIT_STRAND } from './split_strand/main'
include { PROCESS_PB_BED } from '../shared/bed2bedgraphs/pbcpgtools/main'
include { PROCESS_MK_BED } from '../shared/bed2bedgraphs/modkit/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */

workflow PACBIO {
  
  take:
    input

  main:

  pacbio_versions = Channel.empty()

  // Case when aligner is minimap2 and pileup method is modkit 
  if (params.aligner == "minimap2" && params.pileup_method == "modkit") {
      if (params.bedgraph) {
        
        MAP_MINI(input)

        pacbio_versions    = pacbio_versions.mix(MAP_MINI.out.versions)
        map_stat = MAP_MINI.out.flagstat_out

        MODK_PILEUP(MAP_MINI.out.ch_pile_in)

        pacbio_versions    = pacbio_versions.mix(MODK_PILEUP.out.versions)

        PROCESS_MK_BED(MODK_PILEUP.out.pileup_out)

        pacbio_versions    = pacbio_versions.mix(PROCESS_MK_BED.out.versions)

      } else {

        MAP_MINI(input)

        pacbio_versions    = pacbio_versions.mix(MAP_MINI.out.versions)
        map_stat = MAP_MINI.out.flagstat_out

        MODK_PILEUP(MAP_MINI.out.ch_pile_in)

        pacbio_versions    = pacbio_versions.mix(MODK_PILEUP.out.versions)

      }

  // Case when aligner is pbmm2 and pileup method is modkit 
    } else if (params.aligner == "pbmm2" && params.pileup_method == "modkit") {

      if (params.bedgraph) {

          MAP_PBMM2(input)

          pacbio_versions    = pacbio_versions.mix(MAP_PBMM2.out.versions)
          map_stat = MAP_PBMM2.out.flagstat_out

          MODK_PILEUP(MAP_PBMM2.out.ch_pile_in)

          pacbio_versions    = pacbio_versions.mix(MODK_PILEUP.out.versions)

          PROCESS_MK_BED(MODK_PILEUP.out.pileup_out)

          pacbio_versions    = pacbio_versions.mix(PROCESS_MK_BED.out.versions)


        } else {

          MAP_PBMM2(input)

          pacbio_versions    = pacbio_versions.mix(MAP_PBMM2.out.versions)
          map_stat = MAP_PBMM2.out.flagstat_out
          

          MODK_PILEUP(MAP_PBMM2.out.ch_pile_in)

          pacbio_versions    = pacbio_versions.mix(MODK_PILEUP.out.versions)

        }
  // Case when aligner is minimap2 and pileup method is pbcpgtools 
    } else if (params.aligner == "minimap2" && params.pileup_method == "pbcpgtools") {
      
      if (params.bedgraph) {

          MAP_MINI(input)

          pacbio_versions    = pacbio_versions.mix(MAP_MINI.out.versions)
          map_stat = MAP_MINI.out.flagstat_out

          SPLIT_STRAND(MAP_MINI.out.ch_pile_in)

          pacbio_versions    = pacbio_versions.mix(SPLIT_STRAND.out.versions)

          CPG_PILEUP(SPLIT_STRAND.out.ch_pile_in)

          pacbio_versions    = pacbio_versions.mix(CPG_PILEUP.out.versions)

          PROCESS_PB_BED(CPG_PILEUP.out.pile_out)

          pacbio_versions    = pacbio_versions.mix(PROCESS_PB_BED.out.versions)


        } else {

          MAP_MINI(input)

          pacbio_versions    = pacbio_versions.mix(MAP_MINI.out.versions)
          map_stat = MAP_MINI.out.flagstat_out

          SPLIT_STRAND(MAP_MINI.out.ch_pile_in)

          pacbio_versions    = pacbio_versions.mix(SPLIT_STRAND.out.versions)

          CPG_PILEUP(SPLIT_STRAND.out.ch_pile_in)

          pacbio_versions    = pacbio_versions.mix(CPG_PILEUP.out.versions) 

        }

    } else {

      // default setting when aligner is pbmm2 and pileup method is pbcpgtools
      if (params.bedgraph) {

          MAP_PBMM2(input)

          pacbio_versions    = pacbio_versions.mix(MAP_PBMM2.out.versions)
          map_stat = MAP_PBMM2.out.flagstat_out

          SPLIT_STRAND(MAP_PBMM2.out.ch_pile_in)

          pacbio_versions    = pacbio_versions.mix(SPLIT_STRAND.out.versions)

          CPG_PILEUP(SPLIT_STRAND.out.ch_pile_in)

          pacbio_versions    = pacbio_versions.mix(CPG_PILEUP.out.versions) 

          PROCESS_PB_BED(CPG_PILEUP.out.pile_out)

          pacbio_versions    = pacbio_versions.mix(PROCESS_PB_BED.out.versions)

        } else {

          MAP_PBMM2(input)

          pacbio_versions    = pacbio_versions.mix(MAP_PBMM2.out.versions)
          map_stat = MAP_PBMM2.out.flagstat_out
          

          SPLIT_STRAND(MAP_PBMM2.out.ch_pile_in)

          pacbio_versions    = pacbio_versions.mix(SPLIT_STRAND.out.versions)

          CPG_PILEUP(SPLIT_STRAND.out.ch_pile_in)

          pacbio_versions    = pacbio_versions.mix(CPG_PILEUP.out.versions) 

        }
    }

    emit:

    pacbio_versions
    map_stat

}
