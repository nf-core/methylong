/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { PACBIO   } from '../subworkflows/local/pacbio/main'
include { ONT      } from '../subworkflows/local/ont/main'
include { MAP_MINI } from '../subworkflows/local/pacbio/minimap2/main'
include { MAP_PBMM2 } from '../subworkflows/local/pacbio/pbmm2/main'
include { PILEUP as MODK_PILEUP} from '../subworkflows/local/ont/pileup/main'
include { SPLIT_STRAND } from '../subworkflows/local/pacbio/split_strand/main'
include { CPG_PILEUP } from '../subworkflows/local/pacbio/pbcpgtools/main'
include { PROCESS_PB_BED } from '../subworkflows/local/pacbio/process_bed/main'
include { PROCESS_BED } from '../subworkflows/local/ont/process_bed/main'
include { TRIM_REPAIR } from '../subworkflows/local/ont/trim_repair/main'
include { ALIGN } from '../subworkflows/local/ont/align/main'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow METHYLONG {
    // Check if the samplesheet parameter is provided
    if (params.samplesheet) {
        Channel.fromPath(params.samplesheet)
               .splitCsv(header: true)
               .map { row ->
                   def meta = [:]
                   meta.id = row.sample
                   meta.method = row.method
                   return [meta,  row.modbam, row.ref]
                    }
               .set { ch_samples }

        //ch_samples.view {it[0]}
   

        // Split the channel based on method
        
        ch_samples
                  .filter {  it[0].method == "pacbio" }
                  .set {ch_pacbio}

        ch_samples
                  .filter {  it[0].method == "ont" }
                  .set {ch_ont}


        //ch_pacbio
        //       .map{ meta, modbam, _ref -> [meta, modbam]}
        //       .set{ reads_in }

        //ch_pacbio
        //       .map{ meta, _modbam, ref -> [meta, ref]}
        //       .set{ ref_in }



        ch_pacbio |  MAP_MINI | SPLIT_STRAND | CPG_PILEUP | PROCESS_PB_BED

        ch_ont | TRIM_REPAIR | ALIGN | MODK_PILEUP | PROCESS_BED
        ch_ont.view { "${it}" }

        // Handle PacBio samples
        //PACBIO(ch_pacbio)

        // Handle ONT samples
        //ONT(ch_ont)

    } else {
        // Exit if no samplesheet is provided
        exit 1, 'Input samplesheet not specified!'
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
