library(ggplot2)
library(forecast)
library(dplyr)

# Part I - data wrangling 
#install.packages("nasapower")
library(nasapower)
temp_data <- get_power(
  community = "AG",
  lonlat = c(-3.1883,55.9533),   # Edinburgh's Longitude and Latitude
  pars = "T2M",      # Temperature at 2 meters
  temporal_api = "monthly",
  dates = c("2000", "2022")
)



