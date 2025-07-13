library(tidyverse)
library(lubridate)
library(testthat)
library(scales)
library(ggthemes)
library(gridExtra)

# choose the SPEI scale
spei_scale_ii <- 12

# format data
clim_df <- read.csv('data/cgop_weather_daily_interp.csv') %>% 
            subset( !is.na(AveTemp_C) ) %>% 
            mutate( Date = ymd(Date) ) %>% 
            mutate( jul  = format(Date, "%j") ) %>% 
            mutate( jul  = as.numeric(jul) ) %>% 
            mutate( dat_chr = as.character(Date) ) %>% 
            separate( dat_chr, c('year','month','day'), sep = '-') %>% 
            mutate( year  = as.numeric(year),
                    month = as.numeric(month),
                    day   = as.numeric(day) ) %>% 
            # Remove 2019 data before first of June
            subset( !(year %in% 2019 & jul < 152) ) #%>% 
            # # Remove 2022 data after May
            # subset( !(year %in% 2022 & jul > 151) )


# Monthly values ---------------------------------------------------------------

# compute monthly values
month_df <- clim_df %>% 
              group_by( year, month ) %>% 
              summarise( month_t = mean(AveTemp_C ) ) %>% 
              ungroup


# Yearly values (assuming growing season finishes May 31st --------------------- 

# last part of the census year
year_t1 <- clim_df %>% 
  subset( jul < 152 )

# first part of the census year
year_t0 <- clim_df %>% 
  subset( jul > 151 )  %>% 
  mutate( year = year + 1 ) 

# yearly (census-to-census) means 
year_df <- bind_rows( year_t0, year_t1 ) %>% 
  # subset( !(year == 2019) ) %>% 
  group_by( year ) %>% 
  mutate( year_t = mean(AveTemp_C ) ) %>% 
  ungroup %>% 
  arrange( Date )


# Growing season (a-priori: March through June) --------------------------------

# A priori growing season precipitation sum and temperature mean
gs_df <- clim_df %>% 
  subset( !(year %in% c(2019)) ) %>% 
  subset( month %in% c(3:5) ) %>% 
  group_by( year ) %>% 
  summarise( gs_t = mean(AveTemp_C)) %>% 
  ungroup %>% 
  right_join( expand.grid( year  = 2020:2022,
                           month = 3:5 ) 
              )

  
# Growing season (observed via MODIS) ------------------------------------------

# Save files (in case user does not have internet/does not have )
garry_greenup     <- read.csv( 'data/greenup_modis.csv' )
garry_senescence  <- read.csv( 'data/senescence_modis.csv') 

# check the years that we have
years_g <- garry_greenup$calendar_date %>% base::substr(1,4)
years_s <- garry_senescence$calendar_date %>% base::substr(1,4)

# test that years are the same (paranoia)
expect_true( identical(years_g, years_s) )

# start and end of growing seasons as observed by modis
start_end_df <- data.frame( year     = years_g,
                            gs_start = garry_greenup$value,
                            gs_end   = garry_senescence$value )
   
# make data frames with Dates of the growing seasons for each 
make_gs_date_df <- function(i, start_end_df){
  
  expand.grid( year  = start_end_df[i,]$year,
               day_i = start_end_df[i,]$gs_start:start_end_df[i,]$gs_end ) %>% 
    mutate( Date = as.Date(day_i) ) %>% 
    # remove day, as irrelevant at this point
    dplyr::select( -day_i )
  
}

# Dates of growing season observed by MODIS
gs_obs_dates <- lapply( 1:3, make_gs_date_df, start_end_df ) %>% 
                  bind_rows() %>% 
                  mutate( year = as.character(year) %>% as.numeric )


# Growing season (MODIS-selected, here "observed" growing season) 
gs_obs_df <- gs_obs_dates %>% 
              left_join( clim_df ) %>% 
              group_by( year ) %>% 
              mutate( gs_obs_t    = mean(AveTemp_C) ) %>% 
              ungroup %>% 
              dplyr::select(year, Date, gs_obs_t ) 


# Temperature plots ------------------------------------------------------------

# data frame to plot temperature
airt_df <- clim_df %>% 
  # remove data after 2021 growing season 
  subset( Date < ymd('2022-06-01') ) %>%  
  left_join( month_df ) %>%
  left_join( gs_df ) %>% 
  left_join( gs_obs_df )

# monthly segments
month_seg <- airt_df %>% 
  group_by( month_t ) %>% 
  summarise( min_date = as.numeric(Date) %>% min,
             max_date = as.numeric(Date) %>% max ) %>% 
  ungroup %>% 
  mutate( min_date = min_date %>% as.Date,
          max_date = max_date %>% as.Date ) %>% 
  mutate( Predictor = 'Monthly' )

# yearly segments
year_seg <- year_df %>% 
  # remove data after 2021 growing season is over
  subset( Date < ymd('2022-06-01') ) %>%  
  group_by( year_t ) %>% 
  summarise( min_date = as.numeric(Date) %>% min,
             max_date = as.numeric(Date) %>% max ) %>% 
  ungroup %>% 
  mutate( min_date = min_date %>% as.Date,
          max_date = max_date %>% as.Date ) %>% 
  mutate( Predictor = 'Yearly' )

# growing season (a-priori) segments
gs_seg <- airt_df %>% 
  group_by( gs_t ) %>% 
  # start and end of a-priori growing season segments
  summarise( min_date = as.numeric(Date) %>% min,
             max_date = as.numeric(Date) %>% max ) %>% 
  ungroup %>% 
  mutate( min_date = min_date %>% as.Date,
          max_date = max_date %>% as.Date ) %>% 
  subset( !is.na(gs_t) ) %>% 
  mutate( Predictor = 'Grow. seas. (a-priori)' )

# growing season (segment)
gs_obs_seg <- airt_df %>% 
  # attach the stat/end of the growing season info to the full dataset
  group_by( gs_obs_t ) %>% 
  # convert stat/end dates to integer number
  summarise( min_date = as.numeric(Date) %>% min,
             max_date = as.numeric(Date) %>% max ) %>% 
  ungroup %>% 
  mutate( min_date = min_date %>% as.Date,
          max_date = max_date %>% as.Date ) %>% 
  subset( !is.na(gs_obs_t) ) %>% 
  mutate( Predictor = 'Grow. seas. (MODIS)' )

# temperature plot
temp_p <- airt_df %>% 
  ggplot() +
  geom_line( aes(Date, AveTemp_C),
             alpha = 1) +
  # monthly segments
  geom_segment( data = month_seg,
                aes( x    = min_date, 
                     xend = max_date,
                     y    = month_t,
                     yend = month_t,
                     color = Predictor ),
                # col = 'blue',
                lwd = 1 ) +
  # year segments
  geom_segment( data = gs_seg,
                aes( x    = min_date, 
                     xend = max_date,
                     y    = gs_t,
                     yend = gs_t,
                     color = Predictor ),
                # col = 'green',
                lwd = 1 ) +
  # growing season (a-priori)
  geom_segment( data = year_seg,
                aes( x    = min_date, 
                     xend = max_date,
                     y    = year_t,
                     yend = year_t,
                     color = Predictor ),
                # col = 'red',
                lwd = 1 ) +
  # growing season (MODIS-observed) 
  geom_segment( data = year_seg,
                aes( x    = min_date, 
                     xend = max_date,
                     y    = year_t,
                     yend = year_t,
                     color = Predictor ),
                # col = 'red',
                lwd = 1 ) +
  geom_segment( data = gs_obs_seg,
                aes( x    = min_date, 
                     xend = max_date,
                     y    = gs_obs_t ,
                     yend = gs_obs_t ,
                     color = Predictor ),
                # col = 'red',
                lwd = 1 ) +
  scale_color_manual(
    values = c('Monthly' = '#56B4E9', 
               'Yearly' = '#E69F00', 
               'Grow. seas. (a-priori)' = '#009E73',
               'Grow. seas. (MODIS)' = '#F0E442' ),
    # labels = c('Monthly', 'Yearly', 'Growing season (a-priori)'), # Custom labels
    name = '' # Legend title
  ) +
  theme_few() +
  theme( legend.position = 'bottom' ) +
  labs( y = 'Mean daily temperature (°C)' )

# create "results" directory if it doesn't exist yet
if( !dir.exists('results') ) dir.create('results')

ggsave( 'results/temperature_means.tiff',
        temp_p, dpi = 600,
        width = 6.3, height = 4, compression = 'lzw' )
