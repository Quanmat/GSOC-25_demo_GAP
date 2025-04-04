// Split genome into 10Mb chunks
CHUNKS = channel.fromFilePairs("${params.genmap.regions_dir}/*.bed")

GENMAP_MAP
  .multiMap { it -> 
    index: it[0], 
    regions: CHUNKS 
  }
  .set { mapped_regions }

mapped_regions
  .collect()
  .map { mergeBedGraphs(it) } // Custom merging function