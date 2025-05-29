/*
===========================================
 * Import processes from modules
===========================================
 */

include { WHATSHAP_PHASE    } from '../../../modules/local/whatshap/phase/main'
include { WHATSHAP_HAPLOTAG } from '../../../modules/local/whatshap/haplotag/main'
include { TABIX_BGZIPTABIX  } from '../../../modules/nf-core/tabix/bgziptabix/main'
include { SAMTOOLS_INDEX } from '../../../modules/nf-core/samtools/index/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow WHATSHAP {
    take:
    input

    main:

    versions = Channel.empty()

    // Prepare inputs for whatshap

    input
        .map { meta, bam, bai, _ref, _fai, _vcf -> [meta, bam, bai] }
        .set { ch_bam_in }

    input
        .map { meta, _bam, _bai, ref, fai, _vcf -> [meta, ref, fai] }
        .set { ch_ref }

    input
        .map { meta, _bam, _bai, _ref, _fai, vcf -> [meta, vcf] }
        .set { ch_vcf }

    // WhatsHap phase
    WHATSHAP_PHASE(ch_bam_in, ch_ref, ch_vcf )

    versions = versions.mix(WHATSHAP_PHASE.out.versions.first())

    TABIX_BGZIPTABIX(WHATSHAP_PHASE.out.vcf)

    versions = versions.mix(TABIX_BGZIPTABIX.out.versions.first())

    // WhatsHap haplotag
    WHATSHAP_HAPLOTAG(ch_bam_in, ch_ref, TABIX_BGZIPTABIX.out.gz_tbi)

    versions = versions.mix(WHATSHAP_HAPLOTAG.out.versions.first())

    SAMTOOLS_INDEX(WHATSHAP_HAPLOTAG.out.bam)

    versions = versions.mix(SAMTOOLS_INDEX.out.versions.first())

    input
        .join(WHATSHAP_HAPLOTAG.out.bam)
        .join(SAMTOOLS_INDEX.out.bai)
        .map { meta, _bam, _bai, ref, fai, _vcf, newbam, newbai -> [meta, newbam, newbai, ref, fai] }
        .set { ch_whatshap_out }

    emit:
    ch_whatshap_out
    versions
}
