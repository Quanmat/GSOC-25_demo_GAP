// Generate Genome Windows ########

bedtools makewindows \
  -g genome.txt \  
  -w 100000 \             // # Match bcftools -G parameter  
  > genome_windows.bed  



//   Map Heterozygous Windows

// # Converting ROH output to BED of heterozygous regions  
awk 'NR>1 && $6 != "HOM" {print $2 "\t" $3 "\t" $4}' sample.roh > het_regions.bed  

// # Counting overlaps per window  
bedtools map \
  -a genome_windows.bed \  
  -b het_regions.bed \  
  -c 1 -o count \  
  | awk 'BEGIN {OFS="\t"} {print $1, $2, $3, ($4 != "." ? $4 : 0)}' \  
  > windowed_heterozygosity.bedgraph  