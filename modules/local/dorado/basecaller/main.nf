process DORADO_BASECALLER {
    tag "${meta.id}"
    label 'process_high'
    label 'process_gpu'

    container "docker.io/nanoporetech/dorado:shae423e761540b9d08b526a1eb32faf498f32e8f22"

    input:
    tuple val(meta), path(pod5_path)
    val(dorado_model)
    val(dorado_modification)

    output:
    tuple val(meta), path("*.bam")  , emit: bam
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args          = task.ext.args ?: ''
    def prefix        = task.ext.prefix ?: "${meta.id}"
    // def dorado_model  = params.dorado_model
    def modification  = "--modified-bases $dorado_modification"
    def use_gpu       = task.ext.use_gpu ? "--device cuda:all" : ""

    """

    ${!(dorado_model in ['hac','sup']) ? "dorado download --model $dorado_model" : ""}

    dorado basecaller \\
        $args \\
        $dorado_model \\
        $pod5_path \\
        $modification \\
        $use_gpu \\
        > ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml

    "${task.process}":
        dorado: "\$(dorado --version 2>&1 | head -n1)"
    END_VERSIONS
    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo $args
    touch ${prefix}/${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        dorado: "\$(dorado --version 2>&1 | head -n1)"
    END_VERSIONS
    """
}
