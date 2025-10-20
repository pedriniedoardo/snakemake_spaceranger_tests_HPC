rule runSpacerangerMultiRun:
    '''
    This is the rule to run cellranger from multi run samples
    The way this is implemented now I cannot validate the presence of the input files
    '''
    input:
        transcriptome = config["ref"]["reference"],
        # this way I am testing for the existance of the actual input files
        fastqs = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["sample_path_list"],
        image = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["sample_image"]
    output:
        output = config["out_location"] + "spaceranger/merged/{sample_name}_finished.log",
        folder = directory(config["out_location"] + "spaceranger/merged/{sample_name}")
    conda: config["env_spaceranger"]
    log:
        'logs/merged/{sample_name}/runSpacerangerMultiRun.log'
    benchmark:
        'benchmarks/merged/{sample_name}/runSpacerangerMultiRun.txt'
    resources:
        # mem_mb = 16000,
        cpus = config["set-threads"]["runSpaceranger"]
    threads:
        config["set-threads"]["runSpaceranger"]
    params:
        fastqs = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["sample_path_string"],
        INTRON_flag = config['INTRON_flag'],
        BAM_flag = config['BAM_flag'],
        cpus = config["set-threads"]["runSpaceranger"],
        RAM = config["set-resources"]["runSpaceranger"]["mem_gb"],
        INTRON_param = config['INTRON_param'],
        outs = directory(config["out_location"] + "spaceranger/merged/{sample_name}"),
        param_img = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["param_image"],
        param_cytaimg = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["param_cytaimage"],
        value_cytaimg = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["sample_cytaimage"],
        param_slide = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["param_slide"],
        value_slide = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["value_slide"],
        param_align = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["param_align"],
        value_align = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["value_align"],
        param_probe = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["param_probe"],
        value_probe = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["value_probe"],
        param_area = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["param_area"],
        value_area = lambda wildcards: SAMPLES_merge[wildcards.sample_name]["value_area"]

    shell:
        '''
        echo "generate the output folder" >> {log}
        mkdir -p {params.outs} >> {log}
        
        echo "start spaceranger run for <{wildcards.sample_name}>" >> {log}

        spaceranger count --id={wildcards.sample_name} \
        --transcriptome={input.transcriptome} \
        --fastqs={params.fastqs} \
        --sample={wildcards.sample_name} \
        --localcores={params.cpus} \
        --localmem={params.RAM} \
        --output-dir={params.outs} \
        --create-bam={params.BAM_flag} \
        {params.param_img}{input.image} \
        {params.param_cytaimg}{params.value_cytaimg} \
        {params.param_slide}{params.value_slide} \
        {params.param_area}{params.value_area} \
        {params.param_probe}{params.value_probe} \
        {params.param_align}{params.value_align} \
        
        # generate the output file
        touch {output.output}

        echo "completed run spaceranger for <{wildcards.sample_name}>" >> {log}
        '''

rule moveSpacerangerSummaryMultiRun:
    '''
    This is the rule to move the outputs of interest.
    '''
    input:
        cellranger_summary = rules.runSpacerangerMultiRun.output.output
    output:
        summary = config["out_location"] + "web_summaries/merged/{sample_name}_web_summary.html"
    # conda: config["env_bioinfo"]
    log:
        'logs/merged/{sample_name}/moveSpacerangerSummaryMultiRun.log'
    benchmark:
        'benchmarks/merged/{sample_name}/moveSpacerangerSummaryMultiRun.txt'
    resources:
        mem_mb = 250,
        cpus = 1
    threads: 1
    params:
        wd_summary = config["out_location"] + 'spaceranger/merged/{sample_name}/outs/web_summary.html',
    shell:
        '''
        # copy
        echo "copy summary <{wildcards.sample_name}>" >> {log}

        # copy the web summary from the output in an individula folder
        cp {params.wd_summary} {output.summary} >> {log}

        echo "summary copied <{wildcards.sample_name}>" >> {log}
        '''

rule runMultiqc1MultiRun:
    '''
    This rule allow to run the multiqc on the final folder.
    Currently it is set to run after cellranger. this is the only step to grep some outputs.
    '''
    input:
        # this is needed to trigger it after the generation of the outputs on all the outputs
        input_file=expand(rules.moveSpacerangerSummaryMultiRun.output.summary,
        sample_name=SAMPLES_merge.keys())
    output:
        html = config["out_location"] + "multiQC/merged/multiqc_report.html"
    conda: config["env_bioinfo"]
    log:
        'logs/merged/runMultiqc1MultiRun.log'
    benchmark:
        'benchmarks/merged/runMultiqc1MultiRun.txt'
    resources:
        mem_gb = 4,
        cpus = 2
    threads: 2
    params:
        folder_in = config["out_location"] + "spaceranger/merged/",
        folder_out = config["out_location"] + "multiQC/merged/"
    shell:
        '''
        echo "start multiqc" >> {log}
        multiqc --force {params.folder_in} -o {params.folder_out}
        echo "end multiqc" >> {log}
        '''
