/*
 ===========================================
 * Import processes from modules
 ===========================================
 */

include { GUNZIP } from '../../../../modules/nf-core/gunzip/main'

/*
 ===========================================
 * Workflows
 ===========================================
 */

 workflow UNZIP {  
  
  take: 
    input
  
  main: 

    input
        .map { meta, _modbam, ref -> [meta, ref]}
        .filter { it[1] =~ /fa\.gz$|fna\.gz$|fasta\.gz$/ }
        .set {ch_gz_in}

    input
        .map { meta, _modbam, ref -> [meta, ref]}
        .filter { !(it[2] =~ /fa\.gz$|fna\.gz$|fasta\.gz$/ )}
        .set {ch_no_gz_in}

    GUNZIP(ch_gz_in)

    GUNZIP.out.gunzip
              .set {unzip_ref}
    
    GUNZIP.out.versions
              .set {gz_version}

    // merge into one channel 
    unzip_ref
            .concat(ch_no_gz_in)
            .set { ch_index_in }

    // then join back to the original input 
    input
            .join( ch_index_in )
            .map {meta, modbam, _ref, unzip_ref -> [meta, modbam, unzip_ref]}
            .set { unzip_input }

  emit: 
    unzip_input
    gz_version

 }