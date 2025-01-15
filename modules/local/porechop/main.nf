process PORECHOP {
    tag "$meta"
    label 'process_medium'

    publishDir(
        path:  "${params.outdir}/ont/trim/${meta}",
        mode: 'copy',
        saveAs: { fn -> fn.substring(fn.lastIndexOf('/')+1) },
    )

    conda "${moduleDir}/environment.yml"




    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fastq.gz"), emit: reads
    tuple val(meta), path("*.log")     , emit: log
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    micromamba run -n base porechop \\
        -i $reads \\
        -t $task.cpus \\
        $args \\
        --no_split \\
        --format fastq.gz \\
        -o trimmed_${meta}.fastq.gz \\
        > ${meta}_trimmed.log
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        porechop: \$( porechop --version )
    END_VERSIONS
    """
}