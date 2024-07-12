# Bus function

library(dplyr)
library(ggplot2)
library(tidygeocoder)


################################################################################
# Function: ingest dataset and geocode addresses

bus_data_process <- function(url){

  # Take a url
  df <- gsheet::gsheet2tbl(url)

  # Geocode addresses (handling lat long replacements)
  dfgeo <-
    df %>%
    mutate(address = paste0(address,', Franklin County, TN, USA')) %>%
    tidygeocoder::geocode(address, method = 'osm', lat = y , long = x)
  dfgeo %>% as.data.frame

  # Fill in any gaps using the lon and lat columns
  bus_data <-
    dfgeo %>%
    rowwise() %>%
    # Final coordinates
    mutate(x = ifelse(!is.na(lon), lon, x)) %>%
    mutate(y = ifelse(!is.na(lat), lat, y)) %>%
    mutate(valid = ifelse(any(c(is.na(x), is.na(y))), FALSE, TRUE)) %>%
    ungroup()

  # N on board
  bus_data <-
    bus_data %>%
    group_by(bus_route) %>%
    arrange(order) %>%
    mutate(n_big_change = n_big_pickup - n_big_dropoff) %>%
    mutate(n_lil_change = n_lil_pickup - n_lil_dropoff) %>%
    mutate(n_big_tot = cumsum(n_big_change)) %>%
    mutate(n_lil_tot = cumsum(n_lil_change)) %>%
    ungroup()


  return(  bus_data %>% as.data.frame )
}

################################################################################
# Function: map dataset

bus_mapper <- function(bus_data){

  # Prep for tmap
  bus_data %>% head

  # Filter out invalid rows
  bus_data <- bus_data %>% filter(valid == TRUE)
  bussf <- sf::st_as_sf(bus_data, coords = c('x','y'))

  # Re-produce tmap with lines connected in order
  # Make the map interactive
  tmap::tmap_mode("plot")
  tmap_options(basemaps = providers$OpenStreetMap)

  # Create the base map with Franklin County Border
  load('franklin_county.rds')
  map <- tm_shape(franklin, name = "Franklin County Border") +
    tm_polygons(alpha = 0.5, lwd = 3)

  # Add bus routes to the map
  (buses <- unique(bussf$bus_route) %>% as.character)
  pal <- colorRampPalette(colors = c('red', 'yellow', 'green', 'blue', 'violet'))
  (bus_colors <- pal(length(buses)))
  busi = 1
  for (busi in 1:length(buses)) {
    (bus <- buses[busi])
    colori <- bus_colors[busi]

    # filter to relevant route
    bus_map <-
      bussf %>%
      filter(bus_route == bus)

    # if there is an order column, order it
    if('order' %in% names(bus_map)){
      bus_map <-
        bus_map %>%
        arrange(order)
    }

    # Add dots
    map <- map +
      tm_shape(bus_map, name = paste0("Bus Route ", bus)) +
      tm_dots(col = colori, id = "Address", size = 0.1, legend.show = TRUE)

    # Add lines in bus route
    (bus_line <- as_Spatial(bus_map))
    (bus_line <- as(bus_line, 'SpatialLines'))
    map <- map +
      tm_shape(bus_line, name = paste0('Bus Line ', bus)) +
      tm_lines(col = colori)
  }

  map
}

################################################################################
################################################################################
################################################################################
################################################################################
# Run it

# example url
url <- 'https://docs.google.com/spreadsheets/d/1MubRFGO4eIxN1aCQOBe3REAye525-wzqOIzaTYIIg4I/edit?usp=sharing'

# re-process data
bus_data <- bus_data_process(url)

# check it out
bus_data

# map it
bus_mapper(bus_data)


################################################################################
################################################################################
################################################################################
################################################################################
# Build shiny app around it


################################################################################
# UI

ui <- fluidPage(
  fluidRow(column(12, h2('Starting point for bus dashboard'))),
  br(),
  fluidRow(column(12,
                  textInput('url_bus',
            value = 'https://docs.google.com/spreadsheets/d/1MubRFGO4eIxN1aCQOBe3REAye525-wzqOIzaTYIIg4I/edit?usp=sharing',
            label = 'Provide the link for bus route data',
            width = '100%'))),
  fluidRow(column(12, actionButton('reprocess', 'Update dataset', width='50%'))),
  br(),
  br(),
  fluidRow(column(12,
                  plotOutput('map')
                  )))

################################################################################
# SERVER

server <- function(input, output) {

  rv <- reactiveValues()
  rv$bus_data <- NULL

  observeEvent(input$reprocess, {
    withProgress(message = 'Geocoding addresses ...', value = .5, {
      rv$bus_data <- bus_data_process(input$url_bus)
    }
    )
  })

  output$map <- renderPlot({
    if(!is.null(rv$bus_data)){
      bus_mapper(rv$bus_data)
    }
  })

}

################################################################################
# LAUNCH APP

shinyApp(ui = ui, server = server)


