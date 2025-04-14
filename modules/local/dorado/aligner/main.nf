process DORADO_ALIGNER {
    tag "${meta.id}"
    label 'process_medium'

    container "ontresearch/dorado:mr597_sha6058abbabae30a845dcc4ac7b481208de9d2af71"

    input:
    tuple val(meta), path(reads), path(ref)

    output:
    tuple val(meta), path("${meta.id}/*.bam"), emit: bam
    tuple val(meta), path("${meta.id}/*.bai"), emit: bai
    tuple val(meta), path("${meta.id}/*.txt"), emit: summary
    path "versions.yml", emit: versions

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

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dorado: "\$(dorado --version 2>&1 | head -n1)"
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}/${prefix}.bam
    touch ${prefix}/${prefix}.bai
    touch ${prefix}/${prefix}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dorado: "\$(dorado --version 2>&1 | head -n1)"
    END_VERSIONS
    """
}
