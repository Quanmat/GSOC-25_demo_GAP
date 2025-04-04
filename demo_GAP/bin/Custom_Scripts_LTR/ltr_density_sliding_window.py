import pandas as pd  
import numpy as np  

def calculate_density(bed_path, window=5000, step=1000):  
    df = pd.read_csv(bed_path, sep='\t', names=['chrom', 'start', 'end'])  
    density = []  
    for chrom in df['chrom'].unique():  
        chrom_df = df[df['chrom'] == chrom]  
        max_pos = chrom_df['end'].max()  
        for pos in range(0, max_pos, step):  
            window_start = pos  
            window_end = pos + window  
            hits = chrom_df[(chrom_df['start'] < window_end) & (chrom_df['end'] > window_start)]  
            hit_bp = sum(np.minimum(hits['end'], window_end) - np.maximum(hits['start'], window_start))  
            density.append((chrom, window_start, window_end, hit_bp / window))  
    return pd.DataFrame(density, columns=['scaffold', 'start_pos', 'end_pos', 'density'])  

if __name__ == "__main__":  
    import sys  
    density_df = calculate_density(sys.argv[1])  
    density_df.to_csv(sys.stdout, sep='\t', index=False)  