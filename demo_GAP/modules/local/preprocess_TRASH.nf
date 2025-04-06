// ####### Optional masking ####

process MASK_NS {  
  tag "${assembly_id}"  
  container 'our-biocontainer:1.0.0'  

  input:  
    path fasta  

  output:  
    path "*.masked.fa", emit: masked_fasta  

  script:  
    def prefix = fasta.baseName  
    """  
    sed 's/N/X/g' ${fasta} > ${prefix}.masked.fa  
    """  
}  