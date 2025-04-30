# odinaka541



import pandas as pd, numpy as np, yfinance as yf, matplotlib.pyplot as plt
from datetime import datetime, timedelta
from sklearn.linear_model import LinearRegression

from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score



# ----------- data collection and preparation, features engineering ----------
# fetching historical stock price data for GOOGL
google_data = yf.download(
    'GOOGL', start = datetime.now() - timedelta(days = 365 * 4), end = datetime.now(), auto_adjust = False
)
# renaming columns for clarity
google_data = google_data.rename(columns = {'Adj Close': 'Adjusted'})

# removing unnecessary columns: 'High', 'Low', 'Open'
google_data_cleaned = google_data.drop(['High', 'Low', 'Open'], axis = 1)

# engineering some features we'll need in our simple regression model
google_data_cleaned['MA_10'] = google_data_cleaned['Adjusted'].rolling(window = 10).mean()
google_data_cleaned['MA_200'] = google_data_cleaned['Adjusted'].rolling(window = 200).mean()

google_data_cleaned['Log Returns'] = np.log10(
    google_data_cleaned['Adjusted'] / google_data_cleaned['Adjusted'].shift(1)
)

google_data_cleaned['lag1'] = google_data_cleaned['Log Returns'].shift(1)
google_data_cleaned['lag2'] = google_data_cleaned['Log Returns'].shift(2)
google_data_cleaned['lag3'] = google_data_cleaned['Log Returns'].shift(3)

google_data_cleaned['rolling_volatility_20'] = google_data_cleaned['Log Returns'].rolling(window = 20).std()
google_data_cleaned['rolling_volatility_50'] = google_data_cleaned['Log Returns'].rolling(window = 50).std()
google_data_cleaned['rolling_volatility_200'] = google_data_cleaned['Log Returns'].rolling(window = 200).std()

# clean the data even more by dropping na values
google_data_cleaned = google_data_cleaned.dropna()




# ---------- visualization ----------
google_data_cleaned[['rolling_volatility_20', 'rolling_volatility_50', 'rolling_volatility_200']].plot(
    figsize = (10, 6),
    color = ['orange', 'green', 'red']
)
plt.title('RV against time')
plt.xlabel('Date')
plt.ylabel('Volatility')
plt.grid(True)
# plt.show()



# ---------- correlation analysis ----------
cor_rolling_volatilities = google_data_cleaned[['Log Returns', 'rolling_volatility_20', 'rolling_volatility_50', 'rolling_volatility_200']].corr()
cor_moving_averages = google_data_cleaned[['Log Returns', 'MA_10', 'MA_200']].corr()



# ---------- model evaluation ----------
# define variables and set seed sample
X = google_data_cleaned[['MA_10', 'MA_200', 'rolling_volatility_20', 'rolling_volatility_50', 'rolling_volatility_200']]
y = google_data_cleaned['Adjusted']

# split the data into test_data and train_data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size = 0.2, random_state = 25
)

# train model
model = LinearRegression()
model.fit(X_train, y_train)

# make prediction
y_pred = model.predict(X_test)

# check for accuracy and optimize
r2 = r2_score(y_test, y_pred)
print(f"R^2 score is {r2}")

rmse = np.sqrt(np.mean((y_pred - y_test) ** 2))
print(f"RMSE: {rmse}")
# print("Intercept: ", model.intercept_)
# print("Coefficient: ", model.coef_)

# visualizing the actual vs predicted returns
plt.figure(figsize = (10, 6))
plt.plot(y_test.index, y_test, label = 'Actual Adjusted Close Price', color = 'blue')
plt.plot(y_test.index, y_pred, label = 'Predicted Adjusted Close Price', color = 'red', linestyle = '--')
plt.legend()
plt.title('Actual vs Predicted Daily Returns')
# plt.show()




# ----------- outputs -----------

pd.set_option('display.max_columns', None)
print(google_data_cleaned)

# print(cor_rolling_volatilities)
# print(cor_moving_averages)

print("actual: ", y_test.head())
print("predicted: ", y_pred[:5])