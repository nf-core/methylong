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
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    set -eu

    for strand in "+" "-"
    do
        for mod in "C,CHH,0" "C,CHG,0" "C,CG,0" "A,A,0"
        do
            case \$strand in
                "+")
            out_file=\$(echo "\$mod" | sed 's/^[AC],//' | sed 's/,0//')_positive.bedgraph
                ;;
                "-")
            out_file=\$(echo "\$mod" | sed 's/^[AC],//' | sed 's/,0//')_negative.bedgraph
                ;;
                *)
            echo "> not a strand"
                exit 1
                ;;
            esac
            echo "File Path: ${in_bed}"
            awk -v strand=\$strand -v mod=\$mod 'BEGIN{OFS="\t"} ((\$4==mod) && (\$6==strand)) && (\$5 >= 5) {print \$1,\$2,\$3,\$11,\$12,\$13}' ${in_bed} \
            | pigz -p ${task.cpus} -c > ${meta.id}_\${out_file}.gz
        done
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pigz: \$(pigz --version)
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.bedgraph.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pigz: \$(pigz --version)

    END_VERSIONS
    """
}
