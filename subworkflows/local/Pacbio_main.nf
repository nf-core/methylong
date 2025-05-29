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
include { SNVCALL_CLAIR3                   } from './shared_snvcall_clair3/main'
include { GUNZIP_AWK                       } from './shared_gunzip_awk/main'
include { WHATSHAP                         } from './shared_whatshap/main'

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
        if (params.bedgraph) {

            PACBIO_ALIGN_MINI(input)

            pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_MINI.out.versions)
            map_stat = PACBIO_ALIGN_MINI.out.flagstat_out

            INDEX_MODKIT_PILEUP(PACBIO_ALIGN_MINI.out.ch_pile_in)

            pacbio_versions = pacbio_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            pacbio_versions = pacbio_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            PACBIO_ALIGN_MINI(input)

            pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_MINI.out.versions)
            map_stat = PACBIO_ALIGN_MINI.out.flagstat_out

            INDEX_MODKIT_PILEUP(PACBIO_ALIGN_MINI.out.ch_pile_in)

            pacbio_versions = pacbio_versions.mix(INDEX_MODKIT_PILEUP.out.versions)
        }

        SNVCALL_CLAIR3(PACBIO_ALIGN_MINI.out.ch_pile_in)
        pacbio_versions = pacbio_versions.mix(SNVCALL_CLAIR3.out.versions)

        GUNZIP_AWK(SNVCALL_CLAIR3.out.ch_clair3_out)
        pacbio_versions = pacbio_versions.mix(GUNZIP_AWK.out.versions)

        WHATSHAP(GUNZIP_AWK.out.ch_awk_out)
        pacbio_versions = pacbio_versions.mix(WHATSHAP.out.versions)

    }
    else if (params.pacbio_aligner == "pbmm2" && params.pileup_method == "modkit") {

        if (params.bedgraph) {

            PACBIO_ALIGN_PBMM2(input)

            pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_PBMM2.out.versions)
            map_stat = PACBIO_ALIGN_PBMM2.out.flagstat_out

            INDEX_MODKIT_PILEUP(PACBIO_ALIGN_PBMM2.out.ch_pile_in)

            pacbio_versions = pacbio_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            pacbio_versions = pacbio_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            PACBIO_ALIGN_PBMM2(input)

            pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_PBMM2.out.versions)
            map_stat = PACBIO_ALIGN_PBMM2.out.flagstat_out


            INDEX_MODKIT_PILEUP(PACBIO_ALIGN_PBMM2.out.ch_pile_in)

            pacbio_versions = pacbio_versions.mix(INDEX_MODKIT_PILEUP.out.versions)
        }

        SNVCALL_CLAIR3(PACBIO_ALIGN_PBMM2.out.ch_pile_in)
        pacbio_versions = pacbio_versions.mix(SNVCALL_CLAIR3.out.versions)


        GUNZIP_AWK(SNVCALL_CLAIR3.out.ch_clair3_out)
        pacbio_versions = pacbio_versions.mix(GUNZIP_AWK.out.versions)

        WHATSHAP(GUNZIP_AWK.out.ch_awk_out)
        pacbio_versions = pacbio_versions.mix(WHATSHAP.out.versions)

    }
    else if (params.pacbio_aligner == "minimap2" && params.pileup_method == "pbcpgtools") {

        if (params.bedgraph) {

            PACBIO_ALIGN_MINI(input)

            pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_MINI.out.versions)
            map_stat = PACBIO_ALIGN_MINI.out.flagstat_out

            PACBIO_SPLIT_STRAND_PBCPG_PILEUP(PACBIO_ALIGN_MINI.out.ch_pile_in)

            pacbio_versions = pacbio_versions.mix(PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.versions)

            BED2BEDGRAPH(PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.pile_out)

            pacbio_versions = pacbio_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            PACBIO_ALIGN_MINI(input)

            pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_MINI.out.versions)
            map_stat = PACBIO_ALIGN_MINI.out.flagstat_out

            PACBIO_SPLIT_STRAND_PBCPG_PILEUP(PACBIO_ALIGN_MINI.out.ch_pile_in)

            pacbio_versions = pacbio_versions.mix(PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.versions)
        }

        SNVCALL_CLAIR3(PACBIO_ALIGN_MINI.out.ch_pile_in)
        pacbio_versions = pacbio_versions.mix(SNVCALL_CLAIR3.out.versions)

        GUNZIP_AWK(SNVCALL_CLAIR3.out.ch_clair3_out)
        pacbio_versions = pacbio_versions.mix(GUNZIP_AWK.out.versions)

        WHATSHAP(GUNZIP_AWK.out.ch_awk_out)
        pacbio_versions = pacbio_versions.mix(WHATSHAP.out.versions)
    }
    else {

        // default setting when aligner is pbmm2 and pileup method is pbcpgtools
        if (params.bedgraph) {

            PACBIO_ALIGN_PBMM2(input)

            pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_PBMM2.out.versions)
            map_stat = PACBIO_ALIGN_PBMM2.out.flagstat_out

            PACBIO_SPLIT_STRAND_PBCPG_PILEUP(PACBIO_ALIGN_PBMM2.out.ch_pile_in)

            pacbio_versions = pacbio_versions.mix(PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.versions)

            BED2BEDGRAPH(PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.pile_out)

            pacbio_versions = pacbio_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            PACBIO_ALIGN_PBMM2(input)

            pacbio_versions = pacbio_versions.mix(PACBIO_ALIGN_PBMM2.out.versions)
            map_stat = PACBIO_ALIGN_PBMM2.out.flagstat_out


            PACBIO_SPLIT_STRAND_PBCPG_PILEUP(PACBIO_ALIGN_PBMM2.out.ch_pile_in)

            pacbio_versions = pacbio_versions.mix(PACBIO_SPLIT_STRAND_PBCPG_PILEUP.out.versions)
        }

        SNVCALL_CLAIR3(PACBIO_ALIGN_PBMM2.out.ch_pile_in)
        pacbio_versions = pacbio_versions.mix(SNVCALL_CLAIR3.out.versions)

        GUNZIP_AWK(SNVCALL_CLAIR3.out.ch_clair3_out)
        pacbio_versions = pacbio_versions.mix(GUNZIP_AWK.out.versions)

        WHATSHAP(GUNZIP_AWK.out.ch_awk_out)
        pacbio_versions = pacbio_versions.mix(WHATSHAP.out.versions)

    }

    emit:
    pacbio_versions
    map_stat
}
