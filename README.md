# Poll of Polls - India 2024 General Elections

A Shiny application to simulate and analyze polling data for the 2024 Indian general elections using Kalman filtering to estimate vote share trends and uncertainty.

---

## Overview

This project demonstrates a simplified poll aggregation methodology using simulated data from four major Indian political parties. It includes a Shiny web app that visualizes weighted polling trends and their associated uncertainty using Kalman filters.

---

## Objectives

- Simulate polling data with realistic variation
- Apply sample size and time-decay weighting
- Use Kalman filtering for smoothing noisy poll data
- Provide interactive exploration of trends via Shiny

---

## Features

- **Simulated Polling Data**: Generated with built-in pollster biases and sample noise
- **Poll Weighting**: Combines time decay and sample size effects
- **Kalman Filtering**: Trend smoothing with confidence intervals
- **Interactive Shiny Dashboard**: Explore trends by party and timeframe
- **Uncertainty Quantification**: 95% confidence bands on smoothed estimates

---

## Project Structure

```
Poll_of_Polls/
├── app.R                            # Shiny application
├── data_sim.Rmd                     # Data simulation script
├── poll_weighting.Rmd              # Poll weighting methodology
├── kalman_filtering.Rmd            # Kalman filter modeling and plots
├── data/
│   ├── india_2024_polling_simulation.csv    # Raw simulated polls
│   └── india_2024_weighted_polls.csv        # Weighted poll data
└── README.md                        # Project overview (this file)
```

---

## Methodology

### 1. Poll Simulation (`data_sim.Rmd`)
- Timeframe: Feb 5 – Apr 15, 2024 (weekly polls)
- Polling firms: C Voter, Axis My India, Lokniti-CSDS, People’s Insight
- Parties: BJP, INC, AAP, Others
- Each poll includes bias, noise, and a realistic sample size (800–1600)

### 2. Poll Weighting (`poll_weighting.Rmd`)
- **Time Decay**: More recent polls weighted higher (λ = 0.05)
- **Sample Size**: √n scaling favors larger polls
- Final weight = `exp(-λ * days_since) * sqrt(n)`

### 3. Kalman Filtering (`kalman_filtering.Rmd`)
- Random walk state model
- Observation = true support + poll noise
- Maximum likelihood estimation for dV, dW
- Generates smoothed vote share + uncertainty bands

---

## Running the App

### Requirements
```r
install.packages(c("shiny", "tidyverse", "dlm", "lubridate", "plotly"))
```

### Launch App
```r
shiny::runApp("app.R")
```

### Usage
- Select parties from the sidebar
- View smoothed trends and raw points
- Hover for details, zoom with Plotly

---

## Included Political Parties

- **BJP** – Bharatiya Janata Party
- **INC** – Indian National Congress
- **AAP** – Aam Aadmi Party
- **Others** – All other parties grouped

---

## Technical Skills Demonstrated

- R Programming (tidyverse, functional programming)
- Shiny development (reactivity, UI/UX)
- Statistical modeling (Kalman filtering, weighting)
- Debugging and numerical stability (dlm variance edge cases)
- Workflow design: modular scripts, reproducible analysis

---

## 📌 Development Notes

- Kalman filtering and `dlm` stability debugging was assisted using Claude AI.
- Project concept, simulation methodology, Shiny interface, and overall structure were independently developed.

---

## 🔮 Future Enhancements

- Integration with real-time polling data
- Alternative smoothing (e.g., LOESS, spline)
- Regional and state-level disaggregation
- Forecasting turnout or seats
- Quality scoring for pollsters

---

## License

This project is for **educational and demonstration purposes only**.

---

## Acknowledgments

- Claude AI (technical debugging) and assistance with Kalman filtering + shiny app UI
- POLITICO Europe methodology inspiration
- R open source community
