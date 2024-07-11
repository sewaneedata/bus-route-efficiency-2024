# load libraries

library(sf)
library(tmap)
library(osmdata)
library(tidycensus)
library(tidyverse)
library(mapsapi)
library(geodata)

# load bus routes data

bus_routes <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/12Qj9yy1YgqnOWQk3qDCRP9LjsEQUckdJz9DPwogGDSM/edit?pli=1&gid=0#gid=0") %>% 
  mutate( Address = paste0( Address, " 'Franklin County' TN" ) )

# Create a map of Franklin County and the school bus routes

load("data/bus_gis.RData")

bus_routes <- left_join( bus_points %>% select( Address = address, address_google, location_type, pnt ), bus_routes, by = "Address")
bus_routes$Bus <- as.character( bus_routes$Bus )
bus_routes$Bus <- factor( bus_routes$Bus, levels = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", 
                                                     "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", 
                                                     "25", "26", "28", "29", "30", "32", "35", "36", "38", "41", "48", 
                                                     "49", "51", "52", "53", "54"))

tmap_mode( "view" )
tmap_options( basemaps = providers$OpenStreetMap )

# Create layers for each bus route or address.

map <- tm_shape(franklin, name = "Franklin County Border") +
  tm_polygons(alpha = 0.5, lwd = 3) 

# for(i in as.numeric(as.character(unique(bus_routes$Bus))) %>% sort()) {
#   map <- map +
#     tm_shape(bus_routes %>% filter(Bus == i), name = paste0("Bus Route ", i)) +
#     tm_dots(col = "Bus")
# }

buses <- levels( bus_routes$Bus )
for(bus in buses ){
  map <- map +
    tm_shape(bus_routes %>% filter(Bus == bus), name = paste0("Bus Route ", bus)) +
    tm_dots(col = "Bus", size=0.1)
}

bus_route_names <- unique( paste0( "Bus Route ", bus_routes$Bus ) )

map %>% 
  tmap_leaflet( ) %>%
  hideGroup( bus_route_names ) 

# Getting unique values of bus routes to unselect the layers by default. 
bus_route_names <- unique( paste0( "Bus Route ", bus_routes$Bus ) )
map %>% 
  
