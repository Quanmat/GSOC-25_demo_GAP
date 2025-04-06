# Total heterozygous windows (non-HOM)  
total_het=$(awk 'NR>1 && $6 != "HOM" {count++} END {print count}' sample.roh)  

# Total callable genome length (sum of all windows)  
total_length=$(awk 'NR>1 {sum += $4-$3} END {print sum}' sample.roh)  

# Global heterozygosity (het windows / total windows)  
global_het=$(echo "$total_het / $total_length" | bc -l)  


//  Save Results - 
echo "Global Heterozygosity: $global_het" > sample_heterozygosity.txt  