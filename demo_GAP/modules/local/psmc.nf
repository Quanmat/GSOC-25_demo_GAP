process PSMC {  
  tag "${meta.sample}"  
  container 'our/psmc-container:latest'  

  input:  
  tuple val(meta), path(fq)  

  output:  
  path "*.psmc", emit: psmc  
  path "*.psmcfa", emit: psmcfa  

  script:  
  """  
  utils/fq2psmcfa -q20 $fq > ${meta.sample}.psmcfa  
  psmc -N25 -t15 -r5 -p "4+25*2+4+6" -o ${meta.sample}.psmc ${meta.sample}.psmcfa  
  """  
}  