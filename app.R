library(shiny)
library(leaflet)
library(tidyverse)

d = readRDS('EVstations.rds')

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("EV Charging Stations"),
  
  # Sidebar  
  sidebarLayout(
    sidebarPanel(
      
      # Input: state
      selectInput("state", 
                  "Select a state", 
                  choices = sort(unique(d$State)), 
                  selected = 'CT'), 
      
      # Input: date range 
      dateRangeInput("date", 
                     "Select a date range",
                     start = "2015-01-01", 
                     end = Sys.Date()), 
      
      # Input: network
      checkboxGroupInput(
        "network", 
        "Select networks below", 
        choices = NULL, 
        selected = unique(d$EV.Network), 
        inline = TRUE
      ),
      
      # Input: action button 
      # add title 
      h4("Network Selection"),
      actionButton("select_all", "Select all networks"),
      br(),
      actionButton("select_none", "Clear all networks"), 
      
      # Input: level
      radioButtons("level", 
                   "Select a level", 
                   choices = c('Level 2', 'Level 3'), 
                   selected = 'Level 3'),
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      leafletOutput("map")
    )
  )
)

# Define server logic 
server <- function(input, output, session) {
  
  # reactive: get available networks for selected state 
  available_networks <- reactive({
    d %>%
      filter(State == input$state) %>%
      pull(EV.Network) %>%
      unique() %>%
      sort()
  })
  
  # observe action buttons 
  observe({
    networks = available_networks()
    # update the checkboxGroupInput choices
    updateCheckboxGroupInput(session, "network", 
                             choices = networks, 
                             selected = networks)
  })
  
  # observe action buttons 
  observeEvent(input$select_all, {
    updateSelectInput(session, "network", 
                      selected = sort(unique(d$EV.Network)))
  })
  observeEvent(input$select_none, {
    updateSelectInput(session, "network", 
                      selected = character(0))
  })
  
  output$map = renderLeaflet({
    
    if(is.null(input$network) || length(input$network) == 0) {
      # if no network is selected, show an empty map
      leaflet() %>%
        addTiles()
    }
    
    dg = d %>%
      filter(State == input$state, 
             Longitude < -1, 
             Latitude > 1, 
             Open.Date >= input$date[1], 
             Open.Date <= input$date[2],
             EV.Network %in% input$network,
             # if EV.Level2.EVSE.Num > 0, then 'Level 2' is selected
             case_when('Level 2' %in% input$level ~ EV.Level2.EVSE.Num > 0, 
                       # if EV.DC.Fast.Count > 0, then 'Level 3' is selected
                       'Level 3' %in% input$level ~ EV.DC.Fast.Count > 0, 
                       TRUE ~ FALSE)
             )
    
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(data = dg, 
                       lng = ~Longitude, 
                       lat = ~Latitude, 
                       popup = ~Station.Name)
    
  })
  
}


# Run the application 
shinyApp(ui = ui, server = server)