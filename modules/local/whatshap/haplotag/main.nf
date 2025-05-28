process WHATSHAP_HAPLOTAG {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/whatshap:2.3--py39h2de1943_3':
        'biocontainers/whatshap:2.6--py39h2de1943_0' }"

    input:
    tuple val(meta), path(bam), path(bai)
    tuple val(meta2), path(fasta), path(fai)
    tuple val(meta3), path(vcfgz), path(tbi)

    output:
    tuple val(meta), path("*.bam")      , emit: bam
    tuple val(meta), path("*.readlist") , emit: readlist
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args ?: ''
    def prefix      = task.ext.prefix ?: "${meta.id}"
    def reference   = fasta ? "--reference ${fasta}" : ""
    def output_list = "--output-haplotag-list ${prefix}_haplotagged.readlist"
    def output_bam  = "-o ${prefix}_haplotagged.bam"
    
    """
    whatshap \\
        haplotag \\
        $args \\
        $output_list \\
        $output_bam \\
        $reference \\
        $vcfgz \\
        $bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        whatshap: \$(whatshap --version )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_haplotagged"
    """
    touch ${prefix}.bam
    touch ${prefix}.readlist

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        whatshap: \$(whatshap --version )
    END_VERSIONS
    """
}
