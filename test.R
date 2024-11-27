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

# Check Normality

model <- auto.arima(temp_data$TEMPERATURE)

# Extract residuals
residuals <- residuals(model)

# Set up a layout with 1 row and 2 columns
png("plots/two_plots_his_QQ.png", width = 17, height = 10, units = "cm", bg = "white", res = 130)
par(mfrow = c(1, 2))
# First plot
hist(residuals, main = "Histogram of Residuals", xlab = "Residuals")
# Second plot
qqnorm(residuals)
qqline(residuals, col = "red")
dev.off()

# shapiro.test(residuals)

## Part III
### 6. Select an appropriate forecasting model.
### ARIMA Model
# Automatically find the best ARIMA model
best_model <- auto.arima(temp_data$TEMPERATURE, seasonal = TRUE)

# Display the model summary
summary(best_model)


### 7. Generate forecasts for future time points.
# Forecast for the next 12 months
forecasted_12month <- forecast(best_model, h = 12)

# Display the forecast summary
print(forecasted_12month)

# Generate yearly labels based on the range of your data
years <- seq(2000, 2024, by = 1)  # Adjust the range to include the forecast horizon

png("plots/forecasted_12month.png", width = 17, height = 10, units = "cm", bg = "white", res = 130)
# Plot the forecast without the default x-axis because the the default x-axis is 'month'
plot(forecasted_12month, xaxt = "n", main = "Temperature Forecast", ylab = "Temperature", xlab = "Year")
# Add custom x-axis labels with yearly intervals
axis(1, at = seq(1, length(temp_data$TEMPERATURE) + 24, by = 12), labels = years)
dev.off()


# (Optional) Compare the forecasted temperature with real-world temperature
### dataset of 2023
temp_data_2023 <- get_power(
  community = "AG",
  lonlat = c(-3.1883,55.9533),   # Edinburgh's Longitude and Latitude
  pars = "T2M",      # Temperature at 2 meters
  temporal_api = "daily",
  dates = c("2023/01/01", "2023/12/31")
)
Montly_2023_data <- temp_data_2023 %>%
  group_by(YEAR, MM) %>%
  summarise(TEMPERATURE = mean(T2M, na.rm = TRUE))

png("plots/true_with_forecasted_12month.png", width = 17, height = 10, units = "cm", bg = "white", res = 130)
plot(forecasted_12month, xaxt = "n", main = "Temperature Forecast", ylab = "Temperature", xlab = "Year")
# Add custom x-axis labels with yearly intervals
axis(1, at = seq(1, length(temp_data$TEMPERATURE) + 24, by = 12), labels = years)
# Overlay the real-life data on the plot
lines(
  x = seq(length(temp_data$TEMPERATURE) + 1, length(temp_data$TEMPERATURE) + 12), 
  y = Montly_2023_data$TEMPERATURE, 
  col = "red", 
  lwd = 2
)
dev.off()


### 8. Evaluate the model's performance.
# Plot residual diagnostics
png("plots/forecasted_model_residual_plot.png", width = 17, height = 10, units = "cm", bg = "white", res = 130)
checkresiduals(best_model)
dev.off()
# Calculate accuracy metrics
accuracy(forecasted)


#### 9. Forecast for the next 60 months (5 years)
forecasted_5_years <- forecast(best_model, h = 60)

# Generate yearly labels including the next 5 years
years_5_years <- seq(2000, 2027, by = 1)  # Adjust range based on data and forecast horizon
png("plots/forecasted_15years.png", width = 17, height = 10, units = "cm", bg = "white", res = 130)
# Plot the forecast without default x-axis
plot(forecasted_5_years, xaxt = "n", main = "Temperature Forecast for Next 5 Years", 
     ylab = "Temperature", xlab = "Year")

# Add custom x-axis labels
axis(1, at = seq(1, length(temp_data$TEMPERATURE) + 60, by = 12), labels = years_5_years)
dev.off()


# (Optional) Challenge Question 

decomposed_data <- decompose(ts(temp_data$TEMPERATURE, frequency = 12))
plot(decomposed_data)

# Create a detrended dataset by subtracting the trend component
detrended_temp <- temp_data$TEMPERATURE - decomposed_data$trend

# Remove NA values caused by missing trend values at the beginning and end
detrended_temp <- na.omit(detrended_temp)

# Fit an ARIMA model on the detrended dataset
detrended_model <- auto.arima(detrended_temp, seasonal = TRUE)

# Display the summary of the detrended model
summary(detrended_model)

# Forecast for the next 5 years (60 months)
detrended_forecast <- forecast(detrended_model, h = 60)

# Plot the forecast
plot(detrended_forecast, main = "Forecast After Detrending")

# Analyze residuals
checkresiduals(detrended_model)

# Compare accuracy metrics
detrended_accuracy <- accuracy(detrended_model)
original_accuracy <- accuracy(best_model)

# Print comparison
cat("Detrended Model Accuracy:\n")
print(detrended_accuracy)

cat("Original Model Accuracy:\n")
print(original_accuracy)

