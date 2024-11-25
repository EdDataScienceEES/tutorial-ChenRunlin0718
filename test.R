library(ggplot2)
library(forecast)
library(tidyr)
library(dplyr)
library(nasapower)
library(lubridate)
library(zoo)
library(tseries)
library(knitr)
library(rmarkdown)

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
### Temperature_Trends_Over_Time plot
(Temperature_Trends_Over_Time <- ggplot(temp_data, aes(x = YEAR_MONTH, y = TEMPERATURE)) +
  geom_line() +
  labs(
    title = "Temperature Trends Over Time",
    x = "Year-Month",
    y = "Temperature"
  ))
# Save the plot
ggsave('plots/Temperature_Trends_Over_Time.png', plot = Temperature_Trends_Over_Time, width = 30, height = 20, units = "cm", bg = "white")


### Decomposition plot
ts_data <- ts(temp_data$TEMPERATURE, start = c(2000, 1), frequency = 12)
# Apply STL decomposition (Seasonal and Trend decomposition using Loess)
png("plots/STL_Decomposition.png", width = 15, height = 10, units = "cm", bg = "white", res = 150)
decomposed_stl <- stl(ts_data, s.window = "periodic")
STL_Decomposition <- plot(decomposed_stl, main = "STL Decomposition of the Dataset")
dev.off()


### Stationarity Check
#library(tseries)

# Compute rolling mean and standard deviation
roll_mean <- zoo::rollmean(temp_data$TEMPERATURE, k = 12, fill = NA)
roll_sd <- zoo::rollapply(temp_data$TEMPERATURE, width = 12, FUN = sd, fill = NA)

png("plots/Stationarity_Check.png", width = 15, height = 10, units = "cm", bg = "white", res = 150)
plot(temp_data$TEMPERATURE, type = "l", col = "blue", ylab = "Temperature", xlab = "Number of Month from 2000")
lines(roll_mean, col = "red", lty = 2)  # Rolling mean
lines(roll_sd, col = "green", lty = 2)  # Rolling standard deviation
legend("topright", legend = c("Original", "Rolling Mean", "Rolling SD"), col = c("blue", "red", "green"), lty = c(1, 2, 2))
dev.off()

## Another (rather formal) way to test stationarity
library(tseries)
adf.test(temp_data$TEMPERATURE, alternative = "stationary")


# Autocorrelation check
model <- auto.arima(temp_data$TEMPERATURE)
residuals <- residuals(model)
# Check Normality
hist(residuals, main = "Histogram of Residuals", xlab = "Residuals")
qqnorm(residuals)
qqline(residuals, col = "red")
shapiro.test(residuals)

