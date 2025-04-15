include { FIND_TELOMERE_REGIONS } from '../../modules/local/find_telomere_regions'  
include { FIND_TELOMERE_WINDOWS } from '../../modules/local/find_telomere_windows'  
include { EXTRACT_TELO } from '../../modules/local/extract_telo'  
include { TABIX_BGZIPTABIX } from '../../modules/nf-core/tabix/bgziptabix'  

workflow TELO_FINDER {  
    take:  
    reference_tuple  // [val(meta), path(fasta)]  
    teloseq          // Telomeric_motif (Eg-"TTAGGG")  

    main:  
    FIND_TELOMERE_REGIONS(reference_tuple, teloseq)  
    FIND_TELOMERE_WINDOWS(FIND_TELOMERE_REGIONS.out.telomere)  
    EXTRACT_TELO(FIND_TELOMERE_WINDOWS.out.windows)  
    TABIX_BGZIPTABIX(EXTRACT_TELO.out.bed)  

    emit:  
    bed_gz_tbi    = TABIX_BGZIPTABIX.out.gz_tbi  
    bedgraph_file = EXTRACT_TELO.out.bedgraph  
}  