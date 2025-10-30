process DSS {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/bioconductor-dss:2.54.0--r44h3df3fcb_0'
        : 'biocontainers/bioconductor-dss:2.54.0--r44h3df3fcb_0'}"

    input:
    tuple val(meta), path(bed_hp1)
    tuple val(meta2), path(bed_hp2)

    output:
    tuple val(meta), path("*.txt"), optional: true, emit: txt
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args            = task.ext.args ?: ''
    def prefix          = task.ext.prefix ?: "${meta.id}"
    def out_prefix      = "--out_prefix ${prefix}"
    def case_sample     = "--case '${bed_hp1}'"
    def control_sample  = "--control '${bed_hp2}'"
    def out_dir         = "--out_dir ./"

    """
    python \\
        $projectDir/bin/call_dss.py \\
        $args \\
        $out_prefix \\
        $case_sample \\
        $control_sample \\
        $out_dir \\
        > ${prefix}.log 2>&1

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R: \$( R --version 2>&1 | grep -i '^R version' | head -1 | cut -d' ' -f3 )
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo $args
    touch ${prefix}.txt
    touch ${prefix}.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R: \$( R --version 2>&1 | grep -i '^R version' | head -1 | cut -d' ' -f3 )
    END_VERSIONS
    """
}
