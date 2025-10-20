# sample rule to launch spaceranger
rule runSpaceranger:
    '''
    This is the rule to run spaceranger.
    '''
    input:
        fastqs = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["sample_path_list"],
        transcriptome = config["ref"]["reference"],
        image = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["sample_image"]
    output:
        output = config["out_location"] + "spaceranger/single/{sample_run}/{sample_name}_finished.log",
        folder = directory(config["out_location"] + "spaceranger/single/{sample_run}/{sample_name}")
    conda: config["env_spaceranger"]
    log:
        'logs/single/{sample_run}/{sample_name}/runSpaceranger.log'
    benchmark:
        'benchmarks/single/{sample_run}/{sample_name}/runSpaceranger.txt'
    resources:
        # mem_mb = 16000,
        cpus = config["set-threads"]["runSpaceranger"]
    threads:
        config["set-threads"]["runSpaceranger"]
    params:
        fastqs = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["sample_path_string"],
        sample_name_unique = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["sample_name_unique"],
        INTRON_flag = config['INTRON_flag'],
        BAM_flag = config['BAM_flag'],
        cpus = config["set-threads"]["runSpaceranger"],
        RAM = config["set-resources"]["runSpaceranger"]["mem_gb"],
        INTRON_param = config['INTRON_param'],
        outs = directory(config["out_location"] + "spaceranger/single/{sample_run}/{sample_name}"),
        param_img = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["param_image"],
        param_cytaimg = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["param_cytaimage"],
        value_cytaimg = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["sample_cytaimage"],
        param_slide = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["param_slide"],
        value_slide = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["value_slide"],
        param_align = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["param_align"],
        value_align = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["value_align"],
        param_probe = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["param_probe"],
        value_probe = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["value_probe"],
        param_area = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["param_area"],
        value_area = lambda wildcards: SAMPLES_single[(wildcards.sample_name, wildcards.sample_run)]["value_area"]
        
    shell:
        '''
        echo "generate the output folder" >> {log}
        mkdir -p {params.outs} >> {log}
        
        echo "start spaceranger run for <{wildcards.sample_name}>" >> {log}

        spaceranger count --id={params.sample_name_unique} \
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

rule moveSpacerangerSummary:
    '''
    This is the rule to move the outputs of interest.
    '''
    input:
        spaceranger_summary = rules.runSpaceranger.output.output
    output:
        summary = config["out_location"] + "web_summaries/single/{sample_run}/{sample_name}_web_summary.html"
    # conda: config["env_bioinfo"]
    log:
        'logs/single/{sample_run}/{sample_name}/moveSpacerangerSummary.log'
    benchmark:
        'benchmarks/single/{sample_run}/{sample_name}/moveSpacerangerSummary.txt'
    resources:
        mem_mb = 250,
        cpus = 1
    threads: 1
    params:
        wd_summary = config["out_location"] + 'spaceranger/single/{sample_run}/{sample_name}/outs/web_summary.html',
    shell:
        '''
        # copy
        echo "copy summary <{wildcards.sample_name}>" >> {log}

        # copy the web summary from the output in an individula folder
        cp {params.wd_summary} {output.summary} >> {log}

        echo "summary copied <{wildcards.sample_name}>" >> {log}
        '''

rule runMultiqc1:
    '''
    This rule allow to run the multiqc on the final folder.
    Currently it is set to run after spaceranger. this is the only step to grep some outputs.
    This implementation allow to have all the runs in the same report.
    '''
    input:
        # this is needed to trigger it after the generation of the outputs on all the outputs
        input_file=expand(rules.moveSpacerangerSummary.output.summary,
                            zip, # Use zip mode
                            sample_name=[k[0] for k in SAMPLES_single.keys()], # List of first elements (names)
                            sample_run=[k[1] for k in SAMPLES_single.keys()])
    output:
        html = config["out_location"] + "multiQC/single/multiqc_report.html"
    conda: config["env_bioinfo"]
    log:
        'logs/single/runMultiqc1.log'
    benchmark:
        'benchmarks/single/runMultiqc1.txt'
    resources:
        mem_gb = 4,
        cpus = 2
    threads: 2
    params:
        folder_in = config["out_location"] + "spaceranger/single/",
        folder_out = config["out_location"] + "multiQC/single/"
    shell:
        '''
        echo "start multiqc" >> {log}
        multiqc {params.folder_in} -o {params.folder_out}
        echo "end multiqc" >> {log}
        '''
