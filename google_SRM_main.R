# odinaka541





# load (or install) required packages
required_packages <- c(
  "tidyverse", "quantmod", "tseries", "lmtest", "dplyr", "tibble", "TTR", "ggplot2", "plumber", "shiny"
)

lapply(required_packages, library, character.only = T)





# ---------- data collection and preparation, features engineering ----------
# fetch historical data for GOOG
getSymbols(
  "GOOG", src = "yahoo", from = Sys.Date() - 365 * 4, to = Sys.Date()
)

# convert default xts object to tibble and engineer some features
google_data_cleaned <- as_tibble(data.frame(Date = index(GOOG), coredata(GOOG))) |> 
  select(-c(GOOG.Open, GOOG.High, GOOG.Low)) |> # removing columns we don't need in model
  rename(Adjusted = GOOG.Adjusted, Volume = GOOG.Volume, Close = GOOG.Close) |> 
  mutate(
    MA_10 = SMA(Adjusted, n = 10), # 10-day moving average
    MA_200 = SMA(Adjusted, n = 200), # 200-day moving average
    
    `Log Return` = log10(Adjusted / lag(Adjusted)), # daily returns
    
    lag1 = lag(`Log Return`), 
    lag2 = lag(`Log Return`, n = 2),
    lag3 = lag(`Log Return`, n = 3),
    
    rolling_volatility_20 = rollapply(`Log Return`, width = 20, FUN = sd, fill = NA, align = "right"),
    rolling_volatility_50 = rollapply(`Log Return`, width = 50, FUN = sd, fill = NA, align = "right"),
    rolling_volatility_200 = rollapply(`Log Return`, width = 200, FUN = sd, fill = NA, align = "right")
  ) |> 
  na.omit(google_data_cleaned) # cleans the dataframe by removing NA values



# ---------- visualization ----------
# date vs rolling volatilities
ggplot(google_data_cleaned, aes(x = Date)) +
  geom_line(aes(y = rolling_volatility_20, colour = "20-day Volatility")) +
  geom_line(aes(y = rolling_volatility_50, colour = "50-day Volatility")) +
  geom_line(aes(y = rolling_volatility_200, colour = "200-day volatility")) +
  labs(title = "Rolling Volatility over Time", x = "Date", y = "Rolling VOlatility", colour = "Window Size") +
  theme_minimal()



# ---------- correlation analysis ----------
cor_moving_averages <- google_data_cleaned |> 
  select(`Log Return`, MA_10, MA_200) |> 
  cor(use = "complete.obs") |> 
  as_tibble(rownames = "Variables")

cor_volatility_returns <- google_data_cleaned |> 
  select(`Log Return`, rolling_volatility_20, rolling_volatility_50, rolling_volatility_200) |> 
  cor(use = "complete.obs") |> 
  as_tibble(rownames = "Variable")
# moving averages and volatility returns show strong correlations to the daily returns. we can use these features in our model.



# ---------- exploratory data analysis ----------
ggplot(google_data_cleaned, aes(x = `Log Return`)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "red", colour = "black", alpha = 0.7) +
  geom_density(colour = "blue", linewidth = 1) + 
  theme_minimal()



# ---------- time series analysis ----------
# a stationarity test helps test the reliability of the data we intend to use in our time series analysis
print(adf.test(google_data_cleaned$Adjusted)) # stationarity test is passed

ggplot(google_data_cleaned, aes(x = Date, y = Adjusted)) +
  geom_line() +
  geom_smooth() + 
  theme_minimal()



# ---------- model training -----------
# confirming standardization of data:
summary(google_data_cleaned)

# set seed sample to ensure reproducibility. train data
set.seed(25)
train_index <- sample(1:nrow(google_data_cleaned), size = 0.8 * nrow(google_data_cleaned))
train_data <- google_data_cleaned[train_index, ]
test_data <- google_data_cleaned[-train_index, ]

model <- lm(Adjusted ~ rolling_volatility_20 + rolling_volatility_50 + rolling_volatility_200 + MA_10 + MA_200, 
            data = train_data)



# ---------- model evaluation ----------
test_predictions <- predict(model, newdata = test_data)

train_rmse <- sqrt(mean((train_data$Adjusted - predict(model, newdata = train_data)) ^ 2))
test_rmse <- sqrt(mean((test_data$Adjusted - test_predictions) ^ 2))
r_squared <- summary(model)$r.squared
mape <- mean(abs((test_data$Adjusted - test_predictions) / test_data$Adjusted)) * 100

print(paste("Training RMSE:", round(train_rmse, 4)))
print(paste("Test RMSE:", round(test_rmse, 4)))
print(paste("R-squared:", round(r_squared, 4)))
print(paste("MAPE:", round(mape, 4)))


# storing the predictions
test_predictions_DF <- data.frame(Predicted = as.numeric(test_predictions))
prediction_control_data <- google_data_cleaned |> filter(Date >= (Sys.Date() - 7) & Date <= Sys.Date())
predicted_vs_actual <- data.frame(
  Date = google_data_cleaned$Date,
  Actual = google_data_cleaned$Adjusted,
  Prediction = test_predictions_DF$Predicted
)
predicted_vs_actual_control <- predicted_vs_actual |> 
  filter(Date >= (Sys.Date() - 100) & Date <= Sys.Date())
# it makes sense we don't have exact matches because of fundamental data and what not. 

# visualizing the actual vs predicted prices
predicted_vs_actual_plot <- ggplot(predicted_vs_actual_control, aes(x = Date)) +
  geom_line(aes(y = Actual, colour = "Actual Price"), linewidth = 1) +
  geom_line(aes(y = Prediction, colour = "Predicted Price"), linetype = "dashed", linewidth = 1) +
  labs(title = "Actual vs Predicted Price", x = "Date", y = "Stock Price", colour = "Legend") +
  theme_minimal()
  



