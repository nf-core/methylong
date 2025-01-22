process PB_CPG_TOOLS {
    tag "$meta.id"
    label 'process_medium'

    container = "quay.io/pacbio/pb-cpg-tools:v2.3.2_build3"


    input:
    tuple val(meta), path(bam), path(index)
    tuple val(meta2), path(ref)

    output:
    tuple val(meta), path("*positive.bed"), emit: forwardbed
    tuple val(meta), path("*negative.bed"), emit: reversebed
    tuple val(meta), path("*.bw"), emit: bw
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml"       , emit: versions


    script:

    def pileup_mode = params.pileup_count ? "--pileup-mode count" : "--model /opt/pb-CpG-tools-v2.3.2-x86_64-unknown-linux-gnu/models/pileup_calling_model.v1.tflite" 

    """
    aligned_bam_to_cpg_scores \\
        --bam $bam \\
        --output-prefix ${meta.id} \\
        --min-coverage 5 \\
        --threads ${task.cpus} \\
        --ref $ref \\
        $pileup_mode

    # Rename output files
    mv ${meta.id}.hap1.bed ${meta.id}_positive.bed
    mv ${meta.id}.hap2.bed ${meta.id}_negative.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        aligned_bam_to_cpg_scores: \$( aligned_bam_to_cpg_scores --version )
    END_VERSIONS
    """
}


