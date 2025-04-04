process MODKIT_REPAIR {
    tag "$meta.id"
    label 'process_medium'

    container "quay.io/biocontainers/ont-modkit:0.4.2--hcdda2d0_0"

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
        -o ${meta.id}_repaired.bam \\
        --log-filepath ./${meta.id}_repair.log
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        modkit: \$( modkit --version | sed 's/mod_kit //' )
    END_VERSIONS
    """
}