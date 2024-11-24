library(ggplot2)
library(forecast)
library(tidyr)
library(dplyr)
library(nasapower)
library(lubridate)

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

# Clean the dataset
temp_data <- temp_data %>%
  # Reshape from wide to long format
  pivot_longer(
    cols = JAN:DEC, # Ensure column names match exactly
    names_to = "MONTH",
    values_to = "TEMPERATURE"
  ) %>%
  # Convert MONTH abbreviations to numbers
  mutate(
    MONTH = match(toupper(MONTH), toupper(month.abb)),
    YEAR_MONTH = paste(YEAR, MONTH, sep = "-") # Create 'YEAR-MONTH' column
  ) %>%
  mutate(YEAR_MONTH = ym(YEAR_MONTH)) %>% # Convert "YEAR-MONTH" to date
  # Select only the relevant columns for time series analysis
  select(YEAR_MONTH, TEMPERATURE)


# Part II
# Updated ggplot2 code
ggplot(temp_data, aes(x = YEAR_MONTH, y = TEMPERATURE)) +
  geom_line() +
  labs(
    title = "Temperature Trends Over Time",
    x = "Year-Month",
    y = "Temperature"
  )


plot(temp_data$TEMPERATURE, main = "Temperature Over Time", xlab = "Year", ylab = "Temperature")

ts_data <- ts(temp_data$TEMPERATURE, start = c(2000, 1), frequency = 12)
plot(ts_data, main = "Temperature Over Time", xlab = "Year", ylab = "Temperature")

library(stats)
decomposed <- decompose(ts(temp_data$TEMPERATURE, frequency = 12), type = "multiplicative")
plot(decomposed)

