library(leaflet)
library(leaflet.extras)  # For the reset (easy) button
library(dplyr)
library(htmltools)       # For constructing custom HTML layout
library(htmlwidgets)

# Load precomputed data
coords_data <- read.csv("data/coords_data.csv") %>%
  filter(!is.na(lon), !is.na(lat)) %>%
  mutate(count = as.integer(count))

# Create an improved color palette
pal <- colorNumeric(
  # reverse = TRUE,
  palette = "viridis",  # More visually distinct than Blues
  domain = coords_data$count
)

# Define the HTML content to be displayed on the map
map_header <- tags$div(
  # style = "background: white; padding: 10px; border-radius: 8px; box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1); max-width: auto;",
  # tags$h1("FORRT Community Map", style = "font-size: 20px; margin: 5px 0; text-align: center;"),
  # tags$a(
  #   href = "https://forrt.org",
  #   "Framework for Open and Reproducible Research Training",
  #   target = "_blank",
  #   style = "font-size: 16px; text-align: center; display: block; text-decoration: none; color: #007BFF; font-weight: bold;"
  # ),
  # tags$p("The FORRT Mapping Project visualizes our global community.", style = "font-size: 14px; text-align: center; margin-top: 5px;"),
  # tags$p(
  #   "Note: This data is a snapshot of FORRT community members as of 2024.",
  #   style = "font-size: 14px; font-weight: bold; text-align: center;"
  # )
)

# Create the leaflet map with an initial view and a reset button
base_map <- leaflet(coords_data, options = leafletOptions(minZoom = 2)) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(lng = 0, lat = 30, zoom = 2) %>%
  addCircleMarkers(
    lng = ~lon,
    lat = ~lat,
    radius = ~log(sqrt(count)+3)*4,  # Increased size multiplier
    stroke = TRUE,             # Add subtle border
    color = "#444444",         # Border color
    weight = 1,                # Border thickness
    fillColor = ~pal(count),
    fillOpacity = 0.9,         # Increased opacity
    popup = ~sprintf("<b>%s</b><br>%d member%s", city, count, ifelse(count == 1, "", "s")),
    labelOptions = labelOptions(textsize = "14px")
  ) %>%
  addLegend(
    position = "topright",
    pal = pal,
    values = ~count,
    title = "Members",
    opacity = 0.9
  ) %>%
  addEasyButton(easyButton(
    icon = "fa-home",
    title = "Reset Map",
    onClick = JS("function(btn, map){ map.setView([30, 0], 2); }")
  )) %>%
  addControl(
    html = as.character(map_header),
    position = "topright"
  )

# Save as a self-contained HTML file to avoid a separate "lib" folder
saveWidget(
  base_map, 
  file = "forrt-map.html", 
  selfcontained = TRUE
)
