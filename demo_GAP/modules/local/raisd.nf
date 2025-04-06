process RAISD {
  tag "${meta.sample}"
  container 'our-raisd-container:latest'
  publishDir "results/raisd", mode: 'copy'

  input:
  tuple val(meta), path(vcf)
  path genome  // Genome file (chrom sizes)

  output:
  path "RAiSD_Report.${meta.sample}", emit: report
  path "RAiSD_ManhattanPlot.${meta.sample}.png", emit: plot
  path "histogram.tsv", emit: hist_data
  path "histogram.png", emit: hist_image

  script:
  def genome_size = file(genome).name == 'genome.txt' ? "-L $(awk '{sum+=\$2} END{print sum}' $genome)" : ""

  """
  # Step 1: Run RAiSD
  RAiSD \
    -n ${meta.sample} \
    -I $vcf \
    $genome_size \
    -A 0.95 \              # Generate Manhattan plot (top 5% outliers)
    -P                     # Generate per-chromosome PDF plots

  # Step 2: Convert Manhattan PDF to PNG (2000px width)
  convert -density 300 RAiSD_ManhattanPlot.${meta.sample}.pdf -resize 2000x RAiSD_ManhattanPlot.${meta.sample}.png

  # Step 3: Generate histogram from RAiSD report
  awk '\$NF > 0 {print \$NF}' RAiSD_Report.${meta.sample} \
    | sort -n \
    | uniq -c \
    | awk '{print \$2 "\t" \$1}' > histogram.tsv

  # Step 4: Plot histogram with R
  Rscript -e '
    data <- read.table("histogram.tsv", header=F, col.names=c("Score", "Count"))
    png("histogram.png", width=2000, height=1200, res=300)
    hist(data$Score, breaks=50, main="μ-Statistic Score Distribution", xlab="Score", col="skyblue")
    dev.off()
  '
  """
}