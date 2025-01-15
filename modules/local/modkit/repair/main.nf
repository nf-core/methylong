process MODKIT_REPAIR {
    tag "$meta"
    label 'process_medium'
    //publishDir "${params.out}", mode: 'copy', overwrite: false
    publishDir(
        path: "${params.outdir}/ont/repair",
        mode: 'copy',
        saveAs: { fn -> fn.substring(fn.lastIndexOf('/')+1) },
    )

    input:
    tuple val(meta), path(before_trim), path(after_trim)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.log")     , emit: log
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    """
    modkit repair \\
        -t $task.cpus \\
        -d $before_trim  \\
        -a $after_trim \\
        -o ${meta}_repaired.bam \\
        --log-filepath ./${meta}_repair.log
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        modkit: \$( modkit --version )
    END_VERSIONS
    """
}