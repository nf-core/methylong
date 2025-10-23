process FIBERTOOLS_EXTRACT {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/fibertools-rs:0.6.2--h3b373d1_0'
        : 'biocontainers/fibertools-rs:0.6.4--h3b373d1_0'}"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bed"), emit: bed
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args            = task.ext.args ?: ''
    def prefix          = task.ext.prefix ?: "${meta.id}"
    def outbed          = "--m6a ${prefix}.bed"

    """
    ft extract \\
        $args \\
        --threads ${task.cpus} \\
        $bam \\
        $outbed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fibertools: \$(ft --version | sed -E 's/.* ([0-9]+\\.[0-9]+\\.[0-9]+).*/\\1/' )
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fibertools: \$(ft --version | sed -E 's/.* ([0-9]+\\.[0-9]+\\.[0-9]+).*/\\1/' )

    END_VERSIONS
    """
}
