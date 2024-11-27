---
title: 'Tutorial: Introduction to time Series Analysis for Environmental Data'
author: "Runlin Chen"
date: "2024-11-21"
output: html_document
---

# Tutorial aims 

1. Understand the fundamentals of time series analysis and its applications in environmental data.
2. Learn how to preprocess, visualize, and decompose time series dataset for meaningful insights.
3. Gain hands-on experience with forecasting techniques to predict trends in environmental data.
4. Develop skills in using R and relevant packages for analyzing time series data effectively.

# Tutorial steps
#### 1. Introduction.

### Part I: Data Preparation and Exploration
#### 2. Data wrangling:
a) Load the relevant libraries and the dataset.
b) Clean and organize the dataset


### Part II: Analyzing Time Series
#### 4. Decomposing Time Series:
a) Splitting time series into trend, seasonal, and residual components with _decompose_.
b) Interpreting decomposed components in environmental contexts.

5. Detecting Anomalies:
a) Identifying outliers and spikes using visualization techniques.
b) Using statistical tests to confirm anomalies.

### Part III: Forecasting
6. Select an appropriate forecasting model.


7. Generate forecasts for future time points.

8. Evaluate the model's performance.
9. Visualize and interpret the forecast results.


### (Optional) Part IV: Advanced Techniques and Challenge
8. Advanced Topics:
a) Multivariate time series analysis (e.g., temperature and rainfall relationships).
b) Seasonal decomposition of environmental data using Loess (STL).

## 1. Introduction
Time series data are sequential data points collected over time. In environmental science, these could be measurements like temperature, rainfall, species population counts, or carbon dioxide levels. Time series analysis allows us to detect trends, seasonality, and anomalies, predict future values, and understand temporal dynamics of environmental processes. In this tutorial, you’ll learn the basics of time series analysis, including data preprocessing, visualization, decomposition, and basic forecasting techniques.

In part 1, we will be working with a dataset from *NASA* that captures the temperature of earth and try to do some data wrangling with it to make it easier for later analysis. In part 2, we will look into some basic and fundamental techniques that can be used to deal with time series data. In part 3, things are going to get interesting because we are going to build a forecasting Models that is able to predict the temperature in the future. 

> ***_NOTE:_***  Note that this tutorial will assume that you already have previous experience with R and familiar with basic operations of R such as _%>%_ and _summarise()_. If not, Coding Club has got you covered: check out the [Intro to R tutorial](https://ourcodingclub.github.io/tutorials/intro-to-r/)!


{% capture callout %}

Note that this tutorial will assume that you already have previous experience with R and familiar with basic operations of R such as _%>%_ and _summarise()_. If not, Coding Club has got you covered: check out the [Intro to R tutorial](https://ourcodingclub.github.io/tutorials/intro-to-r/)!
  
{% endcapture %}
{% include callout.html content=callout colour=alert %}


# _Part I: Data Preparation and Exploration_
## 2. Data Wrangling
### a) Load the dataset
In this tutorial, we will use a dataset obtained from the **NASA POWER API**, a tool that provides climate data from NASA's Prediction of Worldwide Energy Resource (POWER) project. Specifically, we will use monthly temperature data (measured at 2 meters above the ground) of Edinburgh (by using Edinburgh's location coordinates: Longitude: 3.1883°W & Latitude: 55.9533°N) for the years 2000 to 2022. 
We first download the relevant packages using the following code:
```r
# Relevant packages
# Need to download them if you haven't already
library(ggplot2)
library(forecast)
library(dplyr)
library(nasapower)
library(lubridate)
```

Now let's load the dataset and name it `temp_data`. Note that we want the location to be Edinburgh so we need to enter Edinburgh's coordinate of location. 

```r
temp_data <- get_power(
  community = "AG",
  lonlat = c(-3.1883,55.9533),   # Edinburgh's Longitude and Latitude
  pars = "T2M",      # Temperature at 2 meters
  temporal_api = "monthly",
  dates = c("2000", "2022")
)
```

### b) Clean and organize the dataset
Now we have the dataset, but is it in a ideal form for doing time series analysis? An ideal dataset for time series analysis has specific characteristics that make it well-suited for extracting meaningful patterns and developing accurate models:

**- Consistent Time Intervals:** Regular intervals ensure that the dataset captures temporal patterns like trends, seasonality, or cyclic behavior accurately. Irregular intervals make it difficult to apply standard time series models. 

**- No Missing Values:** Missing values can lead to incorrect analysis, such as distorted trends or seasonal patterns. If unavoidable, missing values should be deleted or handled appropriately.

**- Sufficient Length of Historical Data:** Time series models rely on past data to predict future values. A longer dataset allows for better detection of trends, seasonality, and rare events (e.g., economic recessions or climate changes).

**- Clear labels for time periods:** Properly labeled time points make it easier to interpret results and ensure that models process the data correctly. 

These are some basic characteristics of a dataset that is ideal for doing timer series analysis. Without these characteristics, the quality and reliability of the analysis may suffer. More constraints may apply to the dataset depends on the aims of analysis.

Now let's check what our dataset looks like by running `head(temp_data)`. We can see that the dataset is in a wide format, with months as separate columns. This structure is not ideal for time series analysis, where data should be in long format with a single date column. Also, we do not need columns such as `LON`, `LAT`, and `PARAMETER` are repeated and not provide valuable information. Moreover, the column names for months (JAN, FEB, etc.) use abbreviations, which need to be converted into numbers or used to generate a proper date. These can be done using the following code: 

```r
# Step 1: Reshape from wide to long format
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
  
```
Run the `head(temp_data)` again and see what it looks like now. Now it is in long format and has only two columns: `YEAR_MONTH` and `TEMPERATURE`.  This is a fairly simple dataset but ideal for time series analysis! Note that we haven't check if there is missing values in the dataset, we can do this by running the following code which count the number of missing values in the entire dataset:

```r
sum(is.na(temp_data))
```


It's 0! This means there is no missing value in our dataset. We are good to go!

# _Part II: Analyzing Time Series_
### 3. Visualization of data
We can start by displaying the temperature trends over time and see what the plot looks like. We can simply use the `ggplot()` to do this for us:
```r
ggplot(temp_data, aes(x = YEAR_MONTH, y = TEMPERATURE)) +
  geom_line() +
  labs(
    title = "Temperature Trends Over Time",
    x = "Year-Month",
    y = "Temperature"
  )
```

<center><img src="plots/Temperature_Trends_Over_Time.png" alt="Img" width="589"/></center>


We can clearly see that the temperature exhibits a clear seasonal pattern, with regular fluctuations that likely correspond to yearly changes (e.g., summer and winter cycles). The recurring peaks represent warmer months, while the troughs correspond to cooler months, highlighting predictable seasonal variability. Also, there does not appear to be a significant long-term upward or downward trend, suggesting relative stability in Edinburgh's average temperature from 2000 to the end of 2020. 

### 4. Decomposing Time Series:
The previous plot provides an overview of the temperature trends over time, showing clear seasonal fluctuations and variations. However, to better understand the underlying components—such as the overall trend, recurring seasonal patterns and random fluctuations, we can decompose the time series. Decomposition helps us isolate these components, enabling a more detailed analysis of the data. Using the `forecast` library, we can use the `objects` and `stl()` function, we can decompose our dataset:
```r
ts_data <- ts(temp_data$TEMPERATURE, start = c(2000, 1), frequency = 12)

# Apply STL decomposition (Seasonal and Trend decomposition)
decomposed_stl <- stl(ts_data, s.window = "periodic")
plot(decomposed_stl, main = "STL Decomposition of the Data")
```
The `ts` function converts our temperature data into a time series object and the `stl` function performs seasonal and trend decomposition (note that here we use `s.window = "periodic"` to assume a fixed seasonal pattern in the dataset). Run this chunk of code and we will get the plot below:

<center><img src="plots/STL_Decomposition.png" alt="STL Decomposition Plo" width="589"/></center>


There dataset is decomposed into the following four panels:
**- Data (Observed Time Series):** The top panel represents the original temperature data, which shows both seasonal patterns and an underlying trend. This is just what we have in Figure 1. 

**- Seasonal Component:** The second panel highlights the seasonal component, which is consistent across the years. The periodic fluctuations indicate clear seasonality in the dataset, with similar highs and lows repeating each year. This is typical for most temperature datasets, where warmer and cooler months recur annually.

**- Trend Component:** The third panel shows the trend component, which represents the long-term changes in temperature. There are periods of increase and decrease in temperature over the years, reflecting underlying climatic changes. Notably, around 2010-2015, there is a slight downward trend, but the trend appears to recover in recent years.

**- Remainder (Random Component):** The fourth panel shows the remainder (random) component, which captures noise or unexplained variations in the data. There are spikes and dips, suggesting anomalies or unusual events that deviate from the expected trend and seasonality of the dataset. These could be due to irregular climatic events such as heatwaves, cold snaps, or measurement errors.

In general, the trend component offers insights into long-term climatic changes, useful for climate modeling and environmental studies. Further more, the decomposition shows strong seasonality, which can be leveraged for accurate seasonal forecasting later.


### 5. Check important assumptions
There are some important assumptions to check before going to forecasting (eg, Stationarity, autocorrelation and Independence of Residuals...). In this tutorial, our main focus will be on the forecasting so we would not spend much time checking through all the assumptions. Here, we will only check two of the main assumptions: **Stationarity** and **Normality of Residuals** to show you how things work!

> ***_NOTE:_***  If you would like to know what each assumption is and how to check them using R, please refer to this amazing [Youtube video](https://www.youtube.com/watch?v=eTZ4VUZHzxw&t=204s)!

#### (a) Stationarity Check
Before we move to part III: Data forecasting, it is important to perform stationary check to our dataset. Stationarity is a fundamental assumption for many time series forecasting methods. A stationary series will show constant mean and variance over time, with no visible trend or seasonality. In our case, we will be using looking at rolling mean and rolling standard deviations. These metrics are computed over a moving window (or "rolling window") of data points. The window slides through the dataset, recalculating the mean or standard deviation for each new position. Here we set the k = 12 for the rolling windows because 12 months is a year. 
A way to check this is to use the rolling mean and standard deviation from the `zoo` library. 
```r
# Compute rolling mean and standard deviation
roll_mean <- zoo::rollmean(temp_data$TEMPERATURE, k = 12, fill = NA)
roll_sd <- zoo::rollapply(temp_data$TEMPERATURE, width = 12, FUN = sd, fill = NA)
```

Then we can visualize it to see if they change over time by running the following code:
```r
plot(temp_data$TEMPERATURE, type = "l", col = "blue", ylab = "Temperature", xlab = "Number of Month from 2000")
lines(roll_mean, col = "red", lty = 2)  # Rolling mean
lines(roll_sd, col = "green", lty = 2)  # Rolling standard deviation
legend("topright", legend = c("Original", "Rolling Mean", "Rolling SD"), col = c("blue", "red", "green"), lty = c(1, 2, 2))
```

Here is the plot, what can we tell from it?

<center><img src="plots/Stationarity_Check.png" alt="Img" width="589"/></center>

We can see clearly from the plot that the rolling mean indicates a generally consistent trend over time, with some slight variations in its level. The rolling standard deviation is also relatively stable but appears to fluctuate slightly, particularly around certain periods (e.g., after 100 on the x-axis). However, the rolling mean and the rolling standard deviations are all generally constant. This suggests our dataset is mostly stable but may still have non-stationary components, likely because of the seasonal patterns of the data. 

{% capture callout %}

Try `print(roll_mean)` and `print(roll_sd)`, why is there 5 `NA` values at the beginning and the end of them? Hint: think about why we need the `fill = NA` argument when we were computing the rolling mean and rolling standard deviaton.
  
{% endcapture %}
{% include callout.html content=callout colour=alert %}


The Answer is that: The `zoo::rollmean` function in R calculates the moving average with a specified window size k. When you specify `k = 12`, it calculates the mean over a rolling window of 12 data points. A window size of 12 means that the function requires 12 data points to calculate the first value of the moving average. For the first and last 5 points in your dataset, there aren't enough data points to form a complete window of size 12, and that is why we need to `fill = NA` argument! The `fill = NA` argument ensures that where there aren't enough data points to calculate the moving average, `NA` is inserted instead of a numeric value.

### Another (rather formal) way to check stationarity
If you are a math person and feel like looking at the mean and variance visually is not convincing enough, there are several formal ways to reduce your concerns! One of them is the `Augmented Dickey-Fuller (ADF) Test` from the  `tseries` library which checks whether a time series is stationary or not. We can perform the test using the following code

```r
adf.test(temp_data$TEMPERATURE, alternative = "stationary")

```

The test statistic is `-11.987`. This value is compared with critical values from the Dickey-Fuller table. A very negative test statistic (as in this case) strongly indicates that the null hypothesis can be rejected. The null hypothesis assumes that this time series is non-stationary (it has a unit root). Since the p-value is very small (smaller than common significance levels 0.5), we can reject the null hypothesis that is time series it not stable.

#### (b) Normality of Residual Check
Another important assumption to check is the Normality of Residual. Two easy ways to check this is through a histogram of residuals and a Q-Q plot, which can be done easily by the following code:
```
# Check Normality (Histogram)
hist(residuals, main = "Histogram of Residuals", xlab = "Residuals")
```
```
# Check Normality (Q-Q plot)
qqnorm(residuals)
qqline(residuals, col = "red")
```
Here are the outcomes:

<center><img src="plots/two_plots_his_QQ.png" alt="Img" width="589"/></center>

Both plots look good. The histogram on the left shows that the residuals are approximately symmetrically distributed, resembling a normal distribution with a peak near zero. The Q-Q plot on the right further confirms normality, as most points align closely with the red diagonal line, indicating that the residuals follow a theoretical normal distribution. We are good to move to the forecasting now!


# _Part III: Forecasting_

Now that we’ve prepared and analyzed our time series data, it’s time to build a forecasting model and generate future predictions! In this section, we will:

**- Select an appropriate forecasting model.** 

**- Generate forecasts for future time points.** 

**- Evaluate the model's performance.** 

**- Visualize and interpret the forecast results.** 


### 6. Select an appropriate forecasting model.
The first step in forecasting is selecting the right model. For this tutorial, we’ll use the ARIMA (Auto-Regressive Integrated Moving Average) model, as it is versatile and works well for time series data with trends and seasonality. Good news for us, R provides the `auto.arima()` function from the `forecast` library, which automatically selects the best ARIMA model for the data by optimizing the parameters:

```
# Automatically find the best ARIMA model
best_ARIMA_model <- auto.arima(temp_data$TEMPERATURE, seasonal = TRUE)
```
Now run `summary(best_ARIMA_model)`. This will display the selected model's details, including its parameters and diagnostic information. 
```
# Display the model summary
summary(best_model)
```
If you have never used ARIMA model before, this table may looks confusing to you. Let's break it down!

#### (a). `ARIMA(5,0,0)`:

- ARIMA(p,d,q) refers to the number of autoregressive terms (p), the degree of differencing (d), and the moving average terms (q). In our case:
  - **`p=5`:** The model includes five autoregressive terms, meaning the current value is influenced by the previous five values in the series.
  - **`d=0`:**  No differencing was applied, indicating that the series was stationary without the need for transformation.
  - **`q=0`:** There are no moving average terms in the model.

#### (b). Coefficients:

- The table lists the coefficients for the autoregressive terms (**ar1** to **ar5**) and the overall **mean**:
  - **`ar1 = 0.7249`**: Indicates a strong positive relationship between the current value and the first lag.
  - **`ar2 = -0.0231`**: Shows a very weak negative relationship between the current value and the second lag.
  - **`ar3, ar4, ar5`**: These terms show progressively weaker relationships, with some negative contributions.
  - **`mean = 8.4191`**: The average value of the series, which is included because the series has a non-zero mean.
  
- The **`standard errors (s.e.)`** for the coefficients indicate the uncertainty associated with each estimate. Smaller standard errors suggest more reliable estimates.

#### (c). Variance and Information Criteria

- **`Sigma^2`**: The estimated variance of the residuals, which is 1.547. A lower value generally indicates better model fit.

- **`Log-Likelihood`**: The log of the likelihood function for the fitted model is -451.16. This is used to calculate the information criteria.

- **`AIC` (Akaike Information Criterion) = 916.32**: AIC measures the quality of a statistical model by balancing its fit to the data and its complexity. Lower AIC values normally indicate a better model because it suggests a good balance between model accuracy and simplicity.

- **`BIC` (Bayesian Information Criterion) = 941.66**: Similar to AIC, BIC also balances model fit and complexity but penalizes complexity more heavily than AIC.
  - These are measures of model fit, where lower values indicate a better model. We can compare these values with other models to select the best one if necessary. 

#### (d). Training Set Error Measures

The table provides several error metrics for the training set:

- **`ME` (Mean Error)**: -0.00621183
  - Indicates the average bias of the residuals. A value close to 0 suggests the model is unbiased.

- **`RMSE` (Root Mean Squared Error)**: 1.230134
  - Measures the average magnitude of error. A lower value indicates a better model fit.

- **`MAE` (Mean Absolute Error)**: 0.9750409
  - Similar to RMSE but less sensitive to outliers.

- **`MPE` (Mean Percentage Error)**: -0.2009136
  - Indicates the average percentage error. Negative value shows slight underestimation.

- **`MAPE` (Mean Absolute Percentage Error)**: 20.80954
  - Indicates the average absolute percentage error. A MAPE of ~20% is considered moderate; better models typically have MAPE < 10%.

- **`MASE` (Mean Absolute Scaled Error)**: 0.4741914
  - Scales the MAE to make it comparable across datasets. A value < 1 suggests the model performs better than a naive forecast.

- **`ACF1` (Autocorrelation of Residuals at Lag 1)**: -0.0540435
  - Indicates almost no autocorrelation at lag 1, which is a good sign of well-behaved residuals.

### 7. Generate forecasts for future time points.
### (a). Forecasting the temperature next year (the next 12 months)
Now that we have our ARIMA model and we have ideas of what each value represents, we can forecast temperature for the next 12 months! We can do this using the following code:
```r
# Forecast for the next 12 months, `h` here set teh forecast horizon to 12 month (5 years)
forecasted_12month <- forecast(best_model, h = 12)

# Display the forecast summary if you want
# print(forecasted_12month)

# Generate yearly labels based on the range of your data
years <- seq(2000, 2024, by = 1)  # Adjust the range to include the forecast horizon

# Plot the forecast without the default x-axis because the the default x-axis is 'month'
plot(forecasted_12month, xaxt = "n", main = "Temperature Forecast", ylab = "Temperature", xlab = "Year")

# Add custom x-axis labels with yearly intervals
axis(1, at = seq(1, length(temp_data$TEMPERATURE) + 24, by = 12), labels = years)

```
By running this chunk of code, you should get the following plot:

<center><img src="plots/forecasted_12month.png" alt="forecast 12months" width="589"/></center>

We can see that the plot shows clear seasonal patterns in the temperature data. The forecast (blue line) continues the seasonal pattern into the future (12 months). The shaded area around the forecast represents the prediction intervals, showing the range of uncertainty in the forecast:

- The inner shaded region represents the **80% confidence interval**.

- The outer shaded region represents the **95% confidence interval**.

The smooth continuation of seasonal cycles suggests the ARIMA model captures the underlying patterns well.

### (b)  (Optional) Compare the forecasted temperature with real-world temperature
For those of you who are really curious about how accurate this model is, we can try to fit the data of the true temperature in 2023 in Edinburgh to this model. We can extract this data using similar to what we did at the first place!
Firstly, let's get the dataset from **NASAPOWER**
```r
### Get dataset of 2023
temp_data_2023 <- get_power(
  community = "AG",
  lonlat = c(-3.1883,55.9533),   # Edinburgh's Longitude and Latitude
  pars = "T2M",      # Temperature at 2 meters
  temporal_api = "daily",
  dates = c("2023/01/01", "2023/12/31")
)
# Get the mean temperature of each month
Montly_2023_data <- temp_data_2023 %>%
  group_by(YEAR, MM) %>%
  summarise(TEMPERATURE = mean(T2M, na.rm = TRUE))
```
Then we can fit the true temperature into our forecating plot using the following code:
```
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
```
Here is what the plot looks like now:
<center><img src="true_with_forecasted_12month.png" alt="forecast 12months with true data" width="589"/></center>

We can see that our prediction of the monthly temperature in 2023 fits the real-life temperatures very well!

### (c). (Optional) Forecasting the temperature next 5 years (the next 60 months)



### 8. Evaluate the model's performance.
### 9. Visualize and interpret the forecast results.

