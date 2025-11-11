/*
===========================================
 * Import processes from modules
===========================================
 */

include { MODKIT_PILEUP   as MODKIT_PILEUP_POPULATION_SCALE } from '../../../../modules/nf-core/modkit/pileup/main'
include { GAWK            as GAWK_FOR_DSS                   } from '../../../../modules/nf-core/gawk/main'
include { SAMTOOLS_FAIDX                                    } from '../../../../modules/nf-core/samtools/faidx/main'

/*
===========================================
 * Workflows
===========================================
 */

workflow DSS_POPULATION_SCALE_PREPROCESS {
    take:
    input

    main:

    versions = Channel.empty()

    input
        .map { meta, _bam, _bai, ref -> [meta, ref] }
        .set { ch_ref }

    // Index ref
    SAMTOOLS_FAIDX(ch_ref, [[], []], [])

    versions = versions.mix(SAMTOOLS_FAIDX.out.versions.first())

    // Prepare inputs for modkit pileup
    input
        .join(SAMTOOLS_FAIDX.out.fai)
        .multiMap { meta, bam, bai, ref, fai ->
                bam: [meta, bam, bai]
                ref:  [meta, ref, fai]
        }
        .set { ch_pileup_in }

    // modkit pileup
    MODKIT_PILEUP_POPULATION_SCALE(ch_pileup_in.bam, ch_pileup_in.ref, [[], []])

    versions = versions.mix(MODKIT_PILEUP_POPULATION_SCALE.out.versions.first())

    // gawk
    GAWK_FOR_DSS(MODKIT_PILEUP_POPULATION_SCALE.out.bed, [], [])

    versions = versions.mix(GAWK_FOR_DSS.out.versions.first())

    GAWK_FOR_DSS.out.output.set { bed_preprocessed }

    emit:
    ch_pileup_in
    bed_preprocessed
    versions
}
