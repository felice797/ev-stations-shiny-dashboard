# EV Charging Stations Visualization for Connecticut
# Standalone leaflet map showing Level 3 (DC Fast) charging stations

library(leaflet)
library(dplyr)

# Load and preprocess data
d <- readRDS('data/EVstations.rds')
colnames(d) <- tolower(colnames(d))

# Data preprocessing 
d_processed <- d %>%
  # Remove unnecessary fuel type columns
  select(-matches('cng|lng|lpg|hydrogen|e85|bd[.]blends|french|^ng[.]|plus4|level1')) %>%
  
  # Filter for electric vehicles only
  filter(fuel.type.code == 'ELEC') %>%
  
  # Rename columns for clarity
  rename(
    lev2 = ev.level2.evse.num, 
    lev3 = ev.dc.fast.count, 
    network = ev.network, 
    lat = latitude, 
    lon = longitude
  ) %>%
  
  # Clean and standardize data
  mutate(
    # Standardize status codes
    status = case_when(
      status.code == 'E' ~ 'Available', 
      status.code == 'P' ~ 'Planned', 
      status.code == 'T' ~ 'Temporarily Unavailable', 
      TRUE ~ 'Unknown'
    ),
    
    # Handle missing values
    lev2 = ifelse(is.na(lev2), 0, lev2), 
    lev3 = ifelse(is.na(lev3), 0, lev3),
    
    # Clean network names
    network = case_when(
      network == 'Tesla Destination' ~ 'Tesla',
      TRUE ~ network
    ),
    
    # Fix encoding issues
    network = gsub('Ã©', 'é', network),
    network = gsub('Ã‰', 'É', network)
  ) %>%
  
  # Filter for valid coordinates
  filter(
    !is.na(lon), 
    !is.na(lat),
    lon < -1,  
    lat > 1
  )

# Group networks for better visualization
d_final <- d_processed %>%
  mutate(
    network_group = case_when(
      network %in% c('Tesla', 'Electrify America', 'ChargePoint Network', 
                     'eVgo Network', 'Non-Networked') ~ network, 
      TRUE ~ 'Other'
    )
  ) %>%
  
  # Filter for Level 3 charging stations only
  filter(lev3 > 0) %>%
  
  # Focus on Connecticut for this visualization
  filter(state == 'CT')

# Create the leaflet map
ev_map <- leaflet(d_final %>% filter(state == 'CT')) %>% 
  addTiles() %>% 
  
  # Size the dots by the number of chargers at that location
  addCircleMarkers(lng = ~lon, lat = ~lat, 
                   radius = ~(lev3 + lev2)*1.5, 
                   color = "red",
                   group = ~network, 
                   popup = ~paste(network, '<br>', 
                                  station.name, '<br>', 
                                  street.address, '<br>', 
                                  city, ', ', state, ' ', zip, '<br>', 
                                  'Level 2: ', lev2, '<br>', 
                                  'Level 3: ', lev3)) %>%
  
  # Add layers control to toggle between network groups
  addLayersControl(  
    overlayGroups = unique(d_final$network),
    options = layersControlOptions(collapsed = FALSE)
  )

# Display the map
print(ev_map)

htmlwidgets::saveWidget(ev_map, "ct_ev_stations.html")