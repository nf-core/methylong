process PB_CPG_TOOLS {
    tag "${meta.id}"
    label 'process_medium'

    container "quay.io/pacbio/pb-cpg-tools:3.0.0_build1"

    input:
    tuple val(meta) , path(bam), path(index)
    tuple val(meta2), path(ref)

    output:
    tuple val(meta), path("*positive.bed.gz"), emit: forwardbed
    tuple val(meta), path("*negative.bed.gz"), emit: reversebed
    tuple val(meta), path("*.bw")            , emit: bw
    tuple val(meta), path("*.log")           , emit: log
    path "versions.yml"                      , emit: versions

    script:

    def pileup_mode = params.pileup_count ? "count" : "model"
    def mode        = params.denovo ? "denovo" : "reference"

    """
    aligned_bam_to_cpg_scores \\
        --bam ${bam} \\
        --output-prefix ${meta.id} \\
        --threads ${task.cpus} \\
        --ref ${ref} \\
        --modsites-mode ${mode} \\
        --pileup-mode ${pileup_mode}

    # Rename output files
    mv ${meta.id}.hap1.bed.gz ${meta.id}_positive.bed.gz
    mv ${meta.id}.hap2.bed.gz ${meta.id}_negative.bed.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        aligned_bam_to_cpg_scores: \$( aligned_bam_to_cpg_scores --version | sed 's/aligned_bam_to_cpg_scores //')
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}_positive.bed.gz
    touch ${prefix}_negative.bed.gz
    touch ${prefix}.bw
    touch ${prefix}.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        aligned_bam_to_cpg_scores: \$( aligned_bam_to_cpg_scores --version | sed 's/aligned_bam_to_cpg_scores //')
    END_VERSIONS

    """
}
