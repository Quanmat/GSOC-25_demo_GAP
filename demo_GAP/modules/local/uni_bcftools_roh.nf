process BCFTOOLS_ROH {  
  tag "${meta.sample}"  
  container 'biocontainers/bcftools:1.17'  
  publishDir "results/roh", mode: 'copy'  

  input:  
  tuple val(meta), path(vcf)  
  path genome  
  path af_file, optional: true  

  output:  
  path "*.roh", emit: roh  
  path "global_heterozygosity.txt", emit: het_global  
  path "windowed_heterozygosity.bedgraph", emit: het_windows  
  path "roh_regions.bed", emit: roh_bed  
  path "roh_summary.tsv", emit: roh_summary  

  script:  
  def af_flag = af_file ? "--AF-file $af_file" : "--AF-dflt 0.4"  
  def window_size = params.window_size ?: 100000  

  """  
  # Step 1: Run bcftools roh once  
  bcftools roh \\  
    -G \\  
    $af_flag \\  
    --rec-rate ${params.rec_rate} \\  
    -G $window_size \\  
    -o ${meta.sample}.roh \\  
    $vcf  

  # Step 2: Calculate global heterozygosity (non-HOM windows)  
  awk '  
    BEGIN {total_het=0; total_length=0}  
    NR>1 {  
      if (\$6 != "HOM") total_het++;  
      total_length += (\$4 - \$3);  
    }  
    END {print "Global Heterozygosity:", total_het / total_length}' \\  
    ${meta.sample}.roh > global_heterozygosity.txt  

  # Step 3: Generate windowed heterozygosity track  
  awk 'NR>1 && \$6 != "HOM" {print \$2 "\t" \$3 "\t" \$4 "\t" \$6}' ${meta.sample}.roh \\  
    | bedtools map -a <(bedtools makewindows -g $genome -w $window_size) -b - -c 4 -o count \\  
    | awk 'BEGIN {OFS="\t"} {print \$1, \$2, \$3, (\$4 != "." ? \$4 : 0)}' \\  
    > windowed_heterozygosity.bedgraph  

  # Step 4: Extract ROH regions (HOM windows)  
  awk 'NR>1 && \$6 == "HOM" {print \$2 "\t" \$3 "\t" \$4 "\t" \$1}' ${meta.sample}.roh > roh_regions.bed  

  # Step 5: Generate ROH summary statistics  
  echo -e "Sample\tTotal_ROH_Regions\tTotal_ROH_Length\tLargest_ROH" > roh_summary.tsv  
  awk '  
    BEGIN {OFS="\t"; count=0; total=0; max=0}  
    NR>1 && \$6 == "HOM" {  
      count++;  
      len = \$4 - \$3;  
      total += len;  
      if (len > max) max = len;  
    }  
    END {print "${meta.sample}", count, total, max}' \\  
    ${meta.sample}.roh >> roh_summary.tsv  
  """  
}  