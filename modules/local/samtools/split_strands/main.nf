process SAMTOOLS_SPLIT_STRAND {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/8c/8c5d2818c8b9f58e1fba77ce219fdaf32087ae53e857c4a496402978af26e78c/data'
        : 'community.wave.seqera.io/library/htslib_samtools:1.23.1--5b6bb4ede7e612e5'}"


    input:
    tuple val(meta), path(bam), path(bai)

    output        :
    tuple val(meta),      path("${meta.id}_forward*.bam"), emit: forwardbam
    tuple val(meta),      path("${meta.id}_reverse*.bam"), emit: reversebam
    tuple val("${task.process}"), val('samtools'), eval("samtools version | sed '1!d;s/.* //'"), topic: versions, emit: versions_samtools


    when:
    task.ext.when == null || task.ext.when

    script:

    """
    samtools view $bam -h -@ $task.cpus -F 20 \\
        | awk 'BEGIN {OFS="\\t"} /^@/ {print \$0; next} {\$0 = \$0 "\\tHP:i:1"; print \$0}' \\
        | samtools view -Sb -@ $task.cpus - -o ${meta.id}_forward_tagged.bam

    samtools view $bam -h -@ $task.cpus -f 16 \\
        |awk 'BEGIN {OFS="\\t"} /^@/ {print \$0; next} {\$0 = \$0 "\\tHP:i:2"; print \$0}' \\
        | samtools view -Sb -@ $task.cpus - -o ${meta.id}_reverse_tagged.bam

    """

    stub:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}_forward_tagged.bam
    touch ${prefix}_reverse_tagged.bam

    """

}
