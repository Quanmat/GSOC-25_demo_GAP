process BCFTOOLS_ROH {  
  tag "${meta.sample}"  
  container 'biocontainers/bcftools:1.17'  
  publishDir "results/roh", mode: 'copy'  

  input:  
  tuple val(meta), path(vcf)  
  path af_file, optional: true  
  path genetic_map, optional: true  

  output:  
  path "*.roh", emit: roh  
  path "*.bed", emit: bed  
  path "*.html", optional: true, emit: viz  

  script:  
  def af_cmd = af_file ? "--AF-file $af_file" : "--AF-dflt 0.4"  
  def map_cmd = genetic_map ? "--genetic-map $genetic_map" : "--rec-rate 1e-8"  

  """  
    Steps In shorts -------------->
  
  # Run bcftools ROH  
  bcftools roh \\  
    -G \\  
    $af_cmd \\  
    $map_cmd \\  
    -o ${meta.sample}.roh \\  
    $vcf  

  # Convert to BED  
  awk 'NR>1 && \$6 == "HOM" {print \$2 "\t" \$3 "\t" \$4}' ${meta.sample}.roh > ${meta.sample}_roh.bed  

  # * Optionally: Visualize  
  roh-viz -i ${meta.sample}.roh -v $vcf -o ${meta.sample}_roh.html  
  """  
}  