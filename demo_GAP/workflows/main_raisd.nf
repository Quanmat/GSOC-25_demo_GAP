include { RAISD } from '../modules/local/raisd'

workflow {
  // Previous steps
  VARIANT_CALLING(...)

  // RAiSD analysis
  RAISD(VARIANT_CALLING.out.vcf, REFERENCE.out.genome)

  // Outputs
  raisd_report = RAISD.out.report
  raisd_plots = RAISD.out.plot
}