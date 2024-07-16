################################################################################
################################################################################
# Function: ingest dataset and geocode addresses

bus_data_process <- function(url){

  #googlesheets4::read_sheet(url)
  #sheets_names <- googlesheets4::sheet_names(url)
  #routes <- lapply(sheets_names, function (x) googlesheets4::read_sheet(url, x))
  #routes

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

  # Calculate N on board
  bus_data <-
    bus_data %>%
    group_by(bus_route) %>%
    arrange(order) %>%
    mutate(n_big_pickup = tidyr::replace_na(n_big_pickup, 1)) %>%
    mutate(n_big_dropoff = tidyr::replace_na(n_big_dropoff, 1)) %>%
    mutate(n_lil_pickup = tidyr::replace_na(n_lil_pickup, 1)) %>%
    mutate(n_lil_dropoff = tidyr::replace_na(n_lil_dropoff, 1)) %>%
    mutate(n_big_change = n_big_pickup - n_big_dropoff) %>%
    mutate(n_lil_change = n_lil_pickup - n_lil_dropoff) %>%
    mutate(n_big_tot = cumsum(n_big_change)) %>%
    mutate(n_lil_tot = cumsum(n_lil_change)) %>%
    mutate(n_tot = n_big_tot + n_lil_tot) %>%
    ungroup()

  return(  bus_data %>% as.data.frame )
}


################################################################################
################################################################################
# Check validity

bus_validity_check <- function(bus_data){
  # If the dashboard is being run, which sets the workign directory to the dashboard folder
  if(grepl("dashboard", dirname(rstudioapi::getSourceEditorContext()$path))) {
    # Then go back a folder before going into the data folder to load the file
    load('../data/franklin_county.rds')
  } else {
    # Otherwise, the working directory should be the main project folder and this should work
    load('data/franklin_county.rds')
  }
  

  # Add row id
  busi <- bus_data
  busi$row_id <- 1:nrow(busi)

  # Convert to spatial
  bussf <- busi %>% filter(valid == TRUE)
  bussf <- sf::st_as_sf(bussf, coords = c('x','y'))

  # Find any addresses outside of franklin county
  st_crs(bussf) <- crs(franklin)
  busfiltered <- st_filter(bussf, franklin)
  goodrows <- busfiltered$row_id

  # Update bus_data accordingly
  busi <- busi %>%
    mutate(valid = ifelse(row_id %in% goodrows, valid, FALSE))

  bus_data %>% nrow
  busi %>% nrow

  return(busi)
}

################################################################################
################################################################################
# Function: map dataset

bus_mapper <- function(bus_data){

  # Prep for tmap
  bus_data %>% head

  # Filter out invalid rows
  bus_data <- bus_data %>% filter(valid == TRUE)
  if(! 'sf' %in% class(bus_data)){
    bussf <- sf::st_as_sf(bus_data, coords = c('x','y'))
  }else{
    bussf <- bus_data
  }

  # Re-produce tmap with lines connected in order
  # Make the map interactive
  #tmap::tmap_mode("plot")
  tmap::tmap_mode("view")
  tmap_options(basemaps = providers$OpenStreetMap)

  # Create the base map with Franklin County Border
  
  # If the dashboard is being run, which sets the workign directory to the dashboard folder
  if(grepl("dashboard", dirname(rstudioapi::getSourceEditorContext()$path))) {
    # Then go back a folder before going into the data folder to load the file
    load('../data/franklin_county.rds')
  } else {
    # Otherwise, the working directory should be the main project folder and this should work
    load('data/franklin_county.rds')
  }
  map <- tm_shape(franklin, name = "Franklin County Border") +
    tm_polygons(alpha = 0.5, lwd = 3)

  # Get schools addresses and assign a color
 # unique_school_col <- bus_data %>% filter(`type` == "school")
 # 
 #  unq_school_col <- unique(unique_school_col$address)
 #  
  # Add bus routes to the map
  (buses <- unique(bussf$bus_route) %>% as.character)
  (buses <- buses[!is.na(buses)])
  pal <- colorRampPalette(colors = c('red', 'yellow', 'green', 'blue', 'violet'))
  (bus_colors <- pal(length(buses)))
  busi = 20
  for (busi in 1:length(buses)) {
    (bus <- buses[busi])
    colori <- bus_colors[busi]

    # filter to relevant route
    bus_map <-
      bussf %>%
      filter(bus_route == bus)

    # if there is an order column, order the route accordingly
    if('order' %in% names(bus_map)){
      bus_map <-
        bus_map %>%
        arrange(order)
    }

    # Add dots
    map <- map +
      tm_shape(bus_map, name = paste0("Bus Route ", bus)) +
      tm_dots(col = colori, id = "Address", size = 0.1, legend.show = TRUE)

    if(nrow(bus_map)>1){
      # Add lines in bus route
      (bus_line <- as_Spatial(bus_map))
      (bus_line <- as(bus_line, 'SpatialLines'))
      map <- map +
        tm_shape(bus_line, name = paste0('Bus Route ', bus)) +
        tm_lines(col = colori)
    }
  }

  return(map)
}


################################################################################
################################################################################
# Function: pickup/dropoff sequences

bus_sequence <- function(bus_data){

  bus_data %>% head

  # if there is an order column, order the route accordingly
  if('order' %in% names(bus_data)){
    bus_data <-
      bus_data %>%
      group_by(bus_route) %>%
      arrange(order) %>%
      ungroup()
  }else{
    bus_data %>%
      group_by(bus_route) %>%
      mutate(order = 1:n()) %>%
      ungroup()
  }

  # Pivot longer
  busplot <-
    pivot_longer(bus_data,
               cols = c(n_big_tot, n_lil_tot, n_tot),
               names_to = 'group',
               values_to = 'n') %>%
    mutate(group = ifelse(group == 'n_tot',
                          'Total',
                          ifelse(group == 'n_lil_tot',
                                 'Young students',
                                 ifelse(group == 'n_big_tot',
                                        'Older students',
                                        NA)))) %>%
    #mutate(group = factor(group, levels=c('n_tot','n_lil_tot', 'n_big_tot'))) %>%
    mutate(group = factor(group, levels=c('Total','Young students', 'Older students'))) %>%
    as.data.frame

  # Plot it
  p <- ggplot(busplot,
         aes(x = order,
             y = n,
             color = factor(bus_route),
             lty=group)) +
    geom_path() +
    geom_point() +
    ylab('Total students on board') +
    xlab('Pickup/dropoff order') +
    labs(color = 'Bus route') +
    xlim(1, max(busplot$order)) +
    ylim(0, max(busplot$n))

  p
  return(p)
}


