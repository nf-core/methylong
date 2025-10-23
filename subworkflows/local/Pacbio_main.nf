/*
===========================================
 * Import modules
===========================================
 */

include { CCSMETH_CALLMODS                 } from '../../modules/local/ccsmeth/callmods/main'
include { PBJASMINE                        } from '../../modules/nf-core/pbjasmine/main'

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
include { PACBIO_FIBERSEQ                  } from './pacbio_fiberseq/main'
include { CCSMETH_CALLFREQB_PIGZ           } from './shared_ccsmeth_freqb/main'

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

        ch_input
                .map { meta, bam, _ref -> [meta, bam] }
                .set { ch_bam_in }

        if (params.pacbio_modcaller == "ccsmeth") {

            CCSMETH_CALLMODS(ch_bam_in)

            pacbio_versions = pacbio_versions.mix(CCSMETH_CALLMODS.out.versions.first())

            ch_modbam = CCSMETH_CALLMODS.out.modbam

        } else {

            // default modcaller is jasmine

            PBJASMINE(ch_bam_in)

            pacbio_versions = pacbio_versions.mix(PBJASMINE.out.versions.first())

            ch_modbam = PBJASMINE.out.bam

        }

        ch_input
            .join(ch_modbam)
            .map { meta, _bam, ref, modbam -> [meta, modbam, ref] }
            .set { input_modbam }

    } else {

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

    if (params.pacbio_modcaller == "ccsmeth") {

        CCSMETH_CALLFREQB_PIGZ(ch_pile_in)

        pacbio_versions = pacbio_versions.mix(CCSMETH_CALLFREQB_PIGZ.out.versions)

    }

    if (params.fiberseq) {

        PACBIO_FIBERSEQ(ch_pile_in)

        pacbio_versions = pacbio_versions.mix(PACBIO_FIBERSEQ.out.versions)

    }

    emit:
    ch_pile_in
    pacbio_versions
    map_stat
}
