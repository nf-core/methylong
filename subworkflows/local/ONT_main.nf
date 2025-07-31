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
include { ONT_M6ACALL                      } from './ont_m6acall/main'
include { ONT_BASECALL                     } from './ont_basecall/main'
include { SHARED_FIBERTOOLS_EXTRACT        } from './shared_fibertools_extract/main'

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
        .set { ch_pod5 }
    
    ONT_BASECALL(ch_pod5)

    ont_versions = ont_versions.mix(ONT_BASECALL.out.versions)

    ONT_BASECALL.out.ch_pile_in
        .mix( ch_input.filter { it[1].toString().endsWith('.bam') } )
        .set{ ch_input }

    // m6acall

    if (params.m6a) {
        
        ONT_M6ACALL(ch_input)

        ont_versions = ont_versions.mix(ONT_M6ACALL.out.versions)

        ONT_M6ACALL.out.ch_modbam.set{ input }

    } else {

        ch_input.set{ input }

    }

    // fastq and gunzip

    FASTQ_UNZIP(input)

    ont_versions = ont_versions.mix(FASTQ_UNZIP.out.versions)
    map_stat = map_stat.mix(FASTQ_UNZIP.out.fastqc_log.collect { it[1] }.ifEmpty([]))

    FASTQ_UNZIP.out.unzip_input.set{ ch_ont }


    if (params.no_trim) {
        if (params.bedgraph) {

            ONT_ALIGN(ch_ont)

            ch_pile_in = ONT_ALIGN.out.ch_pile_in
            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

            BED2BEDGRAPH(INDEX_MODKIT_PILEUP.out.pileup_out)

            ont_versions = ont_versions.mix(BED2BEDGRAPH.out.versions)
        }
        else {

            ONT_ALIGN(ch_ont)

            ch_pile_in = ONT_ALIGN.out.ch_pile_in
            ont_versions = ont_versions.mix(ONT_ALIGN.out.versions)
            map_stat = ONT_ALIGN.out.flagstat_out

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)

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

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)

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

            INDEX_MODKIT_PILEUP(ONT_ALIGN.out.ch_pile_in)

            ont_versions = ont_versions.mix(INDEX_MODKIT_PILEUP.out.versions)

        }
    }

    if (params.m6a) {

        SHARED_FIBERTOOLS_EXTRACT(ch_pile_in)

        ont_versions = ont_versions.mix(SHARED_FIBERTOOLS_EXTRACT.out.versions)

    }

    emit:
    ch_pile_in
    ont_versions
    map_stat
}
