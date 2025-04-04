include { DUSTMASKER } from '../modules/local/dustmasker.nf'
include { EINVERTED } from '../modules/local/einverted.nf' 
include { TIDK_FIND } from '../modules/local/tidk_find'  
include { TELO_FINDER } from '../subworkflows/local/telo_finder'  


workflow {  
    // Input (FASTA) 
    input_channel = Channel.fromPath(params.input)  
    teloseq       = Channel.value(params.teloseq)  

    // Run both tools in parallel  
    DUSTMASKER(input_channel) 
    EINVERTED(input_channel)
    TIDK_FIND(input_channel, params.clade)  
    TELO_FINDER(input_channel, teloseq)  

    // Merge outputs for track hub  
    TRACK_HUB_GENERATOR(DUSTMASKER.out.bb) 
    TRACK_HUB_GENERATOR(EINVERTED.out.bb) 
    TRACK_HUB_GENERATOR(TIDK_FIND.out.results.mix(TELO_FINDER.out.bed_gz_tbi))  
     
}  