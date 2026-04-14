process DORADO_ALIGNER {
    tag "${meta.id}"
    label 'process_high'

    container "docker.io/nanoporetech/dorado:shac8f356489fa8b44b31beba841b84d2879de2088e"

    input:
    tuple val(meta), path(reads)
    tuple val(meta2), path(ref)

    output:
    tuple val(meta), path("${meta.id}/**/*.bam"), emit: bam
    tuple val(meta), path("${meta.id}/**/*.bai"), emit: bai
    tuple val("${task.process}"), val('dorado'), eval("dorado --version 2>&1 | head -n1"),
    topic: versions,
    emit: versions_dorado

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    dorado aligner \\
        -t ${task.cpus} \\
        ${ref} \\
        ${reads} \\
        ${args}

    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}/${prefix}.bam
    touch ${prefix}/${prefix}.bai

    """
}
