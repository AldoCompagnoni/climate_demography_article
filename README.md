# Data and code associated with article "Linking climate and demography to predict population dynamics and persistence under global change"

## Workflow
This code reproduces panels B and C of Figure 1 in the main article. Note that panel A in Figure 1 represents the same data as in panel C, but without the overlain lines. All analyses are run through **R/wrapper.R**. This file downloads MODIS data using script **R/get_modis.R**. Then, **R/temp_prec_plots.R** produces two plots, _tempertaure_means.tiff_ and _precip.tiff_. More specifically: 

**R/get_modis.R** downloads two files, _greenup_modis.csv_, and _senescence_modis.csv_. These contain the dates of greenup and senescence, respectively, in years 2020, 2021, and 2022.

**R/temp_prec_plots.R** uses all files: _greenup_modis.csv_, _senescence_modis.csv_, and _cgop_weather_daily.csv_. The last file contains daily temperature and precipitation data from the site located in British Columbia used as example. These data are limited to the interval June 2019 and May 2022. **temp_prec_plots.R** uses these data to:
1. Overlay four types of temperature means to raw data of daily average temperatures (Figure _tempertaure_means.tiff_). One of these temperature means uses the greenup and senescence MODIS data to define the interval of time used to compute the mean.
2. Plot the sequence of daily total precipitation from June 2019 to the end of May 2022 (Figure _precip.tiff_).

## Metadata
The Metadata of the three _.csv_ files contained in */data* are specified in three separate _.csv_ files contained in the */data/metadata* subfolder.

## Reproducibility
This repository uses the R package [renv](https://rstudio.github.io/renv/) for reproducibility. The code reported here should automatically install renv (if not installed yet), and restore the environment (R version and associated R packages) needed to run the code of the repository.
