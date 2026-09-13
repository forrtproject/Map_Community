library(htmlwidgets)

source("map_builder.R")

# This page is the recommended iframe embed (no Shiny server cold starts), so always guard scrolling
base_map <- build_forrt_map(load_coords(), scroll_guard = TRUE)

# A single file can be hosted on GitHub Pages or embedded without shipping a lib/ folder alongside
saveWidget(
  base_map,
  file = "community_map.html",
  selfcontained = TRUE,
  title = "FORRT Community Map"
)
