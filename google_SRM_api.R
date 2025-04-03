# odinaka51

# ---------- deploying the model ----------
saveRDS(model, "googleSRM.rds")

# to load the model 
loaded_model <- readRDS("googleSRM.rds")

# confirming consistency of data
summary(loaded_model)


#* @apiTitle Google Stock Price Prediction API
#* @param rolling_volatility_20: 20-day rolling volatility
#* @param rolling_volatility_50: 50-day rolling volatility
#* @param rolling_volatility_200: 200-day rolling volatility
#* @param MA_10: 10-day moving average
#* @param MA_200: 200-day moving average
#* @post /predict


# building the API function
predict_price <- function(rolling_volatility_20, rolling_volatility_50, rolling_volatility_200, MA_10, MA_200) {
  
  new_data <- tryCatch({ 
    data.frame(
    rolling_volatility_20 = as.numeric(rolling_volatility_20),
    rolling_volatility_50 = as.numeric(rolling_volatility_50),
    rolling_volatility_200 = as.numeric(rolling_volatility_200),
    MA_10 = as.numeric(MA_10),
    MA_200 = as.numeric(MA_200)
    )
  }, error = function(e) {
      return(list(error = "Invalid input data"))
  })
  

if ("error" %in% names(new_data)) {
  return(new_data)
}
  
  
  prediction <- predict(model, newdata = new_data)
  return(list(predicted_price = prediction))
}
