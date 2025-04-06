process DUSTMASKER {  
    tag "DUSTMASKER_${meta.id}"  
    label 'process_medium'  
    container "quay.io/biocontainers/blast:2.13.0"  

    input:  
    tuple val(meta), path(fasta)  

    output:  
    tuple val(meta), path("${prefix}_lowcomplexity.bb"), emit: bb  # bigBed for track hub  
    path "versions.yml", emit: versions  

    script:  
    def prefix = fasta.baseName  
    """  
    Steps In shorts -------------->

    # Step 1: Convert FASTA to uppercase (GDA convention)  
    seqtk seq -U $fasta > ${prefix}_uppercase.fa  

    # Step 2: Run dustmasker (GDA-style FASTA masking)  
    dustmasker -in ${prefix}_uppercase.fa -out ${prefix}_dustmasked.fa -outfmt fasta  

    # Step 3: Generate BEDGRAPH via sliding windows (replaces custom Python script)  
    bedtools makewindows -g <(samtools faidx ${prefix}_uppercase.fa | cut -f1,2) -w ${params.window_size} | \  
    bedtools coverage -a - -b <(grep -v '>' ${prefix}_dustmasked.fa | awk '{print \$1, \$2}') | \  
    awk 'BEGIN {OFS="\\t"} {print \$1, \$2, \$3, \$4}' > ${prefix}_lowcomplexity.bedgraph  

    # Step 4: Convert to bigBed  
    bedGraphToBigBed ${prefix}_lowcomplexity.bedgraph \  
        <(samtools faidx ${prefix}_uppercase.fa | cut -f1,2) \  
        ${prefix}_lowcomplexity.bb  

    # Cleanup intermediates  
    rm ${prefix}_uppercase.fa ${prefix}_dustmasked.fa  

    # Capture versions  
    echo -e "${task.process}:\\n  dustmasker: \$(dustmasker -version | awk '{print \$2}')" > versions.yml  
    """  
}  