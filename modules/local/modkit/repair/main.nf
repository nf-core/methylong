process MODKIT_REPAIR {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/ont-modkit:0.4.3--hcdda2d0_0'
        : 'biocontainers/ont-modkit:0.4.3--hcdda2d0_0'}"

    input:
    tuple val(meta), path(before_trim), path(after_trim)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    """
    modkit repair \\
        -t ${task.cpus} \\
        -d ${before_trim}  \\
        -a ${after_trim} \\
        -o ${meta.id}_repaired.bam \\
        --log-filepath ./${meta.id}_repair.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        modkit: \$( modkit --version | sed 's/mod_kit //' )
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.bam
    touch ${prefix}.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        modkit: \$( modkit --version | sed 's/mod_kit //' )
    END_VERSIONS
    """
}
