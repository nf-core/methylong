/*
 ===========================================
 * Import processes from modules
 ===========================================
 */

include { MODKIT_BEDGRAPH } from '../../../modules/local/bed2bedgraphs/modkit_bedgraphs/main'
include { PBCPG_BEDGRAPHS } from '../../../modules/local/bed2bedgraphs/pbcpgtools_bedgraphs/main'

/*
 ===========================================
 * Import subworkflows
 ===========================================
 */

include { MAP_MINI } from './minimap2/main'
include { PILEUP as MODK_PILEUP} from '../ont/pileup/main'
include { CPG_PILEUP } from './pbcpgtools/main'
include { MAP_PBMM2 } from './pbmm2/main'
include { SPLIT_STRAND } from './split_strand/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */

workflow PACBIO {
  
  take:
    input

  main:


  // Case when aligner is minimap2 and pileup method is modkit 
  if (params.aligner == "minimap2" && params.pileup_method == "modkit") {
      if (params.bedgraph) {
        input | MAP_MINI | MODK_PILEUP | MODKIT_BEDGRAPH
      } else {
        input | MAP_MINI | MODK_PILEUP 
      }

  // Case when aligner is pbmm2 and pileup method is modkit 
    } else if (params.aligner == "pbmm2" && params.pileup_method == "modkit") {

      if (params.bedgraph) {
          input | MAP_PBMM2 | MODK_PILEUP | MODKIT_BEDGRAPH
        } else {
          input | MAP_PBMM2 | MODK_PILEUP 
        }
  // Case when aligner is minimap2 and pileup method is pbcpgtools 
    } else if (params.aligner == "minimap2" && params.pileup_method == "pbcpgtools") {
      
      if (params.bedgraph) {
          input | MAP_MINI | SPLIT_STRAND | CPG_PILEUP | PBCPG_BEDGRAPHS
        } else {
          input | MAP_MINI | SPLIT_STRAND | CPG_PILEUP 
        }

    } else {

      // default setting when aligner is pbmm2 and pileup method is pbcpgtools
      if (params.bedgraph) {
          input | MAP_PBMM2 | SPLIT_STRAND | CPG_PILEUP | PBCPG_BEDGRAPHS
        } else {
          input | MAP_PBMM2 | SPLIT_STRAND | CPG_PILEUP 
        }
    }
}
