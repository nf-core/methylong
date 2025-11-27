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
        .multiMap { meta, bam, bai, ref, fai, vcf ->
                bam_in: [meta, bam, bai]
                ref_in: [meta, ref, fai]
                vcf_in: [meta, vcf]
        }
        .set { ch_input }

    // WhatsHap phase
    WHATSHAP_PHASE(ch_input.bam_in, ch_input.ref_in, ch_input.vcf_in )

    versions = versions.mix(WHATSHAP_PHASE.out.versions.first())

    TABIX_BGZIPTABIX(WHATSHAP_PHASE.out.vcf)

    versions = versions.mix(TABIX_BGZIPTABIX.out.versions.first())

    // join inputs before piping into whatshap_haplotag 
    input
        .join(TABIX_BGZIPTABIX.out.gz_tbi)
        .multiMap { meta, bam, bai, ref, fai, vcf, gz, tbi ->
                bam_in: [meta, bam, bai]
                ref_in: [meta, ref, fai]
                phase_in: [meta, gz, tbi]
        }
        .set {ch_haplotag }

    // WhatsHap haplotag
    WHATSHAP_HAPLOTAG(ch_haplotag.bam_in, ch_haplotag.ref_in, ch_haplotag.phase_in)

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
