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

    main:

        if (!params.skip_snvs) {

            SNVCALL_CLAIR3(pileups)

            GUNZIP_AWK(SNVCALL_CLAIR3.out.ch_clair3_out)

            WHATSHAP(GUNZIP_AWK.out.ch_awk_out)

            if (params.haplotype_dmrer=='modkit' || params.all_contexts) {

                MODKIT_DMR_HAPLOTYPE_LEVEL(WHATSHAP.out.ch_whatshap_out)
            }

            else {
                // default setting when dmrer is dss

                DSS_HAPLOTYPE_LEVEL(WHATSHAP.out.ch_whatshap_out)

            }

        }

        if (params.dmr_population_scale) {

            if (!params.dmr_a || !params.dmr_b) {
                error "When --dmr_population_scale is enabled, both --dmr_a and --dmr_b must be specified"
            }

            if (params.population_dmrer == 'modkit' || params.all_contexts) {

                MODKIT_DMR_POPULATION_SCALE(pileups, params.dmr_a, params.dmr_b)

            }

            else {
                // default setting when dmrer is dss

                DSS_DMR_POPULATION_SCALE(pileups, params.dmr_a, params.dmr_b)

            }

        }

}
