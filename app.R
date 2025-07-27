library(shiny)
library(tidyverse)
library(dlm)
library(lubridate)

# Load polling data
polls <- read_csv("data/india_2024_weighted_polls.csv")

# List of parties
parties <- c("BJP", "INC", "AAP", "Others")

# Kalman model builder
build_kalman_model <- function(par) {
  dlmModPoly(order = 1, dV = exp(par[1]), dW = exp(par[2]))
}

# Safe Kalman filter function for one party
apply_kalman_filter <- function(df, party) {
  agg <- df %>%
    group_by(date) %>%
    summarize(
      raw_vote = weighted.mean(.data[[party]], weight_total),
      .groups = 'drop'
    ) %>%
    arrange(date)
  
  ts_data <- ts(agg$raw_vote)
  
  # Fit model
  fit <- tryCatch({
    dlmMLE(ts_data, parm = c(0, 0), build = build_kalman_model)
  }, error = function(e) {
    warning(paste("MLE failed for", party, ":", e$message))
    return(NULL)
  })
  if (is.null(fit)) return(NULL)
  
  model <- build_kalman_model(fit$par)
  filtered <- tryCatch({
    dlmFilter(ts_data, model)
  }, error = function(e) {
    warning(paste("Kalman filter failed for", party, ":", e$message))
    return(NULL)
  })
  if (is.null(filtered)) return(NULL)
  
  # Compute variances safely
  variances <- sapply(2:length(filtered$U.S), function(i) {
    u <- filtered$U.S[[i]]
    d <- filtered$D.S[[i]]
    if (is.null(u) || is.null(d)) return(NA)
    tryCatch({
      var_matrix <- dlmSvd2var(u, d)
      var_matrix[1, 1]
    }, error = function(e) NA)
  })
  
  # Final output
  agg <- agg %>%
    mutate(
      party = party,
      smoothed = drop(filtered$m[-1]),
      lower = smoothed - 1.96 * sqrt(variances),
      upper = smoothed + 1.96 * sqrt(variances)
    )
  
  return(agg)
}

# Apply Kalman filter to multiple parties
apply_kalman_all_parties <- function(df, selected_parties) {
  results <- lapply(selected_parties, function(p) apply_kalman_filter(df, p))
  results <- results[!sapply(results, is.null)]  # drop failed ones
  if (length(results) == 0) return(NULL)
  bind_rows(results)
}

# UI
ui <- fluidPage(
  titlePanel("Poll of Polls — India 2024 (Simulated)"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("selected_parties", "Select Parties:",
                         choices = parties,
                         selected = parties)
    ),
    mainPanel(
      plotOutput("trendPlot")
    )
  )
)

# Server
server <- function(input, output) {
  output$trendPlot <- renderPlot({
    req(input$selected_parties)
    
    df <- apply_kalman_all_parties(polls, input$selected_parties)
    req(!is.null(df))
    
    ggplot(df, aes(x = date, color = party, fill = party)) +
      geom_point(aes(y = raw_vote), color = "gray70", alpha = 0.4, size = 1) +
      geom_line(aes(y = smoothed), size = 1.2) +
      geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, color = NA) +
      labs(
        title = "Vote Share Trends by Party",
        x = "Date", y = "Vote Share (%)"
      ) +
      theme_minimal(base_size = 14) +
      theme(legend.position = "top")
  })
}

# Run the app
shinyApp(ui = ui, server = server)
