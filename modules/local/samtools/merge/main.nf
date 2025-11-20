process SAMTOOLS_MERGE {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/samtools:1.22.1--h96c455f_0'
        : 'biocontainers/samtools:1.22.1--h96c455f_0'}"

    input:
    tuple val(meta), path(forwardbam), path(reversebam)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.csi"), emit: index
    path "versions.yml"           , emit: versions

    script:

    """
    samtools \\
        merge \\
        -@ ${task.cpus} \\
        ${forwardbam} \\
        ${reversebam} \\
        -o - \\
        | samtools \\
        sort - -@ ${task.cpus} -o sorted_${meta.id}_tagged.bam \\
        --write-index

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.bam
    touch ${prefix}.csi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

}
