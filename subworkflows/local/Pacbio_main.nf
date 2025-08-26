/*
===========================================
 * Import subworkflows
===========================================
 */

include { FASTQ_UNZIP                      } from './shared_fastqc_unzip/main'
include { PACBIO_ALIGN_MINI                } from './pacbio_align_minimap2/main'
include { PACBIO_ALIGN_PBMM2               } from './pacbio_align_pbmm2/main'
include { PACBIO_SPLIT_STRAND_PBCPG_PILEUP } from './pacbio_split_strand_pbcpg_pileup/main'
include { BED2BEDGRAPH                     } from './shared_bed2bedgraph/main'
include { INDEX_MODKIT_PILEUP              } from './shared_modkit_pileup/main'
include { PACBIO_MODCALL_JASMINE           } from './pacbio_modcall_jasmine/main'
include { PACBIO_MODCALL_CCSMETH           } from './pacbio_modcall_ccsmeth/main'
include { PACBIO_M6ACALL                   } from './pacbio_m6acall/main'
include { SHARED_FIBERTOOLS_EXTRACT        } from './shared_fibertools_extract/main'

/*
===========================================
 * PacBio Workflows
===========================================
 */

workflow PACBIO {
    take:
    ch_input

    main:

    pacbio_versions = Channel.empty()
    map_stat        = Channel.empty()

    input = Channel.empty()

    // modcall

    if (params.pacbio_modcall){

        if (params.pacbio_modcaller == "ccsmeth") {

            PACBIO_MODCALL_CCSMETH(ch_input)

            pacbio_versions = pacbio_versions.mix(PACBIO_MODCALL_CCSMETH.out.versions)

            PACBIO_MODCALL_CCSMETH.out.ch_pile_in.set{ input_modbam }

        } else {

            // default modcaller is jasmine

            PACBIO_MODCALL_JASMINE(ch_input)

            pacbio_versions = pacbio_versions.mix(PACBIO_MODCALL_JASMINE.out.versions)

            PACBIO_MODCALL_JASMINE.out.ch_pile_in.set{ input_modbam }

        }

    }

    // m6acall

    if (params.m6a) {

        if (params.pacbio_modcall) {

            PACBIO_M6ACALL(input_modbam)

        } else {

            PACBIO_M6ACALL(ch_input)

        }

        pacbio_versions = pacbio_versions.mix(PACBIO_M6ACALL.out.versions)

        PACBIO_M6ACALL.out.ch_modbam.set{ input_modbam }

    }

    if (!params.pacbio_modcall && !params.m6a) {
        ch_input.set { input_modbam }
    }

    // fastq and gunzip

    FASTQ_UNZIP(input_modbam)

    pacbio_versions = pacbio_versions.mix(FASTQ_UNZIP.out.versions)
    map_stat = map_stat.mix(FASTQ_UNZIP.out.fastqc_log.collect { it[1] }.ifEmpty([]))

    FASTQ_UNZIP.out.unzip_input.set{ input }


    // Case when aligner is minimap2 and pileup method is modkit
    if (params.pacbio_aligner == "minimap2" && params.pileup_method == "modkit") {

        PACBIO_ALIGN_MINI(input)

        ch_pile_in = PACBIO_ALIGN_MINI.out.ch_pile_in
        pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_MINI.out.versions)
        map_stat = PACBIO_ALIGN_MINI.out.flagstat_out

        INDEX_MODKIT_PILEUP(PACBIO_ALIGN_MINI.out.ch_pile_in)

        pacbio_versions = pacbio_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

        if (params.bedgraph) {

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            pacbio_versions = pacbio_versions.mix(BED2BEDGRAPH.out.versions)
        }

    }
    else if (params.pacbio_aligner == "pbmm2" && params.pileup_method == "modkit") {

        PACBIO_ALIGN_PBMM2(input)

        ch_pile_in = PACBIO_ALIGN_PBMM2.out.ch_pile_in
        pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_PBMM2.out.versions)
        map_stat = PACBIO_ALIGN_PBMM2.out.flagstat_out

        INDEX_MODKIT_PILEUP(PACBIO_ALIGN_PBMM2.out.ch_pile_in)

        pacbio_versions = pacbio_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

        if (params.bedgraph) {

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            pacbio_versions = pacbio_versions.mix(BED2BEDGRAPH.out.versions)
        }

    }
    else if (params.pacbio_aligner == "minimap2" && params.pileup_method == "pbcpgtools") {

        PACBIO_ALIGN_MINI(input)

        ch_pile_in = PACBIO_ALIGN_MINI.out.ch_pile_in
        pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_MINI.out.versions)
        map_stat = PACBIO_ALIGN_MINI.out.flagstat_out

        PACBIO_SPLIT_STRAND_PBCPG_PILEUP(PACBIO_ALIGN_MINI.out.ch_pile_in)

        pacbio_versions = pacbio_versions.mix(PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.versions)

        if (params.bedgraph) {

            BED2BEDGRAPH(PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.pile_out)

            pacbio_versions = pacbio_versions.mix(BED2BEDGRAPH.out.versions)
        }

    }
    else {

        // default setting when aligner is pbmm2 and pileup method is pbcpgtools
        PACBIO_ALIGN_PBMM2(input)

        ch_pile_in = PACBIO_ALIGN_PBMM2.out.ch_pile_in
        pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_PBMM2.out.versions)
        map_stat = PACBIO_ALIGN_PBMM2.out.flagstat_out

        PACBIO_SPLIT_STRAND_PBCPG_PILEUP(PACBIO_ALIGN_PBMM2.out.ch_pile_in)

        pacbio_versions = pacbio_versions.mix(PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.versions)

        if (params.bedgraph) {

            BED2BEDGRAPH(PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.pile_out)

            pacbio_versions = pacbio_versions.mix(BED2BEDGRAPH.out.versions)
        }

    }

    if (params.m6a) {

        SHARED_FIBERTOOLS_EXTRACT(ch_pile_in)

        pacbio_versions = pacbio_versions.mix(SHARED_FIBERTOOLS_EXTRACT.out.versions)

    }

    emit:
    ch_pile_in
    pacbio_versions
    map_stat
}
