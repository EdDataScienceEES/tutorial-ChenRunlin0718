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

a) Handling missing values with _drop_na()_ and imputation techniques.
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
Time series data are sequential data points collected over time. In environmental science, these could be measurements like temperature, rainfall, species population counts, or carbon dioxide levels. Time series analysis allows us to detect trends, seasonality, and anomalies, predict future values, and understand temporal dynamics of environmental processes. In this tutorial, you’ll learn the basics of time series analysis, including data preprocessing, visualization, decomposition, and basic forecasting techniques, all within the context of environmental data.

# _Part I_
## Data Wrangling
In this tutorial, we will use a dataset obtained from the *NASA POWER API*, a tool that provides climate data from NASA's Prediction of Worldwide Energy Resource (POWER) project. Specifically, we will use monthly temperature data (measured at 2 meters above the ground) of Edinburgh (by using Edinburgh's location coordinates: Longitude: 3.1883°W & Latitude: 55.9533°N) for the years 2000 to 2022. 
We first download the relevant packages and load the dataset from *NASA POWER API* using the following code:
```r
library(ggplot2)
library(forecast)
library(dplyr)

```


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


