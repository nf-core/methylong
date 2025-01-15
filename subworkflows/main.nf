#!/usr/bin/env nextflow

/*
 ===========================================
 * Import subworkflows 
 ===========================================
 */

include { PACBIO } from './pacbio/main'
include { ONT } from './ont/main'

/*
 ===========================================
 * Workflows
 ===========================================
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

        // Split the channel based on method
        def (ch_pacbio, ch_ont) = ch_samples
                                  .branch { it.meta.method == "pacbio" } { true }
                                  .branch { it.meta.method == "ont" } { true }

        // Handle PacBio samples
        PACBIO(ch_pacbio)

        // Handle ONT samples
        ONT(ch_ont)

    } else {
        // Exit if no samplesheet is provided
        exit 1, 'Input samplesheet not specified!'
    }
}