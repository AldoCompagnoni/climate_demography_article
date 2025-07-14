# Data and code associated with article "Linking climate and demography to predict population dynamics and persistence under global change"

## Workflow
All analyses are run through **Wrapper.R**. This file downloads MODIS data using script **get_modis.R**. Then, **temp_prec_plots.R** reads in daily temperature and precipitation data, computes the relevant means (if any), and produces two plots, _precip.tiff_ and _tempertaure_means.tiff_

**get_modis.R** downloads two files, _greenup_modis.csv_, and _senescence_modis.csv_. These contain the dates of greenup and senescence, respectively, in years 2020, 2021, and 2022.

**temp_prec_plots.R** produces two figures using files _greenup_modis.csv_, _senescence_modis.csv_, and _cgop_weather_daily.csv_:
1. The first figure overlays four types of temperature means to raw data of daily average temperatures. This script uses information from files _cgop_weather_daily.csv_, _greenup_modis.csv_, and _senescence_modis.csv_. 
2. The second figure plots the sequence of daily total precipitation from 2019 to the end of May 2022.

## Reproducibility
This repository uses the R package [renv](https://rstudio.github.io/renv/) for reproducibility. The code reported here should automatically install renv (if not installed yet), and restore the environment (R version and associated R packages) needed to run the code of this repository.

## Metadata
The Metadata of the three _.csv_ files contained in */data* are specified in three separate _.csv_ files contained in the */data/metadata* subfolder.
