/*
===========================================
 * Import subworkflows
===========================================
 */

include { PACBIO_ALIGN_MINI                } from './pacbio_align_minimap2/main'
include { PACBIO_ALIGN_PBMM2               } from './pacbio_align_pbmm2/main'
include { PACBIO_SPLIT_STRAND_PBCPG_PILEUP } from './pacbio_split_strand_pbcpg_pileup/main'
include { BED2BEDGRAPH                     } from './shared_bed2bedgraph/main'
include { INDEX_MODKIT_PILEUP              } from './shared_modkit_pileup/main'

/*
===========================================
 * PacBio Workflows
===========================================
 */

workflow PACBIO {
    take:
    input

    main:

    pacbio_versions = Channel.empty()

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

    emit:
    ch_pile_in
    pacbio_versions
    map_stat
}
