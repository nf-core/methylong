/*
===========================================
 * Import processes from modules
===========================================
 */

include { GUNZIP } from '../../../modules/nf-core/gunzip/main'
include { GAWK   } from '../../../modules/nf-core/gawk/main'

/*
===========================================
 * Workflows
===========================================
 */

workflow GUNZIP_AWK {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, _bam, _bai, _ref, _fai, vcf -> [meta, vcf] }
        .filter { it[1] =~ /\.vcf\.gz$/ }
        .set { ch_gz_in }

    GUNZIP(ch_gz_in)

    GUNZIP.out.gunzip.set { ch_gz_out }

    versions = versions.mix(GUNZIP.out.versions.first())

    GAWK(ch_gz_out, [], [])

    versions = versions.mix(GAWK.out.versions.first())

    input
        .join(GAWK.out.output)
        .map { meta, bam, bai, ref, fai, _old_vcf, new_vcf -> [meta, bam, bai, ref, fai, new_vcf] }
        .set { ch_awk_out }

    emit:
    ch_awk_out
    versions
}
