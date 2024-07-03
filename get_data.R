# load libraries

library(sf)
library(tmap)
library(osmdata)
library(tidycensus)
library(tidyverse)
library(mapsapi)
library(geodata)
library(leaflet)

# load bus routes data
# Reads in the school data
schools <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1SZl3nINhH9V832c_KYjxHGKEfWM4bSwYMRpCgNZg5XM/edit?gid=0#gid=0")

# Transforms the school data into long/lat coordinates. 
schools <- st_as_sf( schools, coords = c("LONG", "LAT"), crs = "WGS84")

bus_routes <- gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/12Qj9yy1YgqnOWQk3qDCRP9LjsEQUckdJz9DPwogGDSM/edit?pli=1&gid=0#gid=0") %>% 
  mutate( Address = paste0( Address, " 'Franklin County' TN" ) )

# Loading the latitude and longitude data of addresses

load("data/bus_gis.RData")

# Adding the longitude and latitude to the data frame
bus_routes <- left_join( bus_points %>% select( Address = address, address_google, location_type, pnt ), bus_routes, by = "Address")
# Converting the Bus numbers to characters
bus_routes$Bus <- as.character( bus_routes$Bus )
# Converting the Bus numbers to factors to enable automatic coloring on the map
bus_routes$Bus <- factor( bus_routes$Bus, levels = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", 
                                                     "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", 
                                                     "25", "26", "28", "29", "30", "32", "35", "36", "38", "41", "48", 
                                                     "49", "51", "52", "53", "54"))

# Making the map interactive
tmap_mode( "view" )
tmap_options( basemaps = providers$OpenStreetMap )

# Create layers for each bus route or address.

map <- tm_shape(franklin, name = "Franklin County Border") +
  tm_polygons(alpha = 0.5, lwd = 3) 


# Get the levels of the bus routes data frame
buses <- levels( bus_routes$Bus )
# The for loop is iterating through each bus and it is adding the bus routes to the map.
for(bus in buses ){
  map <- map +
    tm_shape(bus_routes %>% filter(Bus == bus), name = paste0("Bus Route ", bus)) +
    tm_dots(col = "Bus", size=0.1) 
}

map = map +  tm_shape( schools ) + 
  tm_dots(col = 'SCHOOL', id = 'SCHOOL')

# Getting unique values of bus routes to unselect the layers by default. 
bus_route_names <- unique( paste0( "Bus Route ", bus_routes$Bus ) )
map %>% 
  tmap_leaflet( ) %>%
  hideGroup( bus_route_names ) 







