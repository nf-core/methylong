/*
===========================================
 * Import modules
===========================================
 */

include { CCSMETH_CALLMODS                 } from '../../modules/local/ccsmeth/callmods/main'
include { CCSMETH_CALLFREQB                } from '../../modules/local/ccsmeth/callfreqb/main'
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

/*
===========================================
 * PacBio Workflows
===========================================
 */

workflow PACBIO {
    take:
    ch_input

    main:

    pacbio_versions = channel.empty()
    map_stat        = channel.empty()

    input = channel.empty()

    // modcall

    if (params.pacbio_modcall){

        ch_input
                .map { meta, bam, _ref -> [meta, bam] }
                .set { ch_bam_in }

        if (params.pacbio_modcaller == "ccsmeth") {

            CCSMETH_CALLMODS(ch_bam_in)
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

    map_stat = map_stat.mix(FASTQ_UNZIP.out.fastqc_log.collect { it[1] }.ifEmpty([]))

    FASTQ_UNZIP.out.unzip_input.set{ input }


    // alignment
    if (params.pacbio_aligner == 'minimap2') {

        PACBIO_ALIGN_MINI(input)
        ch_pile_in = PACBIO_ALIGN_MINI.out.ch_pile_in
        map_stat = PACBIO_ALIGN_MINI.out.flagstat_out

    } else {

        PACBIO_ALIGN_PBMM2(input)
        ch_pile_in = PACBIO_ALIGN_PBMM2.out.ch_pile_in
        pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_PBMM2.out.versions)
        map_stat = PACBIO_ALIGN_PBMM2.out.flagstat_out

    }

    // pileup
    if (params.pileup_method == 'modkit') {

        INDEX_MODKIT_PILEUP(ch_pile_in)
        ch_bg_in = INDEX_MODKIT_PILEUP.out.pileup_out

    } else {

        PACBIO_SPLIT_STRAND_PBCPG_PILEUP(ch_pile_in)
        ch_bg_in = PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.pile_out
    }

    // bed to bedgraph conversion
     if (params.bedgraph) {

        BED2BEDGRAPH(ch_bg_in)
    }

    // use ccsmeth
    if (params.pacbio_modcaller == 'ccsmeth') {

        ch_pile_in
            .multiMap { meta, bam, _bai, ref ->
                bam_in: [meta, bam]
                ref_in: [meta, ref]
            }
            .set { ch_ccsmeth_in }

        CCSMETH_CALLFREQB(
            ch_ccsmeth_in.bam_in,
            ch_ccsmeth_in.ref_in
        )
    }

    // fiberseq
    if (params.fiberseq) {

        PACBIO_FIBERSEQ(ch_pile_in)
        pacbio_versions = pacbio_versions.mix(PACBIO_FIBERSEQ.out.versions)
    }


    emit:
    ch_pile_in
    pacbio_versions
    map_stat
}
