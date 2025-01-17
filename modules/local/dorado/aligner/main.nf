process DORADO_ALIGNER {
    tag "$meta.id"
    label 'process_medium'


    input:
    tuple val(meta), path(reads), path(ref), val(method)

    output:
    tuple val(meta), path("${meta.id}/*.bam"), emit: bam
    tuple val(meta), path("${meta.id}/*.bai"), emit: bai
    tuple val(meta), path("${meta.id}/*.txt"), emit: summary

    path "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args ?: ''

    """
    dorado aligner \\
        -t $task.cpus \\
        $ref \\
        $reads \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dorado: \$( dorado --version )
    END_VERSIONS
    """
}