# shiny_app.py

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from shiny import App, render, ui
from sklearn.linear_model import LinearRegression

# Simulated Training Data (replace with your actual X_train and y_train)
# Ensure all numeric values are float64 and clean
X_train = pd.DataFrame({
    'ma_10': np.random.rand(100),
    'ma_200': np.random.rand(100),
    'rolling_volatility_20': np.random.rand(100),
    'rolling_volatility_50': np.random.rand(100),
    'rolling_volatility_200': np.random.rand(100)
})
y_train = pd.Series(np.random.rand(100) * 200 + 1000)  # Fake Google stock prices

# Train model
model = LinearRegression()
model.fit(X_train, y_train)

# --- UI ---
app_ui = ui.page_fluid(
    ui.panel_title("📈 Google Stock Price Predictor"),

    ui.layout_sidebar(
        ui.sidebar(
            ui.input_numeric("ma_10", "10-day Moving Average", value=0.5, step=0.01),
            ui.input_numeric("ma_200", "200-day Moving Average", value=0.5, step=0.01),
            ui.input_numeric("rolling_volatility_20", "20-day Rolling Volatility", value=0.02, step=0.01),
            ui.input_numeric("rolling_volatility_50", "50-day Rolling Volatility", value=0.03, step=0.01),
            ui.input_numeric("rolling_volatility_200", "200-day Rolling Volatility", value=0.03, step=0.01),
        ),

        ui.panel_main(
            ui.output_text_verbatim("prediction"),
            ui.output_plot("prediction_plot")
        )
    )
)

# --- SERVER ---
def server(input, output, session):

    def get_features():
        return np.array([[
            float(input.ma_10()),
            float(input.ma_200()),
            float(input.rolling_volatility_20()),
            float(input.rolling_volatility_50()),
            float(input.rolling_volatility_200())
        ]])

    @output
    @render.text
    def prediction():
        features = get_features()
        predicted = model.predict(features)[0]
        return f"📊 Predicted Google Stock Price: ${predicted:.2f}"

    @output
    @render.plot
    def prediction_plot():
        # Actual vs Predicted (Training Data)
        y_actual = y_train.astype("float64")
        y_pred = model.predict(X_train).astype("float64")

        plt.figure(figsize=(10, 5))
        ax = plt.gca()

        ax.scatter(y_actual, y_pred, color='dodgerblue', alpha=0.6, label='Model Predictions')

        min_val = min(y_actual.min(), y_pred.min())
        max_val = max(y_actual.max(), y_pred.max())
        ax.plot([min_val, max_val], [min_val, max_val], 'gray', linestyle='--', label='Perfect Prediction')

        ax.set_xlabel("Actual Stock Price")
        ax.set_ylabel("Predicted Stock Price")
        ax.set_title("Actual vs Predicted Prices (Training Set)")
        ax.legend()
        ax.grid(True)

        return plt

# --- RUN APP ---
app = App(app_ui, server)
