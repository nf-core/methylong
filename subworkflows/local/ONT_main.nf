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

    ont_versions = Channel.empty()
    map_stat     = Channel.empty()

    // basecall

    ch_input
        .filter { it[1].toString().endsWith('.pod5') || file(it[1]).isDirectory() }
        .map { meta, pod5, _ref -> [meta, pod5] }
        .set { ch_pod5 }

    DORADO_BASECALLER(ch_pod5)

    ont_versions = ont_versions.mix(DORADO_BASECALLER.out.versions.first())

    ch_input
        .join ( DORADO_BASECALLER.out.bam )
        .map { meta, _pod5, ref, modbam -> [meta, modbam, ref] }
        .mix ( ch_input.filter { it[1].toString().endsWith('.bam') } )
        .set { ch_input }

    // fastq and gunzip

    FASTQ_UNZIP(ch_input)

    ont_versions = ont_versions.mix(FASTQ_UNZIP.out.versions)
    map_stat = map_stat.mix(FASTQ_UNZIP.out.fastqc_log.collect { it[1] }.ifEmpty([]))

    FASTQ_UNZIP.out.unzip_input.set{ ch_ont }


    if (params.no_trim) {
        if (params.bedgraph) {

            ONT_ALIGN(ch_ont)

            ch_pile_in = ONT_ALIGN.out.ch_pile_in
            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            ont_versions = ont_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            ONT_ALIGN(ch_ont)

            ch_pile_in = ONT_ALIGN.out.ch_pile_in
            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)
        }
    }
    else {
        if (params.bedgraph) {

            ONT_TRIM_REPAIR(ch_ont)

            ont_versions = ont_versions.mix(ONT_TRIM_REPAIR.out.versions)

            ONT_ALIGN(ONT_TRIM_REPAIR.out.dorado_in)

            ch_pile_in = ONT_ALIGN.out.ch_pile_in
            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            ont_versions = ont_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            ONT_TRIM_REPAIR(ch_ont)

            ont_versions = ont_versions.mix(ONT_TRIM_REPAIR.out.versions)

            ONT_ALIGN(ONT_TRIM_REPAIR.out.dorado_in)

            ch_pile_in = ONT_ALIGN.out.ch_pile_in
            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

        }
    }


    // fiberseq

    if (params.fiberseq) {

        ONT_FIBERSEQ(ch_pile_in)

        ont_versions = ont_versions.mix(ONT_FIBERSEQ.out.versions)

    }

    emit:
    ch_pile_in
    ont_versions
    map_stat
}
