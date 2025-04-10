/*
===========================================
 * Import processes from modules
===========================================
 */

include { SAMTOOLS_SPLIT_STRAND } from '../../../modules/local/samtools/split_strands/main'
include { SAMTOOLS_MERGE        } from '../../../modules/local/samtools/merge/main'
include { PB_CPG_TOOLS          } from '../../../modules/local/pb_cpg_tools/main'

/*
===========================================
 * Workflows
===========================================
 */


// for PacBio

workflow PACBIO_SPLIT_STRAND_PBCPG_PILEUP {
    take:
    input

    main:

    versions = Channel.empty()
    // prepare input

    input
        .map { meta, bam, bai, _ref -> [meta, bam, bai] }
        .set { ch_split_in }

    input
        .map { meta, _bam, _bai, ref -> [meta, ref] }
        .set { ch_ref_in }


    SAMTOOLS_SPLIT_STRAND(ch_split_in)

    versions = versions.mix(SAMTOOLS_SPLIT_STRAND.out.versions.first())

    SAMTOOLS_SPLIT_STRAND.out.forwardbam
        .join(SAMTOOLS_SPLIT_STRAND.out.reversebam)
        .set { stranded_out }

    SAMTOOLS_MERGE(stranded_out)

    versions = versions.mix(SAMTOOLS_MERGE.out.versions.first())

    // Prepare inputs for pbcpgtools
    SAMTOOLS_MERGE.out.bam
        .join(SAMTOOLS_MERGE.out.index)
        .set { merged_bam }
    merged_bam
        .join(ch_ref_in)
        .multiMap { meta, bam, bai, ref ->
            bams: [meta, bam, bai]
            refs: [meta, ref]
        }
        .set { cpg_tools_in }

    PB_CPG_TOOLS(cpg_tools_in.bams, cpg_tools_in.refs)

    versions = versions.mix(PB_CPG_TOOLS.out.versions.first())

    PB_CPG_TOOLS.out.forwardbed
        .join(PB_CPG_TOOLS.out.reversebed)
        .set { pile_out }

    emit:
    pile_out
    versions
}
