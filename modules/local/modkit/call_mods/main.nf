process MODKIT_CALL_MODS {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/ont-modkit:0.4.3--hcdda2d0_0'
        : 'biocontainers/ont-modkit:0.4.3--hcdda2d0_0'}"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam"), emit: call_mod_bam
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args ?: ''
    def prefix      = task.ext.prefix ?: "${meta.id}"

    """
    modkit \\
        call-mods \\
        $args \\
        $bam \\
        --threads ${task.cpus} \\
        ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        modkit: \$( modkit --version | sed 's/mod_kit //' )
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        modkit: \$( modkit --version | sed 's/mod_kit //' )
    END_VERSIONS
    """
}
