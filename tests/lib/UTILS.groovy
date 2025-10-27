// Helper functions for pipeline tests

class UTILS {

    public static def get_assertion = { Map args ->
        // Mandatory, as we always need an outdir
        def outdir = args.outdir

        // Use this args to run the test with stub
        // It will disable all assertions but versions and stable_name
        def stub = args.stub

        // Use this args to include muse txt files in the assertion
        // It will skip the first line of the txt file
        def include_muse_txt = args.include_muse_txt

        // Use this args to include freebayes unfiltered vcf files in the assertion
        // It will only print the vcf summary to avoid differing md5sums because of small differences in QUAL score
        def include_freebayes_unfiltered = args.include_freebayes_unfiltered

        // Will print the summary instead of the md5sum for vcf files
        def no_vcf_md5sum = args.no_vcf_md5sum

        // stable_name: All files + folders in ${outdir}/ with a stable name
        def stable_name = getAllFilesFromDir(outdir, relative: true, includeDir: true, ignore: ['pipeline_info/*.{html,json,txt}'])
        // stable_content: All files in ${outdir}/ with stable content
        def stable_content = getAllFilesFromDir(outdir, ignoreFile: 'tests/.nftignore')
        // bam_files: All bam files
        def bam_files = getAllFilesFromDir(outdir, include: ['**/*.bam'])
        // bam_index_files: All bam.bai files
        def bam_index_files = getAllFilesFromDir(outdir, include: ['**/*.bam.bai'])
        // cram_files: All cram files
        def cram_files = getAllFilesFromDir(outdir, include: ['**/*.cram'])
        // vcf_files: All vcf files
        def vcf_files = getAllFilesFromDir(outdir, include: ['**/*.vcf{,.gz}'])
        // vcf_index_files: All vcf index files
        def vcf_index_files = getAllFilesFromDir(outdir, include: ['**/*.vcf{,.gz}.tbi'])

        def assertion = []

        assertion.add(removeNextflowVersion("${outdir}/pipeline_info/nf_core_methylong_software_mqc_versions.yml"))
        assertion.add(stable_name)

        if (!stub) {
            assertion.add(stable_content.isEmpty() ? 'No stable content' : stable_content)
            assertion.add(bam_files.isEmpty() 
                ? 'No BAM files' 
                : bam_files.collect { file -> 
                file.getName() + ":md5," + bam([stringency: 'silent'], file.toString()).readsMD5 })

            assertion.add(cram_files.isEmpty() ? 'No CRAM files' : cram_files.collect { file -> file.getName() + ":md5," + cram(file.toString(), fasta).readsMD5 })
            
            assertion.add(
                bam_index_files.isEmpty() 
                    ? 'No BAM index files' 
                    : bam_index_files.collect { file -> 
                    def f = new File(file.toString()) 
                    def size = f.length() 
                    return file.getName() + ":exists,size=" + size }
                    )
            
            assertion.add(
                vcf_index_files.isEmpty() 
                    ? 'No VCF index files' 
                    : vcf_index_files.collect { file -> 
                    def f = new File(file.toString()) 
                    def size = f.length() 
                    return file.getName() + ":exists,size=" + size }
                    )

            if (no_vcf_md5sum) {
                assertion.add(vcf_files.isEmpty() ? 'No VCF files' : vcf_files.collect { file -> [ file.getName(), path(file.toString()).vcf.summary ] })
            } else {
                assertion.add(vcf_files.isEmpty() ? 'No VCF files' : vcf_files.collect { file -> file.getName() + ":md5," + path(file.toString()).vcf.variantsMD5 })
            }
        }

        return assertion
    }

    public static def get_test = { scenario ->
        // This function returns a closure that will be used to run the test and the assertion
        // It will create tags or options based on the scenario

        return {
            // If the test is for a gpu, we add the gpu tag
            // Otherwise, we add the cpu tag
            // If the tests has no conda incompatibilities
            // then we append "_conda" to the cpu/gpu tag
            // If the test is for a stub, we add options -stub
            // And we append "_stub" to the cpu/gpu tag

            // All options should be:
            // gpu (this is the default for gpu)
            // cpu (this is the default for tests without conda)
            // gpu_conda (this should never happen)
            // cpu_conda (this is the default for tests with conda compatibility)
            // gpu_stub
            // cpu_stub
            // gpu_conda_stub (this should never happen)
            // cpu_conda_stub

            if (scenario.stub) {
                options "-stub"
            }

            if (scenario.gpu) {
                tag "gpu${!scenario.no_conda ? '_conda' : ''}${scenario.stub ? '_stub' : ''}"
            }

            if (!scenario.gpu) {
                tag "cpu${!scenario.no_conda ? '_conda' : ''}${scenario.stub ? '_stub' : ''}"
            }

            // If a tag is provided, add it to the test
            if (scenario.tag) {
                tag scenario.tag
            }

            when {
                params {
                    // Mandatory, as we always need an outdir
                    outdir = "${outputDir}"
                    // Apply scenario-specific params
                    scenario.params.each { key, value ->
                        delegate."$key" = value
                    }
                }
            }

            then {
                // Assert failure
                if (scenario.failure) {
                    // Early failure, so we don't pollute console with massive diffs
                    assert workflow.failed
                    // Check stdout if specified
                    if (scenario.stdout) {
                        assertAll(
                            { assert workflow.stdout.toString().contains(scenario.stdout) }
                        )
                    }
                    // Check stderr if specified
                    if (scenario.stderr) {
                        { assert snapshot(
                            workflow.stderr.toString().replaceAll(/\x1B\[[0-9;]*m/, '').replaceAll(/^\[/, '').replaceAll(/\]$/, '').replaceAll(/, /, ',').split(",").findAll { !it.matches(/.*Nextflow [0-9]+\.[0-9]+\.[0-9]+ is available.*/) }[scenario.stderr]
                        ).match() }
                    }
                // Assert success
                } else {
                    // Early failure, so we don't pollute console with massive diffs
                    assert workflow.success
                    assertAll(
                        { assert snapshot(
                            // Number of successful tasks
                            workflow.trace.succeeded().size(),
                            // All assertions based on the scenario
                            *UTILS.get_assertion( no_vcf_md5sum: scenario.no_vcf_md5sum, outdir: params.outdir, stub: scenario.stub)
                        ).match() }
                    )
                    // Check stdout if specified
                    if (scenario.stdout) {
                        assert workflow.stdout.toString().contains(scenario.stdout)
                    }
                }
            }
        }
    }
}