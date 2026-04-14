process DORADO_BASECALLER {
    tag "${meta.id}"
    label 'process_high'
    label 'process_gpu'

    container "docker.io/nanoporetech/dorado:shac8f356489fa8b44b31beba841b84d2879de2088e"

    input:
    tuple val(meta), path(pod5_path)
    val(dorado_model)
    val(dorado_modification)

    output:
    tuple val(meta), path("*.bam")  , emit: bam
    tuple val("${task.process}"), val('dorado'), eval("dorado --version 2>&1 | head -n1"),
    topic: versions,
    emit: versions_dorado

    when:
    task.ext.when == null || task.ext.when

    script:
    def args          = task.ext.args ?: ''
    def prefix        = task.ext.prefix ?: "${meta.id}"
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

    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo $args
    touch ${prefix}/${prefix}.bam

    """
}
