process TIDK_FIND {  
    tag "TIDK_FIND_${meta.id}"  
    label 'process_low'  
    container "quay.io/biocontainers/tidk:0.2.61"  

    // Basic error handling  
    errorStrategy { task.exitStatus in 137..140 ? 'retry' : 'terminate' }  
    maxRetries 3  

    input:  
    tuple val(meta), path(fasta)  
    val(clade)  // Eg -  "Lepidoptera"  

    output:  
    tuple val(meta), path("${prefix}_find.tsv"), path("${prefix}_find.bb"), emit: results  
    path "versions.yml", emit: versions  

    script:  
    def prefix = fasta[0].toString().replaceAll(/(\.fa)?\.gz/, '')  
    """  
    In short key steps- 

    # Step 1: Run tidk find  
    tidk find -c "$clade" -o "$prefix" -d ./ "$fasta"  

    # Step 2: Convert BEDGRAPH → bigBed for track hub  
    bedGraphToBigBed "${prefix}_telomeric_repeat_windows.bedgraph" \  
        <(samtools faidx "$fasta" | cut -f1,2) \  
        "${prefix}_find.bb"  

    # Step 3: Cleanup intermediate files  
    rm "${prefix}_telomeric_repeat_windows.bedgraph"  

    # Capture versions  
    echo -e "${task.process}:\\n  tidk: \$(tidk --version | awk '{print \$2}')" > versions.yml  
    """  
}  