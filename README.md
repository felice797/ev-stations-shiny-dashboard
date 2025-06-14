# EV Charging Stations Visualization 

Interactive geospatial analysis of U.S. electric vehicle charging infrastructure using R, Leaflet, Shiny, and dplyr. The visualizations features both a comprehensive multi-state dashboard and a focused Connecticut case study with data cleaning, reactive programming, and web deployment.

## Contents 
1. [Overview](#overview)
2. [Project Files](#project-files)
3. [Key Features](#key-features)
4. [Quick Start](#quick-start)

## Overview
This project transforms raw EV charging station data into interactive web visualizations, showcasing both a focused state-level map (Connecticut) and a comprehensive national dashboard that reveal geographic distribution patterns and network provider coverage.

## Project Files 

- `leaflet.R`: Script containing data preprocessing and Connecticut-focused Level 3 charging station analysis
- `ct_ev_stations.html`: Standalone interactive map widget
- `app.R`: Script implementing a multi-state interactive dashboard with filtering controls
  - The app can be accessed at https://felice797.shinyapps.io/hw5_ev_shiny/

## Key Features 
- **Data Preprocessing**: Cleaning of messy real-world dataset with missing values and encoding issues
- **Proportional Symbol Mapping**: Marker sizes dynamically reflect charging capacity (Level 2 + Level 3 ports)
- **Multi-State Analysis**: Dropdown selection for all U.S. states with EV infrastructure (Shiny app)
- **Temporal Filtering**: Date range picker for analyzing infrastructure growth over time
- **Dynamic Network Selection**: Checkboxes with select all/clear all functionality for charging network providers
- **Charging Level Toggle**: Radio buttons to switch between Level 2 and Level 3 charging analysis
- **Responsive Filtering**: State selection dynamically updates available network options
- **Interactive Elements**: Click-through popups with detailed station information and network filtering
- **Responsive Design**: Cross-platform compatibility (desktop/mobile)

## Quick Start 
**Prerequisites**: R with `leaflet`, `dplyr`, `shiny`, `htmlwidgets`

``` 
# Generate static interactive map
source("leaflet.R")

# Launch interactive Shiny dashboard
shiny::runApp("app.R")

# View standalone map widget
# Open ct_ev_stations.html in browser
```
