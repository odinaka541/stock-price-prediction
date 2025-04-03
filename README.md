Google Stock Price Prediction


This project is an R-based predictive model for forecasting Google's (GOOG) stock prices using historical data and key technical indicators. The model is integrated into a Shiny web application and a Plumber API for interactive predictions.


📌 Features

Data Collection & Feature Engineering: Fetches historical stock data from Yahoo Finance and computes indicators like moving averages and rolling volatility.

Exploratory Data Analysis (EDA): Visualizes stock trends, volatilities, and correlations.

Machine Learning Model: Uses a multiple linear regression model to predict future stock prices.

Evaluation Metrics: RMSE, R-squared, and MAPE for model performance assessment.

Interactive Web App: Built with Shiny for real-time stock price predictions.

REST API: Deployed using Plumber to provide stock price predictions programmatically.


🔧 Installation

Prerequisites

Ensure you have R and RStudio installed. You also need the following R packages:

install.packages(c("tidyverse", "quantmod", "tseries", "lmtest", "dplyr", "tibble", "TTR", "ggplot2", "plumber", "shiny"))

Clone the Repository

git clone https://github.com/yourusername/stock-prediction-r.git
cd stock-prediction-r


🚀 Usage

Running the Model

Run the script in RStudio to fetch stock data, train the model, and visualize results:

source("google_SRM_model.R")

Running the Shiny App

To launch the interactive web app:
library(shiny)
runApp("building_shinyApp.R")


Running the API

To deploy the API for stock price predictions:

library(plumber)
pr("google_SRM_api.R") %>% pr_run(port = 8000)


Test the API:

curl -X POST "http://localhost:8000/predict" -H "Content-Type: application/json" -d '{"rolling_volatility_20": 0.02, "rolling_volatility_50": 0.03, "rolling_volatility_200": 0.04, "MA_10": 173, "MA_200": 168}'
(The values are test data. You can change them.)

📊 Model Performance

Training RMSE: X.XXX

Test RMSE: X.XXX

R-squared: X.XXX

MAPE: X.XXX%


📌 File Structure

📂 stock-price-prediction
├── stock-price-prediction-r
├── google_SRM_main.R   # Main script for fetching data, training, and evaluation
├── building_shinyApp.R                 # Shiny web application
├── google_SRM_api.R               # REST API with Plumber
├── googleSRM.rds               # Saved trained model
├── README.md                   # Project documentation


📜 License

This project is licensed under the MIT License.


🤝 Contributing

Feel free to submit issues or pull requests for improvements!



