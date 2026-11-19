// convert bed to bedgraphs
// split into strands (+/ -) and contexts (CG, CHG, CHH) specific
// filter out positions with less than 5x coverage


process MODKIT_BEDGRAPH {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/pigz:2.8'
        : 'biocontainers/pigz:2.8'}"

    input:
    tuple val(meta), path(in_bed)

    output:
    tuple val(meta), path("*.bedgraph.gz"), emit: bedgraph
    tuple val("${task.process}"), val('pigz'), eval('pigz --version 2>&1 | sed "s/^.*pigz[[:space:]]*//"'), emit: versions_pigz, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def contexts = meta.bedgraph_modification == '6mA' ? 'A' : 'CG CHG CHH'

    """
    set -euo pipefail

    pigz -p ${task.cpus} -dc -- "${in_bed}" > pileup.bed

    for strand in "+" "-"
    do
        strand_name=positive
        if [ "\$strand" = "-" ]; then
            strand_name=negative
        fi

        for context in ${contexts}
        do
            awk -v strand="\$strand" -v context="\$context" '
                BEGIN { OFS = "\\t" }
                NF >= 13 && \$5 >= 5 && \$6 == strand &&
                    (\$4 == "C," context ",0" || (context == "A" && (\$4 == "a" || \$4 == "A,A,0"))) {
                    print \$1, \$2, \$3, \$11, \$12, \$13
                }
            ' pileup.bed \\
                | pigz -p ${task.cpus} -c > "${meta.id}_\${context}_\${strand_name}.bedgraph.gz"
        done
    done

    rm -f -- pileup.bed
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.bedgraph.gz

    """
}
