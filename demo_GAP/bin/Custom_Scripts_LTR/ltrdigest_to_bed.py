import sys  

with open(sys.argv[1], 'r') as f:  
    for line in f:  
        if line.startswith('#'):  
            continue  
        fields = line.strip().split('\t')  
        if fields[2] == "LTR_retrotransposon":  
            chrom = fields[0]  
            start = int(fields[3]) - 1  # Converting to 0-based BED  
            end = fields[4]  
            print(f"{chrom}\t{start}\t{end}")  

