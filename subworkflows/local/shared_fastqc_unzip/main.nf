/*
===========================================
 * Import processes from modules
===========================================
 */

include { GUNZIP } from '../../../modules/nf-core/gunzip/main'
include { FASTQC } from '../../../modules/nf-core/fastqc/main'

/*
===========================================
 * Workflows
===========================================
 */

workflow FASTQ_UNZIP {
    take:
    input

    main:

    fastqc_log = channel.empty()

    input
        .map { meta, modbam, _ref -> [meta, modbam] }
        .set { fastqc_in }

    FASTQC(fastqc_in)
    fastqc_log = fastqc_log.mix(FASTQC.out.zip.collect { it[1] }.ifEmpty([]))

    input
        .map { meta, _modbam, ref -> [meta, ref] }
        .filter { it[1] =~ /fa\.gz$|fna\.gz$|fasta\.gz$/ }
        .set { ch_gz_in }

    input
        .map { meta, _modbam, ref -> [meta, ref] }
        .filter { !(it[2] =~ /fa\.gz$|fna\.gz$|fasta\.gz$/) }
        .set { ch_no_gz_in }

    GUNZIP(ch_gz_in)

    GUNZIP.out.gunzip.set { unzip_ref }

    // merge into one channel
    unzip_ref
        .concat(ch_no_gz_in)
        .set { ch_index_in }

    // then join back to the original input
    input
        .join(ch_index_in)
        .map { meta, modbam, _gzref, ref -> [meta, modbam, ref] }
        .set { unzip_input }

    emit:
    unzip_input
    fastqc_log
}
