process LTR_RETROTRANSPOSONS {  
  tag "${assembly_id}"  
  container 'your-ltr-container:1.0.0'  
  input:  
    path fasta  
    path chrom_sizes  
    val chunk_size : 5000  // Default window size (matching TRF)  

  output:  
    path "*.gff3", emit: gff      // LTRdigest annotations  
    path "*.bed", emit: bed        // Discrete LTR elements  
    path "*.bb", emit: bigbed      // bigBed track (elements + density)  

  script:  
    def prefix = fasta.baseName  
    """  
    In short key steps - 
    
    # Step 1: Run LTRharvest + LTRdigest  
    ltrharvest -sequence ${fasta} -out ${prefix}_ltrharvest.gff3 -minlenltr 100 -maxlenltr 6000 -similar 85  
    ltrdigest -hmms gydb_hmms ${prefix}_ltrharvest.gff3 ${fasta} > ${prefix}_ltrdigest.gff3  

    # Step 2: Convert GFF3 → BED (custom script)  
    python3 /usr/local/bin/ltrdigest_to_bed.py ${prefix}_ltrdigest.gff3 > ${prefix}_ltr_elements.bed  

    # Step 3: Calculate LTR density (sliding window)  
    python3 /usr/local/bin/ltr_density_sliding_window.py ${prefix}_ltr_elements.bed --window ${chunk_size} > ${prefix}_ltr_density.tsv  

    # Step 4: Convert density → BED (reuse TRF script)  
    python3 /usr/local/bin/trf_repeat_density_to_gff.py ${prefix}_ltr_density.tsv BED > ${prefix}_ltr_density.bed  

    # Step 5: BED → bigBed (elements + density)  
    bedSort ${prefix}_ltr_elements.bed ${prefix}_ltr_elements_sorted.bed  
    bedToBigBed ${prefix}_ltr_elements_sorted.bed ${chrom_sizes} ${prefix}_ltr_elements.bb  
    bedSort ${prefix}_ltr_density.bed ${prefix}_ltr_density_sorted.bed  
    bedToBigBed ${prefix}_ltr_density_sorted.bed ${chrom_sizes} ${prefix}_ltr_density.bb  
    """  
}  