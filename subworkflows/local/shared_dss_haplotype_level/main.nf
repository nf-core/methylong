/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_PILEUP as MODKIT_PILEUP_HAPLOTYPE_LEVEL } from '../../../modules/nf-core/modkit/pileup/main'
include { DSS                                            } from '../../../modules/local/dss/main'
include { GAWK   as GAWK_1                               } from '../../../modules/nf-core/gawk/main'
include { GAWK   as GAWK_2                               } from '../../../modules/nf-core/gawk/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow DSS_HAPLOTYPE_LEVEL {
    take:
    input

    main:

    input
        .map { meta, bam, bai, _ref, _fai -> [meta, bam, bai] }
        .set { ch_bam_in }

    input
        .map { meta, _bam, _bai, ref, fai -> [meta, ref, fai] }
        .set { ch_ref }

    // Modkit pileup
    MODKIT_PILEUP_HAPLOTYPE_LEVEL(ch_bam_in, ch_ref, [[], []])

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

    // awk

    GAWK_1(bed_hp1, [], [])
    GAWK_1.out.output.set { bed_preprocessed_1 }

    GAWK_2(bed_hp2, [], [])
    GAWK_2.out.output.set { bed_preprocessed_2 }

    bed_preprocessed_1
        .join(bed_preprocessed_2)
        .multiMap { meta, bed1, bed2 ->
            bed_preprocessed_1: [meta, bed1]
            bed_preprocessed_2: [meta, bed2]
        }
        .set { bed }

    // // DSS dmr
    DSS( bed.bed_preprocessed_1, bed.bed_preprocessed_2 )

    DSS.out.txt.set { dmr_out }

    emit:
    pileup_out
    dmr_out
}
