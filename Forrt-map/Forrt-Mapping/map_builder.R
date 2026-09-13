# Shared by app.R and generate_static_map.R so the Shiny app and the static page cannot drift apart.

library(leaflet)
library(dplyr)

# Not derivable from the data files; update by hand whenever the member export is refreshed.
DATA_SNAPSHOT <- "January 2024"

# Counts are heavily skewed (most cities have fewer than 10 members), so the low end gets
# narrow bins; a linear scale colours almost every city the same.
MEMBER_BINS <- c(1, 5, 10, 20, 50, 100, 200, 250, Inf)
MEMBER_BIN_LABELS <- paste0(head(MEMBER_BINS, -1), "+")

load_coords <- function(path = "data/coords_data.csv") {
  read.csv(path) %>%
    filter(!is.na(lon), !is.na(lat)) %>%
    mutate(
      count = as.integer(count),
      members = sprintf("%d member%s", count, ifelse(count == 1, "", "s"))
    ) %>%
    # Leaflet stacks markers in data order; big circles underneath keep nearby small cities clickable
    arrange(desc(count))
}

#' @param coords_data Output of load_coords().
#' @param scroll_guard Use TRUE when the map is embedded in an iframe: wheel zoom stays off until
#'   the map is clicked, otherwise scrolling the host page gets captured by the map.
build_forrt_map <- function(coords_data, scroll_guard = FALSE) {
  # right = FALSE gives [lower, upper) bins, which is what the "5+" style labels promise
  pal <- colorBin("viridis", bins = MEMBER_BINS, right = FALSE)

  leaflet(coords_data, options = leafletOptions(
    minZoom = 2,
    zoomSnap = 0.5,
    # Leaflet's default of 60 jumps a full zoom level on small wheel movements
    wheelPxPerZoomLevel = 120,
    # +/-85 degrees is where Web Mercator tiles end; beyond it there is only grey background
    maxBounds = list(c(-85, -180), c(85, 180)),
    maxBoundsViscosity = 1,
    scrollWheelZoom = !scroll_guard
  )) %>%
    # Not CARTO Positron: CARTO now watermarks keyless tiles with "API KEY REQUIRED", and a key
    # would be exposed in public HTML. Esri labels are a separate layer, empty below zoom 3.
    addProviderTiles(providers$Esri.WorldGrayCanvas) %>%
    addTiles(
      urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Reference/MapServer/tile/{z}/{y}/{x}",
      options = tileOptions(maxZoom = 16)
    ) %>%
    setView(lng = 0, lat = 30, zoom = 2) %>%
    addCircleMarkers(
      lng = ~lon,
      lat = ~lat,
      radius = ~log(sqrt(count) + 3) * 4,
      # Without an outline the light (high-count) viridis colours fade into the grey basemap
      stroke = TRUE,
      color = "#444444",
      weight = 1,
      fillColor = ~pal(count),
      fillOpacity = 0.9,
      # Both label and popup: touch devices have no hover, so they rely on the popup
      label = ~paste0(city, ": ", members),
      labelOptions = labelOptions(textsize = "13px", direction = "auto"),
      popup = ~sprintf("<b>%s</b><br>%s", htmltools::htmlEscape(city), members)
    ) %>%
    addLegend(
      position = "topright",
      colors = pal(head(MEMBER_BINS, -1)),
      labels = MEMBER_BIN_LABELS,
      title = "Members",
      opacity = 0.9
    ) %>%
    addEasyButton(easyButton(
      icon = "fa-home",
      title = "Reset Map",
      onClick = JS("function(btn, map){ map.setView([30, 0], 2); }")
    )) %>%
    htmlwidgets::onRender(
      "function(el, x, data) {
        var map = this;
        // #loader exists only in the Shiny UI (app.R); the static page has no spinner
        var loader = document.getElementById('loader');
        if (loader) loader.remove();
        if (data.scrollGuard) {
          map.on('click', function() { map.scrollWheelZoom.enable(); });
          // Re-arm the guard so page scrolling works again once the pointer leaves the map
          map.on('mouseout', function() { map.scrollWheelZoom.disable(); });
        }
      }",
      data = list(scrollGuard = scroll_guard)
    )
}
