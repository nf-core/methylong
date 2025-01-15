process DORADO_ALIGNER {
    tag "$meta"
    label 'process_medium'
    //publishDir "${params.out}", mode: 'copy', overwrite: false
    publishDir(
        path:  "${params.outdir}/${method}/alignment/${meta}",
        mode: 'copy',
        saveAs: { fn -> fn.substring(fn.lastIndexOf('/')+1) },
    )

    input:
    tuple val(meta), path(reads), path(ref), val(method)

    output:
    tuple val(meta), path("${meta}/*.bam"), emit: bam
    tuple val(meta), path("${meta}/*.bai"), emit: bai
    tuple val(meta), path("${meta}/*.txt"), emit: summary

    path "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    """
    dorado aligner \\
        -t $task.cpus \\
        $ref \\
        $reads \\
        --emit-summary \\
        --output-dir ${meta}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dorado: \$( dorado --version )
    END_VERSIONS
    """
}