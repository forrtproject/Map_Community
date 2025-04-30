library(shiny)
library(leaflet)
library(dplyr)
library(shinyjs)

# Load precomputed data
coords_data <- read.csv("data/coords_data.csv") %>%
  filter(!is.na(lon), !is.na(lat)) %>%
  mutate(count = as.integer(count))

# Color palette for markers
pal <- colorNumeric(
  palette = "viridis",
  domain = coords_data$count
)

ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$style(HTML("
      #loader {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        padding: 20px;
        z-index: 1000;
      }
      .leaflet-container { 
        min-height: 600px !important; 
      }
    "))
  ),
  titlePanel("FORRT Community Map"),
  style = "max-width: 1200px; margin: 0 auto; padding: 10px;",
  
  div(
    style = "max-width: 1200px; margin: 0 auto; padding: 10px;",
    p(
      a(href = "https://forrt.org", 
        "Framework for Open and Reproducible Research Training",
        style = "font-weight: bold;"
      )
    ),
    p(
      "The FORRT Community Map is a visualization tool that illustrates the global reach and
 diversity of the Framework for Open and Reproducible Research Training (FORRT) community.
 As of January 2024, this map provides a snapshot of FORRT's members worldwide, 
 highlighting FORRT's extensive international collaboration and
  its commitment to fostering open and reproducible research practices across various regions. 
 The map underscores FORRT's dedication to inclusivity and its efforts to build a 
 diverse network of scholars, educators, and researchers united in advancing open science principles. ",
    ),
    mainPanel(
      width = 12,
      div(id = "loader", "Loading map..."),
      leafletOutput("map", height = "75vh")
    )
  
  )
)

server <- function(input, output, session) {
  
  #output$snapshot_date <- renderText(format(Sys.Date(), "%B %d, %Y"))
  
  filtered_data <- reactive({
    coords_data
  })
  
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(minZoom = 2, worldCopyJump = FALSE)) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 0, lat = 30, zoom = 2) %>%
      addCircleMarkers(
        data = coords_data,
        radius = 5,
        stroke = FALSE,
        fillColor = ~pal(count),
        fillOpacity = 0.8,
        popup = ~glue::glue("<b>{city}</b><br>{count} member{ifelse(count == 1, '', 's')}"),
        labelOptions = labelOptions(textsize = "14px")
      ) %>%
      addEasyButton(easyButton(
        icon = "fa-home",
        title = "Reset Map",
        onClick = JS("function(btn, map){ map.setView([30, 0], 2); }")
      )) %>%
      addLegend(
        position = "topright",
        pal = pal,
        values = coords_data$count,
        title = "Members",
        opacity = 0.8
      ) %>%
      htmlwidgets::onRender("function() { Shiny.setInputValue('map_loaded', true); }")
  })
  
  observeEvent(input$map_loaded, hide("loader"))
  
  observeEvent(input$reset, {
    leafletProxy("map") %>% 
      setView(lng = 0, lat = 30, zoom = 2)
  })
  
  
}

shinyApp(ui, server)
