/*
===========================================
 * Import subworkflows
===========================================
 */

include { ONT_ALIGN                        } from './ont_align/main'
include { ONT_TRIM_REPAIR                  } from './ont_trim_repair/main'
include { BED2BEDGRAPH                     } from './shared_bed2bedgraph/main'
include { INDEX_MODKIT_PILEUP              } from './shared_modkit_pileup/main'
include { DOWNSTREAM                       } from './downstream_main'

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

            ch_pile_in = ONT_ALIGN.out.ch_pile_in
            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)
            ch_pile_in = ONT_ALIGN.out.ch_pile_in

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            ont_versions = ont_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            ONT_ALIGN(ch_ont)

            ch_pile_in = ONT_ALIGN.out.ch_pile_in
            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)
            ch_pile_in = ONT_ALIGN.out.ch_pile_in

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)
        }
    }
    else {
        if (params.bedgraph) {

            ONT_TRIM_REPAIR(ch_ont)

            ont_versions = ont_versions.mix(ONT_TRIM_REPAIR.out.versions)

            ONT_ALIGN(ONT_TRIM_REPAIR.out.dorado_in)

            ch_pile_in = ONT_ALIGN.out.ch_pile_in
            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)
            ch_pile_in = ONT_ALIGN.out.ch_pile_in

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            ont_versions = ont_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            ONT_TRIM_REPAIR(ch_ont)

            ont_versions = ont_versions.mix(ONT_TRIM_REPAIR.out.versions)

            ONT_ALIGN(ONT_TRIM_REPAIR.out.dorado_in)

            ch_pile_in = ONT_ALIGN.out.ch_pile_in
            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)
        }
    }

    DOWNSTREAM(ch_pile_in, ont_versions)

    emit:
    ont_versions
    map_stat
}
