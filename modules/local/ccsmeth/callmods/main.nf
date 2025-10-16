process CCSMETH_CALLMODS {
    tag "${meta.id}"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ccsmeth:0.5.0--pyhdfd78af_0':
        'biocontainers/ccsmeth:0.5.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam")  , emit: modbam
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args          = task.ext.args ?: ''
    def prefix        = task.ext.prefix ?: "${meta.id}"
    def model         = params.ccsmeth_cm_model

    """

    ccsmeth call_mods \\
        $args \\
        --input $bam \\
        --model_file $model \\
        --output ${prefix} \\
        --threads ${task.cpus}

    cat <<-END_VERSIONS > versions.yml

    "${task.process}":
        ccsmeth: "\$(ccsmeth --version | sed 's/ccsmeth version: //')"
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo $args
    touch ${prefix}/${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ccsmeth: "\$(ccsmeth --version | sed 's/ccsmeth version: //')"
    END_VERSIONS
    """
}
