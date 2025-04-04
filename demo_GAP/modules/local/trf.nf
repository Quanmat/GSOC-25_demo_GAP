process TRF {  
  tag "${assembly_id}"  
  container 'sanger-trf:1.0.0'  
  input:  
    path fasta  
    path chrom_sizes  
    val chunk_size : 5000  // (*Note - Can adjust –chunk_size in the nextflow process for finer resolution )
  output:  
    path "*.bed", emit: bed  
    path "*.bedgraph", emit: bedgraph  
    path "*.bb", emit: bigbed  
  script:  
    def prefix = fasta.baseName  

// ###################################
// Eg- 

    """  
    mkdir -p trf_tmp  
    python3 /usr/local/bin/run_trf.py ${fasta} trf_tmp/ ./ --chunk_size ${chunk_size}  
    bedSort ${prefix}_tandem_repeat_density.bed ${prefix}_trf_sorted.bed  
    bedToBigBed ${prefix}_trf_sorted.bed ${chrom_sizes} ${prefix}_trf.bb  
    """  
}  
