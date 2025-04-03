# ---------- building the Shiny App Interface


# load the necessary libraries
library(shiny)



ui <- fluidPage(
  titlePanel("Google Stock Price Prediction"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("rolling_volatility_20", "20-Day Rolling Volatility", value = 0.02, min = 0, step = 0.01),
      numericInput("rolling_volatility_50", "50-Day Rolling Volatility", value = 0.03, min = 0, step = 0.01),
      numericInput("rolling_volatility_200", "200-Day Rolling Volatility", value = 0.04, min = 0, step = 0.01),
      numericInput("MA_10", "10-day Moving Average", value = 0, min = 0, step = 0.01),
      numericInput("MA_200", "200-day Moving Average", value = 0, min = 0, step = 0.01),
      
      actionButton("predict_btn", "Predict Stock Price")
    ),
    
    mainPanel(
      textOutput("prediction"),
      plotOutput("p_a_plot")
    )
  )
)


# ---- building the server-side logic
server <- function(input, output) {
  
  
  # when button is clicked, it triggers a reaction
  observeEvent(input$predict_btn, {
    # collects the input data from the UI
    
    new_data <- data.frame(
      rolling_volatility_20 = as.numeric(input$rolling_volatility_20),
      rolling_volatility_50 = as.numeric(input$rolling_volatility_50),
      rolling_volatility_200 = as.numeric(input$rolling_volatility_200),
      MA_10 = as.numeric(input$MA_10),
      MA_200 = as.numeric(input$MA_200)
    )
    
    # making and adding the prediction
    prediction <- predict(model, newdata = new_data)
    
    
    # outputting the predicted price using the loaded model
    output$prediction <- renderText({
      paste("Predicted Stock Price: $", round(prediction, 2))
    })
    output$p_a_plot <- renderPlot({
      ggplot(predicted_vs_actual_control, aes(x = Date)) +
        geom_line(aes(y = Actual, colour = "Actual Price"), linewidth = 1) +
        geom_line(aes(y = Prediction, colour = "Predicted Price"), linetype = "dashed", linewidth = 1) +
        labs(title = "Actual vs Predicted Price", x = "Date", y = "Stock Price", colour = "Legend") +
        theme_minimal()
    })
  })
}