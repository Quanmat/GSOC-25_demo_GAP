# demo_GAP
Just some examples to have better understanding of the GAP project, under GSOC'25.😊
## Note- This is just for better understanding of the possible approaches, and in no way reflects the actual approaches that will be implemneted.


## TRF Module  
To run:  
```bash  
nextflow run main.nf --fasta <assembly.fasta> [--chunk_size 5000]

## Telomeric Repeat Detection (tidk find)  
### Usage  
1. Specify the clade in `nextflow.config` or via CLI:  
   ```bash  
   nextflow run main.nf --input genome.fa --clade Lepidoptera  
