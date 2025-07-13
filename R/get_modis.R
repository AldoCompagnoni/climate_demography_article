library(tidyverse)
library(lubridate)
library(MODISTools)

# Phenology: Modis product MCD12Q2
bands <- mt_bands(product = "MCD12Q2")
dates <- mt_dates(product = "MCD12Q2", 
                  lat = 48.77684893077655, 
                  lon = -123.93986390377184)

# greenup date
garry_greenup <- mt_subset(product = "MCD12Q2",
                           lat = 48.77684893077655,
                           lon =  -123.93986390377184,
                           band = "Greenup.Num_Modes_01",
                           start = "2019-06-01",
                           end = "2022-08-31",
                           site_name = "grarryoak",
                           internal = TRUE,
                           progress = FALSE
)

# greenup date
garry_senescence <- mt_subset(product = "MCD12Q2",
                              lat = 48.77684893077655,
                              lon =  -123.93986390377184,
                              band = "Senescence.Num_Modes_01",
                              start = "2019-06-01",
                              end = "2022-08-31",
                              site_name = "grarryoak",
                              internal = TRUE,
                              progress = FALSE
)

# Save files (in case user does not have internet/does not have )
write.csv(garry_greenup, 'data/greenup_modis.csv', row.names = F)
write.csv(garry_senescence, 'data/senescence_modis.csv', row.names = F)
