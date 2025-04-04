// ######## EXAMPLE - TRF ################

include { TRF } from '../modules/local/trf.nf'  
include { GENMAP_INDEX } from '../modules/local/genmap_index.nf'
include { GENMAP_MAP } from '../modules/local/genmap_map.nf'

workflow {  
  // FASTA indexing - 
  INDEX_FASTA(fasta)
  INDEX_FASTA(INPUT_FASTA.out.fasta)

  // Run TRF after indexing - 
  TRF(fasta, INDEX_FASTA.out.chrom_sizes, params.chunk_size)  
  
  // GenMap workflow
  GENMAP_INDEX(INPUT_FASTA.out.fasta)
  GENMAP_MAP(
    GENMAP_INDEX.out.index,
    params.genmap.exclude_regions ? file(params.genmap.exclude_regions) : []
  )

  // Track hub generation - 
  GENERATE_TRACKHUB(TRF.out.bigbed)  

 // Downstream usage
  ANNOTATION_PROCESS(GENMAP_MAP.out.bedgraph)
}  


// nextflow run main.nf --help  # List all parameters  