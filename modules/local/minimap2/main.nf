process MINIMAP2 {
    tag "$meta.id"
    label 'process_medium'

    container "quay.io/biocontainers/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:3161f532a5ea6f1dec9be5667c9efc2afdac6104-0"

    input:
    tuple val(meta), path(reads), path(ref)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.csi"), emit: index
    path "versions.yml"       , emit: versions

   

    script:

    """

    minimap2 -y -Y -ax \\
        map-hifi $ref \\
        $reads -t $task.cpus \\
        --secondary=no \\
        | samtools sort \\
        --write-index --threads $task.cpus \\
        -o ${meta.id}_pacbio_aligned.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$( minimap2 --version )
    END_VERSIONS
    """
}