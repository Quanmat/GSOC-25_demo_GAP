process VCF2FQ {  
  tag "${meta.sample}"  
  container 'biocontainers/bcftools:1.17'  

  input:  
  tuple val(meta), path(vcf)  

  output:  
  path "diploid.fq.gz", emit: fq  

  script:  
  """  
  bcftools view -v snps $vcf \  
    | vcfutils.pl vcf2fq -d 10 -D 100 \  
    | gzip > diploid.fq.gz  
  """  
}  