process MINIMAP2 {
    tag "$meta.id"
    label 'process_medium'

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