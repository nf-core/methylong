/*
===========================================
 * Import processes from modules
===========================================
 */

include { WHATSHAP_PHASE    } from '../../../modules/local/whatshap/phase/main'
include { WHATSHAP_HAPLOTAG } from '../../../modules/local/whatshap/haplotag/main'
include { TABIX_TABIX  as TABIX_TABIX_PHASE  } from '../../../modules/nf-core/tabix/tabix/main'
include { SAMTOOLS_INDEX as SAMTOOLS_INDEX_PHASE } from '../../../modules/nf-core/samtools/index/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow WHATSHAP {
    take:
    input

    main:

    // Prepare inputs for whatshap

    input
        .multiMap { meta, bam, bai, ref, fai, vcf ->
                bam_in: [meta, bam, bai]
                ref_in: [meta, ref, fai]
                vcf_in: [meta, vcf]
        }
        .set { ch_input }

    // WhatsHap phase
    WHATSHAP_PHASE(ch_input.bam_in, ch_input.ref_in, ch_input.vcf_in )

    TABIX_TABIX_PHASE(WHATSHAP_PHASE.out.vcfgz)

    // join inputs before piping into whatshap_haplotag
    input
        .join(WHATSHAP_PHASE.out.vcfgz)
        .join(TABIX_TABIX_PHASE.out.index)
        .multiMap { meta, bam, bai, ref, fai, _vcf, vcfgz, tbi ->
                bam_in: [meta, bam, bai]
                ref_in: [meta, ref, fai]
                phase_in: [meta, vcfgz, tbi]
        }
        .set {ch_haplotag }

    // WhatsHap haplotag
    WHATSHAP_HAPLOTAG(ch_haplotag.bam_in, ch_haplotag.ref_in, ch_haplotag.phase_in)

    SAMTOOLS_INDEX_PHASE(WHATSHAP_HAPLOTAG.out.bam)

    input
        .join(WHATSHAP_HAPLOTAG.out.bam)
        .join(SAMTOOLS_INDEX_PHASE.out.index)
        .map { meta, _bam, _bai, ref, fai, _vcf, newbam, index -> [meta, newbam, index, ref, fai] }
        .set { ch_whatshap_out }

    emit:
    ch_whatshap_out
}
