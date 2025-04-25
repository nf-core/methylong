process RENAME_FASTQ {
    tag "${meta.id}"
    label 'process_low'

    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/ubuntu%3A24.04'
        : 'biocontainers/ubuntu:24.04'}"

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*fastq.gz"), emit: rename_fastq

    script:
    """
    cp ${meta.id}_${meta.method}_other.fastq.gz ${meta.id}_${meta.method}.fastq.gz

    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.fastq.gz

    """
}
