/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { PACBIO   } from '../subworkflows/local/pacbio/main'
include { ONT      } from '../subworkflows/local/ont/main'

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
                   meta.modbam = row.modbam
                   meta.ref = row.ref
                   meta.method = row.method
                   return [meta]
               }
               .set { ch_samples }

        ch_samples.view{ "${it}"}

        // Split the channel based on method
        
        ch_samples.map { it[0] }
                  .filter { it.method == "pacbio" }
                  .set {ch_pacbio}

        ch_samples.map { it[0] }
                  .filter { it.method == "ont" }
                  .set {ch_ont}

        // Debug: View the content of ch_pacbio and ch_ont
        ch_pacbio.view { "${it}"}
        ch_ont.view { "${it}" }

        // Handle PacBio samples
        //PACBIO(ch_pacbio)

        // Handle ONT samples
        ONT(ch_ont)

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
