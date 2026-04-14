/*
===========================================
 * Import modules
===========================================
 */

include { DORADO_BASECALLER                } from '../../modules/local/dorado/basecaller/main'

/*
===========================================
 * Import subworkflows
===========================================
 */

include { FASTQ_UNZIP                      } from './shared_fastqc_unzip/main'
include { ONT_ALIGN                        } from './ont_align/main'
include { ONT_TRIM_REPAIR                  } from './ont_trim_repair/main'
include { BED2BEDGRAPH                     } from './shared_bed2bedgraph/main'
include { INDEX_MODKIT_PILEUP              } from './shared_modkit_pileup/main'
include { ONT_FIBERSEQ                     } from './ont_fiberseq/main'

/*
===========================================
 * ONT Workflows
===========================================
 */


workflow ONT {
    take:
    ch_input

    main:

    ont_versions = channel.empty()
    map_stat     = channel.empty()

    // basecall

    ch_input
        .filter { it[1].toString().endsWith('.pod5') || file(it[1]).isDirectory() }
        .map { meta, pod5, _ref -> [meta, pod5] }
        .set { ch_pod5 }

    DORADO_BASECALLER(ch_pod5, params.dorado_model, params.dorado_modification)

    ch_input
        .join ( DORADO_BASECALLER.out.bam )
        .map { meta, _pod5, ref, modbam -> [meta, modbam, ref] }
        .mix ( ch_input.filter { it[1].toString().endsWith('.bam') } )
        .set { ch_input }

    // fastq and gunzip

    FASTQ_UNZIP(ch_input)

    map_stat = map_stat.mix(FASTQ_UNZIP.out.fastqc_log.collect { it[1] }.ifEmpty([]))

    FASTQ_UNZIP.out.unzip_input.set{ ch_ont }

    if (params.no_trim) {
        ch_reads = ch_ont
    } else {
        ONT_TRIM_REPAIR(ch_ont)
        ont_versions = ont_versions.mix(ONT_TRIM_REPAIR.out.versions)
        ch_reads = ONT_TRIM_REPAIR.out.dorado_in
    }

    ONT_ALIGN(ch_reads)

    ch_pile_in   = ONT_ALIGN.out.ch_pile_in
    map_stat     = ONT_ALIGN.out.flagstat_out

    INDEX_MODKIT_PILEUP(ch_pile_in)

    ch_bg_in = INDEX_MODKIT_PILEUP.out.pileup_out

    if (params.bedgraph) {

        if (params.m6a) {
                ch_bg_in = ch_bg_in.mix(INDEX_MODKIT_PILEUP.out.pileup_6mA_out)
                }

        BED2BEDGRAPH(ch_bg_in)
    }

    if (params.fiberseq) {
        ONT_FIBERSEQ(ch_pile_in)
        ont_versions = ont_versions.mix(ONT_FIBERSEQ.out.versions)
    }

    emit:
    ch_pile_in
    ont_versions
    map_stat
}
