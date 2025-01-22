process DORADO_ALIGNER {
    tag "$meta.id"
    label 'process_medium'
    
    container "registry.hub.docker.com/ontresearch/dorado:mr555_shada39cafbee40826d83076f28b596ab59dc3d7211"

    
    input:
    tuple val(meta), path(reads), path(ref)

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