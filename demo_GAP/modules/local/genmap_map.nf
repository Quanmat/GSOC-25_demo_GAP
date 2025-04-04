process GENMAP_MAP {
  tag "${meta.id}"
  label 'process_high'
  container 'your-container-with-genmap:1.3.0'

  input:
  tuple val(meta), path(index)
  tuple val(meta2), path(regions), optional: true

  output:
  tuple val(meta), path("*.bedgraph"), emit: bedgraph
  path "versions.yml", emit: versions

  script:
  def regions_flag = regions ? "--selection $regions" : ""
  def args = task.ext.args ?: "--k 100 --mismatches 4" // Default parameters
  
  """
  genmap map \\
    $args \\
    $regions_flag \\
    --index $index \\
    --output ./ \\
    --threads ${task.cpus} \\
    --bedgraph
  """
}