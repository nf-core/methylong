/*
===========================================
 * Import processes from modules
===========================================
 */

include { CLAIR3         } from '../../../modules/nf-core/clair3/main'
include { SAMTOOLS_FAIDX } from '../../../modules/nf-core/samtools/faidx/main'

/*
===========================================
 * Workflows
===========================================
 */


workflow SNVCALL_CLAIR3 {
    take:
    input

    main:

    versions = Channel.empty()

    // Prepare inputs for clair3

    input
        .map { meta, _bam, _bai, ref -> [meta, ref] }
        .set { ch_ref_in }

    // Index ref
    SAMTOOLS_FAIDX(ch_ref_in, [[], []], [])

    versions = versions.mix(SAMTOOLS_FAIDX.out.versions.first())

    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .map { meta, bam, bai, _ref, _fai ->
        def packaged_model = meta.method ==  "ont" ? "r1041_e82_400bps_sup_v500" : "hifi_revio"
        def platform = 
            meta.method == "ont"  ? "ont" : 
            meta.method == "pacbio" ? "hifi" : error('unknown method')
        [meta, bam, bai, packaged_model, [] , platform] }
        .set { ch_bam_in }

    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .map { meta, _bam, _bai, ref, _fai -> [meta, ref] }
        .set { ch_ref }

    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .map { meta, _bam, _bai, _ref, fai -> [meta, fai] }
        .set { ch_index }

    // Clair3
    CLAIR3(ch_bam_in, ch_ref, ch_index)

    versions = versions.mix(CLAIR3.out.versions.first())

    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .join(CLAIR3.out.vcf)
        .set { ch_clair3_out }

    emit:
    ch_clair3_out
    versions
}
