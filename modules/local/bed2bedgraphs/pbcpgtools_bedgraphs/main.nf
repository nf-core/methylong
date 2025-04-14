process PBCPG_BEDGRAPHS {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/pigz:2.8'
        : 'biocontainers/pigz:2.8'}"

    input:
    tuple val(meta), path(forwardbed), path(reversebed)

    output:
    tuple val(meta), path("*.bedgraph.gz"), emit: bedgraph
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    def pileup_mode = params.pileup_count ? "count" : "model"

    """
    set -eu

    pigz -cd -p ${task.cpus} ${forwardbed} \
        | tail -n +10 | awk 'BEGIN {OFS="\\t"} {print \$1, \$2, \$3, \$4, \$7, \$8}' > ${meta.id}.${pileup_mode}.forward.bedgraph

    pigz -cd -p ${task.cpus} ${reversebed} \
        | tail -n +10 | awk 'BEGIN {OFS="\\t"} {print \$1, \$2+1, \$3+1, \$4, \$7, \$8}' > ${meta.id}.${pileup_mode}.reverse.bedgraph

    cat ${meta.id}.${pileup_mode}.forward.bedgraph ${meta.id}.${pileup_mode}.reverse.bedgraph \
        | pigz -c > ${meta.id}_CG_${pileup_mode}.merged.bedgraph.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pigz: \$(pigz --version)

    END_VERSIONS
    """
}
