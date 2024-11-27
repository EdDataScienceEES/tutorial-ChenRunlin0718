[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/6eRt7-90)

## Tutorial - Runlin Chen (s2153060)
The aim of this tutorial is to provide a comprehensive and approachable guide to time series analysis and forecasting using temperature data in Edinburgh. This tutorial is designed for advanced undergraduate or early graduate students in Environmental or Ecological Sciences who are looking to enhance their data science skills. By the end of this tutorial, learners will:

- Understand the fundamental concepts of time series analysis, including decomposition, stationarity, and autocorrelation.
- Gain hands-on experience in using R to preprocess, analyse, and forecast time series data.
- Learn how to assess and improve model performance and interpret forecasting results effectively.
- Apply these techniques to real-world problems to understand climate trends and predict environmental changes.

## Table of Contents
- To the website - [index.html](/index.html)
- To the MarkDown - [index.md](/index.md)
- To the coding - [code](/test.R)
- Plots - [Plot image outputs](/plots)

# Tutorial steps
#### 1. Introduction

### Part I: Data Preparation and Exploration
#### 2. Data Preparation
a) Load the dataset.
b) Clean and organise the dataset.

### Part II: Analyzing Time Series and Assumptions Check
#### 3. Visualization of data

#### 4. Decomposing Time Series

#### 5. Check important assumptions
a) Stationarity Check
b) Normality of Residual Check

### Part III: Forecasting

#### 6. Select an appropriate forecasting model

#### 7. Generate forecasts
a) Forecasting the temperature next year (the next 12 months)
b) (Optional) Compare the forecasted temperature with real-world temperature

#### 8. Evaluate the model's performance

#### 9. (Optional) Forecasting the temperature for the next 5 years (the next 60 months)

### (Optional) Part IV: Challenges
#### 10: Analyse whether there is a long-term trend in the temperature data and assess its impact on the forecasting model

## Next Steps from this tutorial
- **Explore Advanced Models:** Now that you’re familiar with ARIMA, try exploring other advanced forecasting models such as:
  - **Prophet:** A flexible and robust model designed for handling seasonal data with holiday effects. Check out the `prophet` package in R.
  - **TBATS:** Useful for handling complex seasonal patterns and multiple seasonalities.

- **Apply to Real-World Problems:** Use time series analysis to explore datasets from your field of interest, such as rainfall patterns, biodiversity monitoring, or energy consumption data.

- **Learn Forecasting Beyond ARIMA:** Dive into machine learning techniques like Long Short-Term Memory (LSTM) networks for time series forecasting.




---
# tutorial-instructions
## Instructions for Tutorial Assignment

The key final assignment for the Data Science course is to create your own tutorial. Your tutorial has to communicate a specific quantitative skill - you can choose the level at which you pitch your tutorial and how advanced or introductory it is. You can create "part 2" tutorials where "part 1" is an existing Coding Club tutorial.

You are encouraged to add your peers to your tutorial development repositories so that you can exchange feedback - remember that the best way to check if your tutorial makes sense is to have someone that is not you go through it.

__Note that the deadline for this challenge is 12pm on 28th November 2024. Submission is via GitHub like with previous challenges, but you have to also submit a pdf version of your tutorial via Turnitin before 12pm on 28th November 2024. Your submission on GitHub will represent a repository that is also a website (the tutorial on making tutorials below explains how to turn a GitHub repo into a website) and you can just save a pdf of your website using `File/Export as pdf` when you've opened your repository website, you don't need to be separately generating a pdf through code unless you want to.__

__Marking criteria:__

•	Topic – A relevant topic and content that is appropriate for a Coding Club tutorial and relevant to the field of data science, plus appropriate for learners at a particular skill level - at least 4th year Environmental / Ecological science student. - 25%

•	Structure – Clear and logical structure to the tutorial that is easy to navigate with clear instructions. Clear, concrete and measurable learning objectives (i.e., people can tell exactly what they are learning and when they have achieved each learning objective). - 25%

•	Reproducibility – People can do the tutorial on their own, without assistance and without needing to pay for extra software, the code works and people can easily access any data needed to complete the tutorial. - 25%

•	Creativity – A well-illustrated, professionally designed tutorial with appropriate figures and diagrams. A creative and engaging approach to teaching the learning objectives. - 25%

__Useful links:__
- https://ourcodingclub.github.io/tutorials/tutorials/ - Coding Club tutorial on how to make tutorials
- https://ourcodingclub.github.io/tutorials/ - all the other Coding Club tutorials
- https://github.com/ourcodingclub/ourcodingclub.github.io - the repository behind the Coding Club website - here you can see the Markdown code for how the tutorials were formatted
- https://rstudio.com/wp-content/uploads/2015/02/rmarkdown-cheatsheet.pdf - markdown cheatsheet

__Absolute top of the class examples of tutorials made by DS students:__
- https://ourcodingclub.github.io/tutorials/data-manip-creative-dplyr/ - Advanced data manipulation: Creative use of diverse dplyr functions by Jakub Wieczorkowski
- https://ourcodingclub.github.io/tutorials/data-scaling/ - Transforming and scaling data by Matus Seci
- https://ourcodingclub.github.io/tutorials/anova/ - ANOVA from A to (XY)Z by Erica Zaja
- https://ourcodingclub.github.io/tutorials/spatial-vector-sf/ - Geospatial vector data in R with sf by Boyan Karabaliev
- https://eddatascienceees.github.io/tutorial-assignment-beverlytan/ - Creating a repository with a clear structure by Beverly Tan
- https://ourcodingclub.github.io/tutorials/spatial/ - Intro to Spatial Analysis in R by Maude Grenier

All the other useful links we have shared with previous challenges and from the course reading - think of the tutorials you have done in the past - what did you like about those tutorials, what didn't work so well and could be improved. 

