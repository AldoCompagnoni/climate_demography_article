# Data and code associated with article "Linking climate and demography to predict population dynamics and persistence under global change"

## Workflow
All analyses are run through **Wrapper.R**. This file downloads MODIS data using script **get_modis.R**. Then, **temperature_means.R** it runs the analyses by combining climate data to the data with MODIS.

**get_modis.R** downloads two files, _greenup_modis.csv_, and _senescence_modis.csv_. These contain the dates of greenup and senescence, respectively, in years 2020, 2021, and 2022.

**temperature_means.R** calculates produces a figure overlaying four types of temperature means, to raw data of daily average temperatures. This script uses information from files _cgop_weather_daily_interp.csv_, _greenup_modis.csv_, and _senescence_modis.csv_. 
_cgop_weather_daily_interp.csv_ contains daily temperature data from a Garry Oak site in British Columbia from 2019 to the end of 2022. This file contains four variables, all of which are self-explanatory: _Date_, _minTemp_C_, _maxTemp_C_, _AveTemp_C_ (average temperature).
