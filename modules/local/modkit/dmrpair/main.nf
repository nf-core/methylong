process MODKIT_DMRPAIR {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/ont-modkit:0.6.1--hcdda2d0_0'
        : 'biocontainers/ont-modkit:0.6.1--hcdda2d0_0'}"

    input:
    tuple val(meta), path(bed_hp1), path(bed_hp1_tbi)
    tuple val(meta2), path(bed_hp2), path(bed_hp2_tbi)
    tuple val(meta3), path(fasta), path(fai)


    output:
    tuple val(meta), path("*.bed.gz"), emit: bedgz
    tuple val(meta), path("*.log")   , emit: log     , optional: true
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args ?: ''
    def prefix      = task.ext.prefix ?: "${meta.id}"
    def reference   = fasta ? "--ref ${fasta}" : ""
    def a_params    = bed_hp1.collect { "-a $it" }.join(' ')
    def b_params    = bed_hp2.collect { "-b $it" }.join(' ')

    """
    modkit \\
        dmr pair \\
        $args \\
        $reference \\
        --threads ${task.cpus} \\
        $a_params \\
        $b_params \\
        -o ${prefix}.bed

    gzip -c ${prefix}.bed > ${prefix}.bed.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        modkit: \$( modkit --version | sed 's/mod_kit //' )
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo $args
    echo "" | gzip > ${prefix}.bed.gz
    touch ${prefix}_dmr.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        modkit: \$( modkit --version | sed 's/mod_kit //' )
    END_VERSIONS
    """
}
