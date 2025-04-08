process RUN_PANTERA {
    tag "${meta.species}"
    publishDir "${params.outdir}/pantera", mode: 'copy'

    input:
    tuple val(meta), path(haplotypes)
    path chrom_sizes  // From samtools faidx

    output:
    path "*.bb", emit: bigbed
    path "pantera_lib.fa.classified", emit: te_lib

    script:
    """
      Steps In shorts -------------->

    # Step 1: Combine haplotypes per chromosome and run pggb
    cat ${haplotypes} > combined_haplotypes.fa
    bgzip combined_haplotypes.fa
    samtools faidx combined_haplotypes.fa.gz
    pggb -i combined_haplotypes.fa.gz -o pggb_out -n 2 -t ${task.cpus}

    # Step 2: Run Pantera on GFA files
    ls pggb_out/*.gfa > gfas_list.txt
    pantera.R -g gfas_list.txt -o pantera_out -c ${task.cpus}

    # Step 3: Classify TEs with RepeatClassifier
    RepeatClassifier -consensi pantera_out/pantera_lib.fa

    # Step 4: Convert to BED and bigBed
    awk 'BEGIN{OFS="\\t"} /^>/ {split($0,a,"-"); chr=a[2]; start=a[3]; end=a[4]} {print chr, start, end}' pantera_lib.fa.classified > pantera.bed
    bedSort pantera.bed pantera.sorted.bed
    bedToBigBed pantera.sorted.bed ${chrom_sizes} pantera.bb
    """
}


// #### Pre-check in Input Validation:

// if (!params.haplotypes) {
//     log.warn "Skipping Pantera: No haplotype inputs provided."
// } else {
//     RUN_PANTERA(...)
// }
