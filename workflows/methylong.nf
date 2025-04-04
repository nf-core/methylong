/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { PACBIO                 } from '../subworkflows/local/pacbio/main'
include { ONT                    } from '../subworkflows/local/ont/main'
include { UNZIP                  } from '../subworkflows/local/shared/unzip/main'
include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_methylong_pipeline'
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

        ch_versions = Channel.empty()
        ch_multiqc_files = Channel.empty()

        //
        // MODULE: Run FastQC
        //
            ch_samples
                .map { meta, modbam, _ref -> [meta, modbam] }
                .set { fastqc_in }

            FASTQC (
                fastqc_in
            )

        ch_versions    = ch_versions.mix(FASTQC.out.versions)
        ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect { it[1] }.ifEmpty([]))

        // Split the channel based on method
        
        UNZIP(ch_samples)

        ch_versions    = ch_versions.mix(UNZIP.out.gz_version)

        UNZIP.out.unzip_input
                 .filter {  it[0].method == "pacbio" }
                 .set {ch_pacbio}

        UNZIP.out.unzip_input
                 .filter {  it[0].method == "ont" }
                 .set {ch_ont}


        // different workflow depending on data type 
        
        PACBIO(ch_pacbio)

        ch_versions = ch_versions.mix(PACBIO.out.pacbio_versions)
        ch_multiqc_files = ch_multiqc_files.mix(PACBIO.out.map_stat.collect { it[1] }.ifEmpty([]))
        
        ONT(ch_ont)

        ch_versions = ch_versions.mix(ONT.out.ont_versions)
        ch_multiqc_files = ch_multiqc_files.mix(ONT.out.map_stat.collect { it[1] }.ifEmpty([]))


        //
        // Collate and save software versions
        //



        softwareVersionsToYAML(ch_versions)
            .collectFile(
                storeDir: "${params.outdir}/pipeline_info",
                name: 'nf_core_'  + 'pipeline_software_' +  'mqc_'  + 'versions.yml',
                sort: true,
                newLine: true
            ).set { ch_collated_versions }


        //
        // MODULE: MultiQC
        //
        ch_multiqc_config        = Channel.fromPath(
            "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
        ch_multiqc_custom_config = params.multiqc_config ?
            Channel.fromPath(params.multiqc_config, checkIfExists: true) :
            Channel.empty()
        ch_multiqc_logo          = params.multiqc_logo ?
            Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
            Channel.empty()

        summary_params      = paramsSummaryMap(
            workflow, parameters_schema: "nextflow_schema.json")
        ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))
        ch_multiqc_files = ch_multiqc_files.mix(
            ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
        ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
            file(params.multiqc_methods_description, checkIfExists: true) :
            file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
        ch_methods_description                = Channel.value(
            methodsDescriptionText(ch_multiqc_custom_methods_description))

        ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
        ch_multiqc_files = ch_multiqc_files.mix(
            ch_methods_description.collectFile(
                name: 'methods_description_mqc.yaml',
                sort: true
            )
        )

        MULTIQC (
            ch_multiqc_files.collect(),
            ch_multiqc_config.toList(),
            ch_multiqc_custom_config.toList(),
            ch_multiqc_logo.toList(),
            [],
            []
        )

        emit:multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
        versions       = ch_versions                 // channel: [ path(versions.yml) ]

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