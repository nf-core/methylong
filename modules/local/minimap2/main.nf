process MINIMAP2 {
    tag "$meta"
    label 'process_medium'
    //publishDir "${params.out}", mode: 'copy', overwrite: false
    publishDir(
        path:  "${params.outdir}/pacbio/aligned_minimap2/${meta}",
        mode: 'copy',
        saveAs: { fn -> fn.substring(fn.lastIndexOf('/')+1) },
    )

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
        -o ${meta}_pacbio_aligned.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$( minimap2 --version )
    END_VERSIONS
    """
}