process BCFTOOLS_ROH {  
  tag "${meta.sample}"  
  container 'biocontainers/bcftools:1.17'  
  publishDir "results/heterozygosity", mode: 'copy'  

  input:  
  tuple val(meta), path(vcf)  
  path genome  
  path af_file, optional: true  

  output:  
  path "*.roh", emit: roh  
  path "global_heterozygosity.txt", emit: global  
  path "windowed_heterozygosity.bedgraph", emit: windows  

  script:  
  def af_flag = af_file ? "--AF-file $af_file" : ""  
  def rec_rate = params.rec_rate ?: "1e-8"  

  """  
    Steps In shorts -------------->

  # Step 1: Run bcftools ROH  
  
  bcftools roh \\  
    $af_flag \\  
    --rec-rate $rec_rate \\  
    --ignore-homref \\  
    -G ${params.window_size} \\  
    -o ${meta.sample}.roh \\  
    $vcf  

  # Step 2: Calculate global heterozygosity
   
  total_het=\$(awk 'NR>1 && \$6 != "HOM" {count++} END {print count}' ${meta.sample}.roh)  
  total_length=\$(awk 'NR>1 {sum += \$4-\$3} END {print sum}' ${meta.sample}.roh)  
  echo "Global Heterozygosity: \$(echo "\$total_het / \$total_length" | bc -l)" > global_heterozygosity.txt  

  # Step 3: Generate windowed heterozygosity  

  awk 'NR>1 && \$6 != "HOM" {print \$2 "\t" \$3 "\t" \$4}' ${meta.sample}.roh > het_regions.bed  
  bedtools makewindows -g $genome -w ${params.window_size} > genome_windows.bed  
  bedtools map -a genome_windows.bed -b het_regions.bed -c 1 -o count \\  
    | awk 'BEGIN {OFS="\\t"} {print \$1, \$2, \$3, (\$4 != "." ? \$4 : 0)}' \\  
    > windowed_heterozygosity.bedgraph  
  """  
}  