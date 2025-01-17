process SAMTOOLS_MERGE {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(forwardbam), path(reversebam)

    output:
    tuple val(meta), path("*.bam")      , emit: bam
    tuple val(meta), path("*.csi")      , emit: index
    path "versions.yml"                 , emit: versions


    script:

    """
    samtools \\
        merge \\
        -@ ${task.cpus} \\
        $forwardbam \\
        $reversebam \\
        -o - \\
        | samtools \\
        sort - -o sorted_${meta.id}_tagged.bam \\
        --write-index
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

}