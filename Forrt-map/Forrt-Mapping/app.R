library(shiny)
library(leaflet)

source("map_builder.R")

coords_data <- load_coords()

# Iframe hosts append ?embed=true to get the map without the page title and description
is_embed <- function(query_string) {
  embed <- parseQueryString(query_string)$embed
  isTRUE(tolower(embed) %in% c("true", "1", "yes"))
}

# The onRender hook in map_builder.R removes the element by its "loader" id; keep the two in sync
loader_css <- "
  #loader {
    position: fixed;
    top: 50%;
    left: 50%;
    width: 40px;
    height: 40px;
    margin: -20px 0 0 -20px;
    border: 4px solid #dddddd;
    border-top-color: #555555;
    border-radius: 50%;
    animation: forrt-spin 0.8s linear infinite;
    z-index: 1000;
  }
  @keyframes forrt-spin { to { transform: rotate(360deg); } }
"

loader <- div(id = "loader", role = "status", `aria-label` = "Loading map")

# No min-height here (unlike full_ui): it would give a short iframe an inner scrollbar
embed_ui <- fillPage(
  title = "FORRT Community Map",
  tags$head(tags$style(HTML(loader_css))),
  loader,
  leafletOutput("map", height = "100%")
)

full_ui <- fluidPage(
  tags$head(
    tags$style(HTML(paste0(loader_css, "
      .leaflet-container {
        min-height: 600px !important;
      }
    ")))
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
      paste0("The FORRT Community Map is a visualization tool that illustrates the global reach and
 diversity of the Framework for Open and Reproducible Research Training (FORRT) community.
 As of ", DATA_SNAPSHOT, ", this map provides a snapshot of FORRT's members worldwide,
 highlighting FORRT's extensive international collaboration and
  its commitment to fostering open and reproducible research practices across various regions.
 The map underscores FORRT's dedication to inclusivity and its efforts to build a
 diverse network of scholars, educators, and researchers united in advancing open science principles. ")
    ),
    mainPanel(
      width = 12,
      loader,
      leafletOutput("map", height = "75vh")
    )

  )
)

# A UI function lets one deployment serve both layouts, picked per request from the URL
ui <- function(req) {
  if (is_embed(req$QUERY_STRING)) embed_ui else full_ui
}

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    # isolate(): the layout was fixed when the UI was served, so URL changes must not re-render the map
    embed <- is_embed(isolate(session$clientData$url_search))
    build_forrt_map(coords_data, scroll_guard = embed)
  })
}

shinyApp(ui, server)
