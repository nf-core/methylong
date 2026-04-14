process WHATSHAP_PHASE {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/whatshap:2.6--py39h2de1943_0':
        'biocontainers/whatshap:2.6--py39h2de1943_0' }"

    input:
    tuple val(meta), path(bam), path(bai)
    tuple val(meta2), path(fasta), path(fai)
    tuple val(meta3), path(vcf)

    output:
    tuple val(meta), path("*.vcf.gz"), emit: vcfgz
    tuple val("${task.process}"), val('whatshap'), eval("whatshap --version"), topic: versions, emit: versions_whatshap

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args ?: ''
    def prefix      = task.ext.prefix ?: "${meta.id}"
    def output      = "-o ${prefix}.vcf.gz"
    def reference   = fasta ? "--reference=${fasta}" : ""

    """
    whatshap \\
        phase \\
        $args \\
        $output \\
        $reference \\
        $vcf \\
        $bam

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo $args
    echo "" | gzip > ${prefix}.vcf.gz

    """
}
