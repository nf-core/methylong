process PB_CPG_TOOLS {
    tag "$meta"
    label 'process_medium'
    publishDir(
        path:  "${params.outdir}/${method}/pileup/pb_cpg_tools/${meta}",
        mode: 'copy',
        saveAs: { fn -> fn.substring(fn.lastIndexOf('/')+1) },
    )

    input:
    tuple val(meta), path(bam), path(index), path(ref), val(method)


    output:
    tuple val(meta), path("*hap1.bed"), emit: forwardbed
    tuple val(meta), path("*hap2.bed"), emit: reversebed
    tuple val(meta), path("*.bw"), emit: bw
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml"       , emit: versions


    script:

    def pileup_mode = params.model == null ? "--model /bin/models/pileup_calling_model.v1.tflite" : "--pileup-mode count" 

    """

    aligned_bam_to_cpg_scores \\
        --bam $bam \\
        --output-prefix ${meta} \\
        --min-coverage 5 \\
        --threads $task.cpus \\
        --ref $ref \\
        $pileup_mode

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        aligned_bam_to_cpg_scores: \$( aligned_bam_to_cpg_scores --version )
    END_VERSIONS
    """
}


