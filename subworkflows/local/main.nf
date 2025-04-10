/*
===========================================
 * Import subworkflows
===========================================
 */

include { ONT_ALIGN                        } from './ont_align/main'
include { ONT_TRIM_REPAIR                  } from './ont_trim_repair/main'
include { PACBIO_ALIGN_MINI                } from './pacbio_align_minimap2/main'
include { PACBIO_ALIGN_PBMM2               } from './pacbio_align_pbmm2/main'
include { PACBIO_SPLIT_STRAND_PBCPG_PILEUP } from './pacbio_split_strand_pbcpg_pileup/main'
include { BED2BEDGRAPH                     } from './shared_bed2bedgraph/main'
include { INDEX_MODKIT_PILEUP              } from './shared_modkit_pileup/main'


/*
===========================================
 * ONT Workflows
===========================================
 */


workflow ONT {
    take:
    ch_ont

    main:

    ont_versions = Channel.empty()

    if (params.no_trim) {
        if (params.bedgraph) {

            ONT_ALIGN(ch_ont)

            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            ont_versions = ont_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            ONT_ALIGN(ch_ont)

            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)
        }
    }
    else {
        if (params.bedgraph) {

            ONT_TRIM_REPAIR(ch_ont)

            ont_versions = ont_versions.mix(ONT_TRIM_REPAIR.out.versions)

            ONT_ALIGN(ONT_TRIM_REPAIR.out.dorado_in)

            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            ont_versions = ont_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            ONT_TRIM_REPAIR(ch_ont)

            ont_versions = ont_versions.mix(ONT_TRIM_REPAIR.out.versions)

            ONT_ALIGN(ONT_TRIM_REPAIR.out.dorado_in)

            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)
        }
    }

    emit:
    ont_versions
    map_stat
}

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
    if (params.aligner == "minimap2" && params.pileup_method == "modkit") {
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
    }
    else if (params.aligner == "pbmm2" && params.pileup_method == "modkit") {

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
    }
    else if (params.aligner == "minimap2" && params.pileup_method == "pbcpgtools") {

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
    }

    emit:
    pacbio_versions
    map_stat
}
