process CCSMETH_BEDGRAPH {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/pigz:2.8'
        : 'biocontainers/pigz:2.8'}"

    input:
    tuple val(meta), path(in_bed)

    output:
    tuple val(meta), path("*_CG.bedgraph.gz"), emit: bedgraph
    tuple val("${task.process}"), val('pigz'), eval('pigz --version 2>&1 | sed "s/^.*pigz[[:space:]]*//"'), emit: versions_pigz, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    set -euo pipefail

    pigz -p ${task.cpus} -dc -- "${in_bed}" \\
        | awk 'BEGIN { FS = OFS = "\\t" } NF >= 11 && \$5 >= 5 { print \$1, \$2, \$3, \$11 }' \\
        | pigz -p ${task.cpus} -c > "${meta.id}_CG.bedgraph.gz"
    """

    stub:
    """
    pigz -c < /dev/null > "${meta.id}_CG.bedgraph.gz"
    """
}
