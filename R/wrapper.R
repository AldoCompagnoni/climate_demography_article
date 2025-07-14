# Ensure renv is installed
if( !"renv" %in% installed.packages() ){
  install.packages("renv")
}

# Restore libraries via renv 
renv::restore()

# get MODIS data
source( 'R/get_modis.R' )

# produce temperature and precipitation plots
source( 'R/temp_prec_plots.R' )
