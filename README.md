## Forrt Community Mapping 
The Forrt Mapping Project aims to visualize the global community of FORRT.

All files live in `Forrt-map/Forrt-Mapping/`. The map itself is defined once in `map_builder.R` and used by both outputs:

| Output | Built by | Best for |
| --- | --- | --- |
| `community_map.html` (static, self-contained) | `Rscript generate_static_map.R` | Embedding in other pages |
| Shiny app ([shinyapps.io](https://forrt-community-map.shinyapps.io/Forrt-Mapping/)) | `app.R` | Standalone page with title and description |

### Embedding the map
**Recommended: the static page.** The data doesn't change at runtime.

```html
<iframe
  src="https://forrtproject.github.io/map-community/Forrt-map/Forrt-Mapping/community_map.html"
  title="FORRT Community Map"
  style="width: 100%; height: 600px; border: 0;"
  loading="lazy">
</iframe>
```

**Alternative: the Shiny app in map-only mode.** Add `?embed=true` to hide the title and description:

```html
<iframe
  src="https://forrt-community-map.shinyapps.io/Forrt-Mapping/?embed=true"
  title="FORRT Community Map"
  style="width: 100%; height: 600px; border: 0;"
  loading="lazy">
</iframe>
```

In both embeds, scroll-wheel zoom turns on only after a click on the map, so scrolling the host page is not captured by the map.

### The data
The current data is a snapshot from **January 2024**.
