process TRASH {  
  tag "${assembly_id}"  
  container 'your-trash-container:1.0.0'  
  publishDir "./output", pattern: "*.{bb,bed,gff,csv,pdf}", mode: 'copy'  

  input:  
    path fasta                // Input FASTA (masked or unmasked)  
    path chrom_sizes          // Chromosome sizes (from samtools faidx)  
    val params                // TRASH parameters  

  output:  
    path "*.gff", emit: gff            // GFF annotations  
    path "*.csv", emit: csv            // CSV metadata (repeats, HORs)  
    path "*.bb", emit: bigbed          // bigBed track  
    path "plots/*.pdf", emit: plots    // Circos/HOR plots  

  script:  
    def prefix = fasta.baseName  
    def trash_params = params.trash ?: "--k 10 --win 1000 --t 5"  

    """  
    Steps in short -
    
    # Step 1: Run TRASH  
    conda run -n trash-env TRASH_run.sh ${fasta} --o ./ ${trash_params}  

    # Step 2: Convert CSV → BED (custom script)  
    awk -F',' 'NR>1 {print \$2"\t"\$3"\t"\$4}' ${prefix}_all.repeats.from.${prefix}.csv > ${prefix}_trash.bed  

    # Step 3: Convert BED → bigBed  
    bedSort ${prefix}_trash.bed ${prefix}_trash_sorted.bed  
    bedToBigBed ${prefix}_trash_sorted.bed ${chrom_sizes} ${prefix}_trash.bb  

    # Step 4: Organize outputs  
    mkdir -p plots  
    mv *.pdf plots/  
    """  
}  