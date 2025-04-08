process RENAME_FASTQ {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*fastq.gz"), emit: rename_fastq




    script:
    """
    cp ${meta.id}_${meta.method}_other.fastq.gz ${meta.id}_${meta.method}.fastq.gz

    """
}
