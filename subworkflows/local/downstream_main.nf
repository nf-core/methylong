/*
===========================================
 * Import subworkflows
===========================================
 */

include { SNVCALL_CLAIR3                   } from './shared_snvcall_clair3/main'
include { GUNZIP_AWK                       } from './shared_gunzip_awk/main'
include { WHATSHAP                         } from './shared_whatshap/main'
include { MODKIT_DMR_HAPLOTYPE_LEVEL       } from './shared_modkit_dmr_haplotype_level/main'
include { DSS_HAPLOTYPE_LEVEL              } from './shared_dss_haplotype_level/main'
include { MODKIT_DMR_POPULATION_SCALE      } from './shared_modkit_dmr_population_scale/main'
include { DSS_DMR_POPULATION_SCALE         } from './shared_dss_population_scale/main'

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

            if (params.haplotype_dmrer=='modkit') {

                MODKIT_DMR_HAPLOTYPE_LEVEL(WHATSHAP.out.ch_whatshap_out)

                versions = versions.mix(MODKIT_DMR_HAPLOTYPE_LEVEL.out.versions)

            }

            else {
                // default setting when dmrer is dss

                DSS_HAPLOTYPE_LEVEL(WHATSHAP.out.ch_whatshap_out)

                versions = versions.mix(DSS_HAPLOTYPE_LEVEL.out.versions)

            }

        }

        if (params.dmr_population_scale) {

            if (!params.dmr_a || !params.dmr_b) {
                error "When --dmr_population_scale is enabled, both --dmr_a and --dmr_b must be specified"
            }

            if (params.population_dmrer == 'modkit') {

                MODKIT_DMR_POPULATION_SCALE(pileups)

                versions = versions.mix(MODKIT_DMR_POPULATION_SCALE.out.versions)

            }

            else {
                // default setting when dmrer is dss

                DSS_DMR_POPULATION_SCALE(pileups)

                versions = versions.mix(DSS_DMR_POPULATION_SCALE.out.versions)

            }

        }

    emit:
    versions
}
