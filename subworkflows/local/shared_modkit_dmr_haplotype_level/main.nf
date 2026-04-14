/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_PILEUP as MODKIT_PILEUP_HAPLOTYPE_LEVEL } from '../../../modules/nf-core/modkit/pileup/main'
include { MODKIT_DMRPAIR    as DMR_HAPLOTYPE_LEVEL       } from '../../../modules/local/modkit/dmrpair/main'
include { TABIX_TABIX as TABIX_TABIX_1                   } from '../../../modules/nf-core/tabix/tabix/main'
include { TABIX_TABIX as TABIX_TABIX_2                   } from '../../../modules/nf-core/tabix/tabix/main'

/*
===========================================
 * Workflows
===========================================
 */

workflow MODKIT_DMR_HAPLOTYPE_LEVEL {
    take:
    input

    main:

    input
        .multiMap { meta, bam, bai, ref, fai  ->
                bam_in: [meta, bam, bai]
                ref_in: [meta, ref, fai]
        }
        .set { ch_input }

    // Modkit pileup
    MODKIT_PILEUP_HAPLOTYPE_LEVEL(ch_input.bam_in, ch_input.ref_in, [[], []])

    MODKIT_PILEUP_HAPLOTYPE_LEVEL.out.bedgz
        .flatMap { meta, files ->
            files.collect { file ->
                [meta, file]
            }
        }
        .set { pileup_out }

    // segment haplotype bed files
    bed_hp1 = pileup_out.filter { _meta, file -> file.toString().endsWith('_1.bed.gz') }

    bed_hp2 = pileup_out.filter { _meta, file -> file.toString().endsWith('_2.bed.gz') }

    //tabix
    TABIX_TABIX_1(bed_hp1)

    TABIX_TABIX_2(bed_hp2)

    bed_hp1
    .join(TABIX_TABIX_1.out.index)
    .map { meta, bedgz, index -> [meta, bedgz, index] }
    .set { bed_hp1_gz }

    bed_hp2
    .join(TABIX_TABIX_2.out.index)
    .map { meta, bedgz, index -> [meta, bedgz, index] }
    .set { bed_hp2_gz }

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

    DMR_HAPLOTYPE_LEVEL.out.bedgz.set { dmr_out }

    emit:
    pileup_out
    dmr_out
}
