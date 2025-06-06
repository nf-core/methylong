/*
===========================================
 * Import subworkflows
===========================================
 */

include { SNVCALL_CLAIR3                   } from './shared_snvcall_clair3/main'
include { GUNZIP_AWK                       } from './shared_gunzip_awk/main'
include { WHATSHAP                         } from './shared_whatshap/main'

/*
===========================================
 * Downstream Workflows
===========================================
 */


workflow DOWNSTREAM {
    take:
    pileups
    versions

    main:

        if (!params.skip_snvs) {
            SNVCALL_CLAIR3(pileups)
            versions = versions.mix(SNVCALL_CLAIR3.out.versions)

            GUNZIP_AWK(SNVCALL_CLAIR3.out.ch_clair3_out)
            versions = versions.mix(GUNZIP_AWK.out.versions)

            WHATSHAP(GUNZIP_AWK.out.ch_awk_out)
            versions = versions.mix(WHATSHAP.out.versions)
        }

    emit:
    versions
}
