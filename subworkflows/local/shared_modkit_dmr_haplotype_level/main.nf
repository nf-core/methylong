/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_PILEUP as MODKIT_PILEUP_HAPLOTYPE_LEVEL } from '../../../modules/nf-core/modkit/pileup/main'
include { MODKIT_DMR    as DMR_HAPLOTYPE_LEVEL           } from '../../../modules/local/modkit/dmr/main'
include { TABIX_BGZIPTABIX as TABIX_BGZIPTABIX_1         } from '../../../modules/nf-core/tabix/bgziptabix/main'
include { TABIX_BGZIPTABIX as TABIX_BGZIPTABIX_2         } from '../../../modules/nf-core/tabix/bgziptabix/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow MODKIT_DMR_HAPLOTYPE_LEVEL {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .multiMap { meta, bam, bai, ref, fai  ->
                bam_in: [meta, bam, bai]
                ref_in: [meta, ref, fai]
        }
        .set { ch_input }

    // Modkit pileup
    MODKIT_PILEUP_HAPLOTYPE_LEVEL(ch_input.bam_in, ch_input.ref_in, [[], []])

    versions = versions.mix(MODKIT_PILEUP_HAPLOTYPE_LEVEL.out.versions.first())

    MODKIT_PILEUP_HAPLOTYPE_LEVEL.out.bed
        .flatMap { meta, files ->
            files.collect { file ->
                [meta, file]
            }
        }
        .set { pileup_out }

    // segment haplotype bed files
    bed_hp1 = pileup_out.filter { _meta, file -> file.toString().endsWith('_1.bed') }

    bed_hp2 = pileup_out.filter { _meta, file -> file.toString().endsWith('_2.bed') }

    // bgzip and tabix
    TABIX_BGZIPTABIX_1(bed_hp1)

    versions = versions.mix(TABIX_BGZIPTABIX_1.out.versions.first())

    TABIX_BGZIPTABIX_2(bed_hp2)

    versions = versions.mix(TABIX_BGZIPTABIX_2.out.versions.first())

    TABIX_BGZIPTABIX_1.out.gz_tbi.set { bed_hp1_gz }

    TABIX_BGZIPTABIX_2.out.gz_tbi.set { bed_hp2_gz }

    // Merge bed files with the same [meta]
    bed_hp1_gz
        .join(bed_hp2_gz)
        .join(ch_input.ref_in)
        .multiMap { meta, bed1, tbi1, bed2, tbi2, ref, fai ->
                bed_hp1_gz: [meta, bed1, tbi1]
                bed_hp2_gz: [meta, bed2, tbi2]
                ch_ref: [meta, ref, fai]
        }
        .set { bed }

    // Modkit dmr
    DMR_HAPLOTYPE_LEVEL( bed.bed_hp1_gz, bed.bed_hp2_gz, bed.ch_ref )

    versions = versions.mix(DMR_HAPLOTYPE_LEVEL.out.versions.first())

    DMR_HAPLOTYPE_LEVEL.out.bed.set { dmr_out }

    emit:
    pileup_out
    dmr_out
    versions
}
