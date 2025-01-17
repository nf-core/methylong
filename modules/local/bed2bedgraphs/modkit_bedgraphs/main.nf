// preprocess beds (cuz its huge) > filter out reads with less than 5x coverage, select only 6mA and the three C contexts and the fractions of the methylation for each genomic position 
// convert bed to bedgraphs, prepared as input to methylScore
// split into strands (+/ -) and contexts (CG, CHG, CHH) specific 
// filter out positions with less than 5x coverage 
// remove positions with no coverage - reason why this exist is because col 5 (the total coverage) also contained read counts from Nother_mod - see definition from modkit pileup, 
// thats why is still important to remove out these calls, or else it gives problem when input to methylScore 


process MODKIT_BEDGRAPH {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(in_bed), val(method)

    output:
    tuple val(meta), path("*.bedgraph"), emit: bedgraph


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
        awk -v strand=\$strand -v mod=\$mod 'BEGIN{OFS="\t"} ((\$4==mod) && (\$6==strand)) && (\$5 >= 5) {print \$1,\$2,\$3,\$11,\$12,\$13}' ${in_bed} > ${meta}_\${out_file}
      done
    done
    """
}

