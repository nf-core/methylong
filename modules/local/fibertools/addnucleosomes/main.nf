process FIBERTOOLS_ADD_NUCLEOSOMES {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/fibertools-rs:0.6.2--h3b373d1_0'
        : 'biocontainers/fibertools-rs:0.6.4--h3b373d1_0'}"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam"), emit: modbam
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args            = task.ext.args ?: ''
    def prefix          = task.ext.prefix ?: "${meta.id}"

    """
    ft add-nucleosomes \\
        $args \\
        $bam \\
        ${prefix}.bam
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fibertools: \$(ft --version | sed 's/.* \\([^ ]*\\) .*/\1/' )
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fibertools: \$(ft --version | sed 's/.* \\([^ ]*\\) .*/\1/' )
    END_VERSIONS
    """
}
