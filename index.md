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
6. Building Forecasting Models:
a) Introduction to ARIMA models and their suitability for environmental data.
b) Automatically selecting the best model with auto.arima.

7. Generating Predictions:
a) Forecasting future values and confidence intervals.
b) Plotting and interpreting forecasts.

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
This is what the plot looks like:
<table align="center">
  <tr>
    <td>
      <img src="https://github.com/EdDataScienceEES/tutorial-ChenRunlin0718/blob/master/plots/Temperature_Trends_Over_Time.png" alt="Temperature trend" width="700"/>
      <p><em>Figure 1: Temperature trend over time</em></p>
    </td>
  </tr>
</table>

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

<table align="center">
  <tr>
    <td>
      <img src="https://github.com/EdDataScienceEES/tutorial-ChenRunlin0718/blob/master/plots/STL_Decomposition.png" alt="STL Decomposition Plot" width="700"/>
      <p><em>Figure 2: STL Decomposition Plot</em></p>
    </td>
  </tr>
</table>

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
<table align="center">
  <tr>
    <td>
      <img src="https://github.com/EdDataScienceEES/tutorial-ChenRunlin0718/blob/master/plots/Stationarity_Check.png" alt="Stationarity_Check" width="700"/>
      <p><em>Figure 3: Stationarity Check</em></p>
    </td>
  </tr>
</table>

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
<table align="center">
  <tr>
    <td>
      <img src="https://github.com/EdDataScienceEES/tutorial-ChenRunlin0718/blob/master/plots/two_plots_his_QQ.png" alt="Histogram and Q-Q plot" width="700"/>
      <p><em>Figure 4: Histogram and Q-Q plot</em></p>
    </td>
  </tr>
</table>
Both plots look good. The histogram on the left shows that the residuals are approximately symmetrically distributed, resembling a normal distribution with a peak near zero. The Q-Q plot on the right further confirms normality, as most points align closely with the red diagonal line, indicating that the residuals follow a theoretical normal distribution. We are good to move to the forecasting now!


# _Part III: Forecasting_










```{r, echo=FALSE, results='asis'}
cat('
<div class="callout {{ include.colour }}">
    <p>Your content goes here.</p>
</div>
')
```






