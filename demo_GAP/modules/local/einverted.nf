process EINVERTED {  
    tag "EINVERTED_${meta.id}"  
    label 'process_medium'  
    container "quay.io/biocontainers/emboss:6.6.0"  

    input:  
    tuple val(meta), path(fasta)  

    output:  
    tuple val(meta), path("${prefix}_inverted.bb"), emit: bb  // bigBed for track hub  
    path "versions.yml", emit: versions  

    script:  
    def prefix = fasta.baseName  
    """  
    Steps in short -

    # Step 1: Run einverted (GDA parameters)  
    einverted -sequence $fasta \  
        -gap 12 \  
        -threshold 50 \  
        -match 3 \  
        -mismatch -4 \  
        -outfile ${prefix}.einverted  

    # Step 2: Parse .einverted output to BED  
    awk '/^Sequence:/ {chr=\$2} /^Start:/ {start=\$2} /^End:/ {print chr"\\t"start"\\t"\$2}' ${prefix}.einverted \  
        | sort -k1,1 -k2,2n > ${prefix}_inverted.bed  

    # Step 3: Generate density bedgraph via sliding windows  
    bedtools makewindows -g <(samtools faidx $fasta | cut -f1,2) -w ${params.window_size} \  
        | bedtools coverage -a - -b ${prefix}_inverted.bed \  
        | awk 'BEGIN {OFS="\\t"} {print \$1, \$2, \$3, \$4}' > ${prefix}_inverted.bedgraph  

    # Step 4: Convert to bigBed  
    bedGraphToBigBed ${prefix}_inverted.bedgraph \  
        <(samtools faidx $fasta | cut -f1,2) \  
        ${prefix}_inverted.bb  

    # Cleanup intermediates  
    rm ${prefix}.einverted ${prefix}_inverted.bed  

    # Capture versions  
    echo -e "${task.process}:\\n  einverted: \$(einverted -version 2>&1 | awk '{print \$3}')" > versions.yml  
    """  
}  