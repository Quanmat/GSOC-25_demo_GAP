params.genmap.reuse_index = false

workflow {
  if (params.genmap.reuse_index && file("${params.outdir}/index").exists()) {
    GENMAP_MAP(path("${params.outdir}/index"), ...)
  } else {
    GENMAP_INDEX(...) 
  }
}