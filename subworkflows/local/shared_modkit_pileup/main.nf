/*
===========================================
 * Import processes from modules
===========================================
 */


include { MODKIT_PILEUP                      } from '../../../modules/nf-core/modkit/pileup/main'
include { MODKIT_PILEUP as MODKIT_PILEUP_6mA } from '../../../modules/nf-core/modkit/pileup/main'
include { SAMTOOLS_FAIDX                     } from '../../../modules/nf-core/samtools/faidx/main'
include { TABIX_TABIX                   } from '../../../modules/nf-core/tabix/tabix/main'
include { TABIX_TABIX       as     TABIX_TABIX_6MA       } from '../../../modules/nf-core/tabix/tabix/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow INDEX_MODKIT_PILEUP {
    take:
    input

    main:

    pileup_6mA_out = channel.empty()

    // Prepare inputs for pileup

    input
        .map { meta, _bam, _bai, ref -> [meta, ref, []] }
        .set { ch_ref_in }

    // Index ref
    SAMTOOLS_FAIDX(ch_ref_in, [])

    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .map { meta, bam, bai, _ref, _fai -> [meta, bam, bai] }
        .set { ch_bam_in }

    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .map { meta, _bam, _bai, ref, fai -> [meta, ref, fai] }
        .set { ch_index_ref }


    // Modkit pileup
   if (params.m6a) {
        MODKIT_PILEUP_6mA(ch_bam_in, ch_index_ref, [[], []])

        MODKIT_PILEUP_6mA.out.bedgz.set { pileup_6mA_out }
        TABIX_TABIX_6MA(MODKIT_PILEUP_6mA.out.bedgz)
    }

    MODKIT_PILEUP(ch_bam_in, ch_index_ref, [[], []])

    MODKIT_PILEUP.out.bedgz.set { pileup_out }
    TABIX_TABIX(MODKIT_PILEUP.out.bedgz)


    emit:
    pileup_6mA_out
    pileup_out
}
