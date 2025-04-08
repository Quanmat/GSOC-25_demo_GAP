process HET_DISTRIBUTION {
  tag "${meta.sample}"
  container 'biocontainers/bcftools:1.17'

  input:
  tuple val(meta), path(vcf)
  path genome

  output:
  path "het_distribution.bedgraph", emit: bedgraph
  path "het_distribution.png", optional: true, emit: image

  script:
  """


  # Extract heterozygous sites
  bcftools query -i 'GT="het"' -f '%CHROM\\t%POS\\t%POS\\n' $vcf \
    | awk '{print \$1 "\t" \$2 "\t" \$2+1 "\t1"}' > het_sites.bed

  # Sort
  bedtools sort -i het_sites.bed > het_sites_sorted.bed

  # Generate windows
  bedtools makewindows -g $genome -w 100000 > genome_windows.bed

  # Map counts
  bedtools map \
    -a genome_windows.bed \
    -b het_sites_sorted.bed \
    -c 4 -o count \
    | awk 'BEGIN {OFS="\\t"} {print \$1, \$2, \$3, (\$4 != "." ? \$4 : 0)}' \
    > het_distribution.bedgraph

  """
}