# demo_GAP
Just some examples to have better understanding of the GAP project, under GSOC'25.😊
## Note- This is just for better understanding of the possible approaches, and in no way reflects the actual approaches that will be implemneted.

## Low-Complexity Region Detection (dustmasker)  
### Usage  
 **Window Size**: Adjust via `--window_size` (default: 5000 bp).  
   ```bash  
   nextflow run main.nf --input genome.fa --window_size 10000
   ```
## Inverted Repeat Detection (einverted)  
### Usage  
**Window Size**: Adjust via `--window_size` (default: 5000 bp).  
   ```bash  
   nextflow run main.nf --input genome.fa --window_size 10000  
   ```
## TRF Module  
To run:  
```bash  
nextflow run main.nf --fasta <assembly.fasta> [--chunk_size 5000]

```
## Telomeric Analysis  
### Tools  
1. **tidk find**: Identifies clade-specific telomeric repeats.  
2. **telo_finder**: Finds regions matching a user-defined motif (e.g., `TTAGGG`).  

### Parameters  
- `--clade`: Clade for `tidk find` (e.g., "Lepidoptera").  
- `--teloseq`: Telomeric motif for `telo_finder` (default: `TTAGGG`).  

### Outputs  
- `results/tidk_find/`: Clade-specific repeats.  
- `results/telo_finder/`: Motif-specific regions.  
