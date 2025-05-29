/*
===========================================
 * Import subworkflows
===========================================
 */

include { ONT_ALIGN                        } from './ont_align/main'
include { ONT_TRIM_REPAIR                  } from './ont_trim_repair/main'
include { BED2BEDGRAPH                     } from './shared_bed2bedgraph/main'
include { INDEX_MODKIT_PILEUP              } from './shared_modkit_pileup/main'
include { SNVCALL_CLAIR3                   } from './shared_snvcall_clair3/main'
include { GUNZIP_AWK                       } from './shared_gunzip_awk/main'
include { WHATSHAP                         } from './shared_whatshap/main'

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

        SNVCALL_CLAIR3(ONT_ALIGN.out.ch_pile_in)
        ont_versions = ont_versions.mix(SNVCALL_CLAIR3.out.versions)

        GUNZIP_AWK(SNVCALL_CLAIR3.out.ch_clair3_out)
        ont_versions = ont_versions.mix(GUNZIP_AWK.out.versions)

        WHATSHAP(GUNZIP_AWK.out.ch_awk_out)
        ont_versions = ont_versions.mix(WHATSHAP.out.versions)

    }

    emit:
    ont_versions
    map_stat
}
