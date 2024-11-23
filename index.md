---
title: 'Tutorial: Introduction to time Series Analysis for Environmental Data'
author: "Runlin Chen"
date: "2024-11-21"
output: html_document
---

# Tutorial aims 

1. Understand the fundamentals of time series analysis and its applications in environmental data.
2. Learn how to preprocess, visualize, and decompose time series datasets for meaningful insights.
3. Gain hands-on experience with forecasting techniques to predict trends in environmental data.
4. Develop skills in using R and relevant packages for analyzing time series data effectively.

# Tutorial steps
1. Introduction.
### Part I: Data Preparation and Exploration
2. Data wrangling:

a) Load the relevant libraries and dataset.
a) Handling missing values with *drop_na()* and imputation techniques.
b) Formatting date variables using lubridate.
c) Filtering and subsetting time periods for analysis.
3. Exploring the data.

### Part II: Analyzing Time Series
4. Decomposing Time Series:
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

## Introduction
Time series data are sequential data points collected over time. In environmental science, these could be measurements like temperature, rainfall, species population counts, or carbon dioxide levels. Time series analysis allows us to detect trends, seasonality, and anomalies, predict future values, and understand temporal dynamics of environmental processes. In this tutorial, you’ll learn the basics of time series analysis, including data preprocessing, visualization, decomposition, and basic forecasting techniques.

In part 1, we will be working with a dataset from *NASA* that captures the temperature of earth and try to do some data wrangling with it to make it easier for later analysis. In part 2, we will look into some basic and fundamental techniques that can be used to deal with time series data. In part 3, things are going to get interesting because we are going to build a forecasting Models that is able to predict the temperature in the future. 

{% capture callout %}
Note that this tutorial will assume that you already have previous experience with R and familiar with basic operations of R such as _%>%_ and _summarise()_. If not, Coding Club has got you covered: check out the [Intro to R tutorial](https://ourcodingclub.github.io/tutorials/intro-to-r/)!
{% endcapture %}
{% include callout.html content=callout colour=alert %}



# _Part I_
## Data Wrangling
### a) Load the dataset
In this tutorial, we will use a dataset obtained from the **NASA POWER API**, a tool that provides climate data from NASA's Prediction of Worldwide Energy Resource (POWER) project. Specifically, we will use monthly temperature data (measured at 2 meters above the ground) of Edinburgh (by using Edinburgh's location coordinates: Longitude: 3.1883°W & Latitude: 55.9533°N) for the years 2000 to 2022. 
We first download the relevant packages using the following code:
```
# relevant packages
library(ggplot2)
library(forecast)
library(dplyr)
library(nasapower)
library(lubridate)
```

Now let's load the dataset and name it *'temp_data'*. Note that we want the location to be Edinburgh so we need to enter Edinburgh's coordinate of location. 

```
temp_data <- get_power(
  community = "AG",
  lonlat = c(-3.1883,55.9533),   # Edinburgh's Longitude and Latitude
  pars = "T2M",      # Temperature at 2 meters
  temporal_api = "monthly",
  dates = c("2000", "2022")
)
```

### b) Clean and organize the dataset










{{ $id := substr (sha1 .Inner) 0 8 }}
<div class="gdoc-expand">
  <label class="gdoc-expand__head flex justify-between" for="{{ $id }}-{{ .Ordinal }}">
    <span>{{ default "Expand" (.Get 0) }}</span>
    <span>{{ default "↕" (.Get 1) }}</span>
  </label>
  <input id="{{ $id }}-{{ .Ordinal }}" type="checkbox" class="gdoc-expand__control hidden" />
  <div class="gdoc-markdown--nested gdoc-expand__content">
    {{ .Inner | $.Page.RenderString }}
  </div>
</div>


