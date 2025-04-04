process PBCPG_BEDGRAPHS {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(forwardbed), path(reversebed)

    output:
    tuple val(meta), path("*.bedgraph"), emit: bedgraph
    path "versions.yml"                , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    
    def pileup_mode = params.pileup_count ? "count" : "model"

    """
    set -eu

    awk 'BEGIN {OFS="\\t"} {print \$1, \$2, \$3, \$4, \$6}' ${forwardbed} > ${meta.id}.${pileup_mode}.forward.bedgraph
    awk 'BEGIN {OFS="\\t"} {print \$1, \$2+1, \$3+1, \$4, \$6}' ${reversebed} > ${meta.id}.${pileup_mode}.reverse.bedgraph

    cat ${meta.id}.${pileup_mode}.forward.bedgraph ${meta.id}.${pileup_mode}.reverse.bedgraph > ${meta.id}_CG_${pileup_mode}.merged.bedgraph
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pigz: \$(pigz --version)
    END_VERSIONS
    """
}
