/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { PACBIO   } from '../subworkflows/local/pacbio/main'
include { ONT      } from '../subworkflows/local/ont/main'
include { PBMM2_ALIGN } from '../modules/nf-core/pbmm2/align/main'


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


        ch_pacbio
               .map{ meta, modbam, _ref -> [meta, modbam]}
               .set{ reads_in }

        ch_pacbio
               .map{ meta, _modbam, ref -> [meta, ref]}
               .set{ ref_in }

       // ch_pacbio
       //         .map{row -> [row.id, row.ref]}
       //         .set{ ref_in }
//
       // PBMM2_ALIGN(reads_in, ref_in)
        //ch_samples.map { it[0] }
                //  .filter { it.method == "ont" }
                //  .set {ch_ont}

        // Debug: View the content of ch_pacbio and ch_ont
        reads_in.view { "${it}"}
        ref_in.view { "ref path: ${it}"}

        PBMM2_ALIGN(reads_in, ref_in)
        

        //ch_ont.view { "${it}" }

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
