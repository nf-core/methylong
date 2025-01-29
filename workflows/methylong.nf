/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { PACBIO   } from '../subworkflows/local/pacbio/main'
include { ONT      } from '../subworkflows/local/ont/main'
include { UNZIP } from '../subworkflows/local/shared/unzip/main'

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

        // Split the channel based on method
        
        ch_samples
                  .filter {  it[0].method == "pacbio" }
                  .set {ch_pacbio}

        ch_samples
                  .filter {  it[0].method == "ont" }
                  .set {ch_ont}


        //ch_pacbio.view { "pacbio read: ${it[0]}, additional info: ${it[1]}" }
        //ch_ont.view { "ont read: ${it[0]}, additional info: ${it[1]}" }
        // Handle PacBio samples
        ch_pacbio | UNZIP | PACBIO
        
        // Handle ONT samples
        ch_ont | UNZIP | ONT

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
